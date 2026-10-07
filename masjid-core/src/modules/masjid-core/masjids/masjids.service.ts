import { randomBytes } from 'crypto';
import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import {
  getPhoneSearchVariants,
  normalizePhone,
} from '../../../common/utils/phone.util';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import {
  AUDIT_ACTION,
  AUDIT_ENTITY,
  AuditService,
} from '../../../common/audit/audit.service';
import { requireMasjidId } from '../../../common/tenant';
import { PrismaService } from '../../../prisma/prisma.service';
import { AppConfig } from '../../../config/app-config';
import { hasPermission, PERMISSIONS } from '../../../access/permissions';
import { Prisma } from '../../../generated/prisma/client';
import {
  MasjidStatus,
  RoleName,
  UserStatus,
} from '../../../generated/prisma/enums';
import { isPrismaError } from '../prisma-errors';
import { initialPasswordFor } from '../../platform-core/auth/initial-password';
import { BCRYPT_ROUNDS } from '../../platform-core/auth/auth.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import {
  CreateMasjidUserDto,
  CreateMasjidUserRoleDto,
} from './dto/create-masjid-user.dto';
import { UpdateWelcomeMessageDto } from './dto/update-welcome-message.dto';
import {
  UpdateMasjidUserDto,
  UpdateMasjidUserStatusDto,
} from './dto/update-masjid-user.dto';
import {
  CreatedMasjidUser,
  CreatedMasjidUserResponse,
  ExistingUserByPhone,
  existingUserByPhoneSelect,
  MasjidMember,
  MasjidMemberResponse,
  masjidMemberSelect,
  MasjidProfile,
  masjidProfileSelect,
  masjidUserCreateSelect,
  MasjidWelcome,
  masjidWelcomeSelect,
} from './masjids.selects';

@Injectable()
export class MasjidsService {
  private readonly logger = new Logger(MasjidsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: AppConfig,
    private readonly audit: AuditService,
  ) {}

  async getMyMasjid(actor: AuthenticatedUser): Promise<MasjidProfile> {
    const masjid = await this.prisma.masjid.findUnique({
      where: { id: requireMasjidId(actor) },
      select: masjidProfileSelect,
    });

    if (!masjid) throw this.masjidNotFound();
    return masjid;
  }

  async updateWelcomeMessage(
    dto: UpdateWelcomeMessageDto,
    actor: AuthenticatedUser,
  ): Promise<MasjidWelcome> {
    const masjidId = requireMasjidId(actor);

    try {
      const masjid = await this.prisma.$transaction(async (tx) => {
        const before = await tx.masjid.findUnique({
          where: { id: masjidId },
          select: masjidWelcomeSelect,
        });
        if (!before) throw this.masjidNotFound();
        const updated = await tx.masjid.update({
          where: { id: masjidId },
          data: { welcomeMsg: dto.welcomeMsg },
          select: masjidWelcomeSelect,
        });
        await this.audit.record(
          {
            masjidId,
            actor,
            action: AUDIT_ACTION.UPDATE,
            entity: AUDIT_ENTITY.MASJID,
            entityId: updated.id,
            summary: `Welcome message updated for ${updated.name}`,
            before,
            after: updated,
          },
          tx,
        );
        return updated;
      });
      this.logger.log({ message: 'Masjid welcome message updated', masjidId });
      return masjid;
    } catch (error) {
      // Only "the masjid is gone" becomes MASJID_NOT_FOUND; anything else
      // (database down, audit failure, ...) goes to the global filter.
      if (isPrismaError(error, 'P2025')) throw this.masjidNotFound();
      throw error;
    }
  }

  async createMyMasjidUser(
    actor: AuthenticatedUser,
    dto: CreateMasjidUserDto,
  ): Promise<CreatedMasjidUserResponse> {
    const callerRoles = actor.roles;
    this.assertCanCreateRole(callerRoles, dto.role);

    if (!this.isPlatformAdmin(callerRoles) && dto.masjidId) {
      throw new ApiException(
        'You are not allowed to choose a masjid',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.FORBIDDEN,
      );
    }

    this.assertProfileFields(dto.role, dto.isFamilyHead);
    const masjidId = this.resolveTargetMasjidId(callerRoles, actor, dto);
    const phone = normalizePhone(dto.phone);
    const email = dto.email?.trim().toLowerCase() || null;

    // Independent reads in one round trip.
    const [masjid, existingByPhone, existingByEmail] = await Promise.all([
      this.prisma.masjid.findUnique({
        where: { id: masjidId },
        select: { id: true, status: true },
      }),
      // One person = one phone number = one masjid at a time.
      this.prisma.user.findFirst({
        where: { phone: { in: getPhoneSearchVariants(phone) } },
        select: existingUserByPhoneSelect,
      }),
      email
        ? this.prisma.user.findUnique({
            where: { email },
            select: { id: true },
          })
        : Promise.resolve(null),
    ]);

    if (!masjid) throw this.masjidNotFound();

    if (masjid.status !== MasjidStatus.APPROVED) {
      throw new ApiException(
        'Masjid is not approved',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.MASJID_NOT_APPROVED,
      );
    }

    if (existingByPhone) {
      this.assertCanLinkExistingUser(existingByPhone, masjidId);
    } else if (existingByEmail) {
      throw new ApiException(
        'Email already exists',
        HttpStatus.CONFLICT,
        ERROR_CODES.EMAIL_ALREADY_EXISTS,
      );
    }

    // Imams and committee members log in with a password; members use OTP only
    // and get an unguessable password they never need.
    const initial = this.requiresTemporaryPassword(dto.role)
      ? initialPasswordFor(this.config)
      : null;
    const temporaryPassword = initial?.disclosable ? initial.password : null;

    if (existingByPhone) {
      // A linked member keeps their password; only a known one is set.
      return this.linkExistingUser({
        actor,
        existing: existingByPhone,
        masjidId,
        dto,
        passwordHash: initial
          ? await bcrypt.hash(initial.password, BCRYPT_ROUNDS)
          : null,
        temporaryPassword,
      });
    }

    const passwordHash = await bcrypt.hash(
      initial?.password ?? randomBytes(32).toString('hex'),
      BCRYPT_ROUNDS,
    );

    const createdUser = await this.prisma.$transaction(async (tx) => {
      // User, role link and the response row in one call.
      const created = await tx.user.create({
        data: {
          fullName: dto.fullName.trim(),
          phone,
          email,
          fatherName: dto.fatherName.trim(),
          age: dto.age,
          gender: dto.gender,
          isFamilyHead: this.isFamilyHeadFor(dto),
          familyMemberCount: dto.familyMemberCount ?? null,
          masjidId,
          status: UserStatus.ACTIVE,
          isPhoneVerified: false,
          isEmailVerified: false,
          passwordHash,
          userRoles: this.singleRole(dto.role),
        },
        select: masjidUserCreateSelect,
      });

      if (dto.role === CreateMasjidUserRoleDto.IMAM) {
        // Replacing imamUserId is allowed here; the previous imam user is not deleted.
        await tx.masjid.update({
          where: { id: masjidId },
          data: { imamUserId: created.id },
          select: { id: true },
        });
      }

      await this.audit.record(
        {
          masjidId,
          actor,
          action: AUDIT_ACTION.CREATE,
          entity: AUDIT_ENTITY.MEMBER,
          entityId: created.id,
          summary: `Member "${dto.fullName.trim()}" added as ${dto.role}`,
          after: created,
        },
        tx,
      );
      return created;
    });

    const response = this.toCreatedMasjidUserResponse(
      createdUser,
      temporaryPassword,
    );

    this.logger.log({
      message: 'Masjid user created',
      userId: response.id,
      masjidId,
      role: dto.role,
    });

    return response;
  }

  async updateMyMasjidUser(
    actor: AuthenticatedUser,
    userId: string,
    dto: UpdateMasjidUserDto,
  ): Promise<MasjidMemberResponse> {
    const phone = normalizePhone(dto.phone);
    // Omitted email: left unchanged. Empty email: cleared.
    const email =
      dto.email === undefined
        ? undefined
        : dto.email?.trim().toLowerCase() || null;

    // Permission check and both duplicate checks in one round trip; the
    // duplicate results are only looked at once the caller is allowed.
    const [target, duplicatePhone, duplicateEmail] = await Promise.all([
      this.ensureCanManageTargetUser(actor, userId),
      this.prisma.user.findFirst({
        where: {
          phone: { in: getPhoneSearchVariants(phone) },
          NOT: { id: userId },
        },
        select: { id: true },
      }),
      email
        ? this.prisma.user.findFirst({
            where: { email, NOT: { id: userId } },
            select: { id: true },
          })
        : Promise.resolve(null),
    ]);

    if (
      target.userRoles.some(
        (userRole) =>
          userRole.role.name === (CreateMasjidUserRoleDto.MEMBER as string),
      ) &&
      dto.isFamilyHead === undefined
    ) {
      throw new ApiException(
        'Is family head is required for member users',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }
    if (duplicatePhone) {
      throw new ApiException(
        'Phone number already exists',
        HttpStatus.CONFLICT,
        ERROR_CODES.PHONE_ALREADY_EXISTS,
      );
    }
    if (duplicateEmail) {
      throw new ApiException(
        'Email already exists',
        HttpStatus.CONFLICT,
        ERROR_CODES.EMAIL_ALREADY_EXISTS,
      );
    }

    const updated = await this.prisma.$transaction(async (tx) => {
      // The audit "before" is read in the same transaction as the write.
      const before = await tx.user.findFirst({
        where: { id: userId, masjidId: target.masjidId },
        select: masjidMemberSelect,
      });
      if (!before) throw this.masjidUserNotFound();
      const user = await tx.user.update({
        where: { id: userId },
        data: {
          fullName: dto.fullName.trim(),
          phone,
          email,
          fatherName: dto.fatherName.trim(),
          age: dto.age,
          gender: dto.gender,
          isFamilyHead: dto.isFamilyHead ?? false,
          familyMemberCount: dto.familyMemberCount ?? null,
        },
        select: masjidMemberSelect,
      });
      await this.audit.record(
        {
          masjidId: user.masjidId ?? target.masjidId,
          actor,
          action: AUDIT_ACTION.UPDATE,
          entity: AUDIT_ENTITY.MEMBER,
          entityId: user.id,
          summary: `Member "${user.fullName}" profile updated`,
          before,
          after: user,
        },
        tx,
      );
      return user;
    });
    this.logger.log({
      message: 'Masjid user updated',
      userId,
      masjidId: updated.masjidId,
    });
    return this.toMasjidMemberResponse(updated);
  }

  async updateMyMasjidUserStatus(
    actor: AuthenticatedUser,
    userId: string,
    dto: UpdateMasjidUserStatusDto,
  ): Promise<MasjidMemberResponse> {
    const target = await this.ensureCanManageTargetUser(actor, userId);
    const updated = await this.prisma.$transaction(async (tx) => {
      const user = await tx.user.update({
        where: { id: userId },
        data: { status: dto.status },
        select: masjidMemberSelect,
      });
      await this.audit.record(
        {
          masjidId: user.masjidId ?? target.masjidId,
          actor,
          action: AUDIT_ACTION.STATUS_CHANGE,
          entity: AUDIT_ENTITY.MEMBER,
          entityId: user.id,
          summary: `Member "${user.fullName}" status ${target.status} -> ${user.status}`,
          before: target,
          after: user,
        },
        tx,
      );
      return user;
    });
    this.logger.warn({
      message: 'Masjid user status changed',
      userId,
      status: dto.status,
    });
    return this.toMasjidMemberResponse(updated);
  }

  async findMyMasjidUsers(
    actor: AuthenticatedUser,
  ): Promise<MasjidMemberResponse[]> {
    const users = await this.prisma.user.findMany({
      where: { masjidId: requireMasjidId(actor) },
      orderBy: { fullName: 'asc' },
      select: masjidMemberSelect,
    });

    // Phone numbers and emails are only for people who need to contact
    // members (imam, committee). Others see names only.
    const canSeeContacts = hasPermission(
      actor,
      PERMISSIONS.MEMBERS_CONTACT_READ,
    );
    return users.map((user) => {
      const member = this.toMasjidMemberResponse(user);
      if (canSeeContacts || user.id === actor.id) return member;
      return { ...member, phone: null, email: null };
    });
  }

  /**
   * Removes the signed-in user from their masjid so another masjid can add
   * them. They keep their account and history; their roles become MEMBER
   * (imam and committee roles belong to a masjid), and they no longer see any
   * masjid data until a committee adds them again.
   */
  async leaveMyMasjid(actor: AuthenticatedUser): Promise<{ left: true }> {
    const masjidId = actor.masjidId;
    if (!masjidId) {
      throw new ApiException(
        'You are not a member of any masjid',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.USER_MASJID_NOT_ASSIGNED,
      );
    }
    if (this.isPlatformAdmin(actor.roles)) {
      throw new ApiException(
        'A super admin cannot leave a masjid',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.CANNOT_LEAVE_MASJID,
      );
    }

    await this.prisma.$transaction(async (tx) => {
      // Masjid cleared and roles reset to MEMBER in one nested write.
      await tx.user.update({
        where: { id: actor.id },
        data: {
          masjidId: null,
          userRoles: {
            deleteMany: {},
            ...this.singleRole(CreateMasjidUserRoleDto.MEMBER),
          },
        },
        select: { id: true },
      });
      // If they were this masjid's imam, the masjid no longer has one.
      await tx.masjid.updateMany({
        where: { id: masjidId, imamUserId: actor.id },
        data: { imamUserId: null },
      });
      await this.audit.record(
        {
          masjidId,
          actor,
          action: AUDIT_ACTION.LEAVE,
          entity: AUDIT_ENTITY.MEMBER,
          entityId: actor.id,
          summary: `Member "${actor.fullName}" left the masjid (was ${actor.roles.join(', ')})`,
          before: { masjidId, roles: actor.roles },
          after: { masjidId: null, roles: [CreateMasjidUserRoleDto.MEMBER] },
        },
        tx,
      );
    });

    this.logger.log({
      message: 'User left masjid',
      userId: actor.id,
      masjidId,
      previousRoles: actor.roles,
    });
    return { left: true };
  }

  private assertCanLinkExistingUser(
    existing: ExistingUserByPhone,
    masjidId: string,
  ): void {
    if (existing.masjidId === masjidId) {
      throw new ApiException(
        'This person is already a member of this masjid.',
        HttpStatus.CONFLICT,
        ERROR_CODES.MASJID_USER_ALREADY_LINKED,
      );
    }
    if (existing.masjidId) {
      throw this.userInAnotherMasjid();
    }
    const roles = existing.userRoles.map((userRole) => userRole.role.name);
    if (this.isPlatformAdmin(roles)) {
      throw new ApiException(
        'This phone number belongs to a platform administrator.',
        HttpStatus.CONFLICT,
        ERROR_CODES.PHONE_ALREADY_EXISTS,
      );
    }
  }

  /** Adds a person who has no masjid (for example after leaving one) to this masjid. */
  private async linkExistingUser(params: {
    actor: AuthenticatedUser;
    existing: ExistingUserByPhone;
    masjidId: string;
    dto: CreateMasjidUserDto;
    passwordHash: string | null;
    temporaryPassword: string | null;
  }): Promise<CreatedMasjidUserResponse> {
    const { existing, masjidId, dto } = params;
    const userId = existing.id;

    let linked: CreatedMasjidUser;
    try {
      linked = await this.prisma.$transaction(async (tx) => {
        // `masjidId: null` in the where: if another masjid linked them in
        // the meantime, nothing matches (P2025) and nothing is changed.
        const user = await tx.user.update({
          where: { id: userId, masjidId: null },
          data: {
            masjidId,
            status: UserStatus.ACTIVE,
            isFamilyHead: this.isFamilyHeadFor(dto),
            familyMemberCount: dto.familyMemberCount ?? null,
            // Imams and committee members need a password they know.
            ...(params.passwordHash
              ? { passwordHash: params.passwordHash }
              : {}),
            userRoles: { deleteMany: {}, ...this.singleRole(dto.role) },
          },
          select: masjidUserCreateSelect,
        });
        if (dto.role === CreateMasjidUserRoleDto.IMAM) {
          await tx.masjid.update({
            where: { id: masjidId },
            data: { imamUserId: userId },
            select: { id: true },
          });
        }
        await this.audit.record(
          {
            masjidId,
            actor: params.actor,
            action: AUDIT_ACTION.JOIN,
            entity: AUDIT_ENTITY.MEMBER,
            entityId: userId,
            summary: `Existing user "${user.fullName}" joined as ${dto.role}`,
            before: existing,
            after: user,
          },
          tx,
        );
        return user;
      });
    } catch (error) {
      if (isPrismaError(error, 'P2025')) throw this.userInAnotherMasjid();
      throw error;
    }

    const response = this.toCreatedMasjidUserResponse(
      linked,
      params.temporaryPassword,
    );
    this.logger.log({
      message: 'Existing user added to masjid',
      userId,
      masjidId,
      role: dto.role,
    });
    return response;
  }

  private async ensureCanManageTargetUser(
    actor: AuthenticatedUser,
    userId: string,
  ): Promise<MasjidMember> {
    const callerRoles = actor.roles;
    const isPlatformAdmin = this.isPlatformAdmin(callerRoles);

    // Not requireMasjidId: a caller without a masjid gets FORBIDDEN, not
    // USER_MASJID_NOT_ASSIGNED, and no query is made.
    if (!isPlatformAdmin && !actor.masjidId) {
      throw new ApiException(
        'You are not allowed to manage this user',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.FORBIDDEN,
      );
    }

    // Scoped lookup: a user of another masjid is simply not found here.
    const target = await this.prisma.user.findFirst({
      where: isPlatformAdmin
        ? { id: userId }
        : { id: userId, masjidId: actor.masjidId },
      select: masjidMemberSelect,
    });

    if (!target) throw this.masjidUserNotFound();

    if (isPlatformAdmin) return target;

    const targetRoles = target.userRoles.map((userRole) => userRole.role.name);
    const isOnlyMember =
      targetRoles.includes('MEMBER') &&
      targetRoles.every((role) => role === 'MEMBER');
    // Committee members manage villagers (MEMBER role) only; imams and
    // committee members are appointed by the super admin.
    if (
      !hasPermission({ roles: callerRoles }, PERMISSIONS.MEMBERS_MANAGE) ||
      !isOnlyMember
    ) {
      throw new ApiException(
        'You are not allowed to manage this user',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.FORBIDDEN,
      );
    }

    return target;
  }

  private assertCanCreateRole(
    callerRoles: string[],
    targetRole: CreateMasjidUserRoleDto,
  ): void {
    const allowedRoles = this.getAllowedCreatableRoles(callerRoles);

    if (!allowedRoles.includes(targetRole)) {
      throw new ApiException(
        'You are not allowed to add this role',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.INVALID_ROLE_FOR_CREATION,
      );
    }
  }

  private getAllowedCreatableRoles(
    callerRoles: string[],
  ): CreateMasjidUserRoleDto[] {
    if (this.isPlatformAdmin(callerRoles)) {
      return [
        CreateMasjidUserRoleDto.IMAM,
        CreateMasjidUserRoleDto.COMMITTEE_MEMBER,
        CreateMasjidUserRoleDto.MEMBER,
      ];
    }

    if (hasPermission({ roles: callerRoles }, PERMISSIONS.MEMBERS_MANAGE)) {
      return [CreateMasjidUserRoleDto.MEMBER];
    }

    return [];
  }

  /** Super admin: may act on any masjid and appoint imams/committee members. */
  private isPlatformAdmin(callerRoles: string[]): boolean {
    return hasPermission(
      { roles: callerRoles },
      PERMISSIONS.PLATFORM_ROLES_ASSIGN,
    );
  }

  /** A super admin may pick the masjid in the body; otherwise their own. */
  private resolveTargetMasjidId(
    callerRoles: string[],
    actor: AuthenticatedUser,
    dto: CreateMasjidUserDto,
  ): string {
    const masjidId = this.isPlatformAdmin(callerRoles)
      ? (dto.masjidId ?? actor.masjidId)
      : actor.masjidId;

    return requireMasjidId({ masjidId: masjidId ?? null });
  }

  private assertProfileFields(
    role: CreateMasjidUserRoleDto,
    isFamilyHead: boolean | undefined,
  ): void {
    if (role === CreateMasjidUserRoleDto.MEMBER && isFamilyHead === undefined) {
      throw new ApiException(
        'Is family head is required for member users',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }
  }

  private requiresTemporaryPassword(role: CreateMasjidUserRoleDto): boolean {
    return (
      role === CreateMasjidUserRoleDto.IMAM ||
      role === CreateMasjidUserRoleDto.COMMITTEE_MEMBER
    );
  }

  /** Members must say whether they head a family (checked by assertProfileFields). */
  private isFamilyHeadFor(dto: CreateMasjidUserDto): boolean {
    return dto.role === CreateMasjidUserRoleDto.MEMBER
      ? dto.isFamilyHead!
      : (dto.isFamilyHead ?? false);
  }

  /**
   * Nested write that gives a user exactly this role, connected by its
   * unique name (no separate role lookup). Pair with `deleteMany: {}` on
   * update to replace existing roles.
   */
  private singleRole(role: CreateMasjidUserRoleDto) {
    return {
      create: { role: { connect: { name: role as RoleName } } },
    } satisfies Prisma.UserRoleCreateNestedManyWithoutUserInput &
      Prisma.UserRoleUpdateManyWithoutUserNestedInput;
  }

  private masjidNotFound(): ApiException {
    return new ApiException(
      'Masjid not found',
      HttpStatus.NOT_FOUND,
      ERROR_CODES.MASJID_NOT_FOUND,
    );
  }

  private masjidUserNotFound(): ApiException {
    return new ApiException(
      'Masjid user not found',
      HttpStatus.NOT_FOUND,
      ERROR_CODES.MASJID_USER_NOT_FOUND,
    );
  }

  private userInAnotherMasjid(): ApiException {
    return new ApiException(
      'This person is already a member of another masjid. Ask them to leave that masjid from the app first, then add them again.',
      HttpStatus.CONFLICT,
      ERROR_CODES.USER_IN_ANOTHER_MASJID,
    );
  }

  private toCreatedMasjidUserResponse(
    user: CreatedMasjidUser,
    temporaryPassword: string | null,
  ): CreatedMasjidUserResponse {
    const response: CreatedMasjidUserResponse = {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      fatherName: user.fatherName ?? null,
      age: user.age ?? null,
      gender: user.gender ?? null,
      isFamilyHead: user.isFamilyHead ?? false,
      familyMemberCount: user.familyMemberCount ?? null,
      status: user.status,
      masjidId: user.masjidId ?? '',
      roles: user.userRoles.map((userRole) => userRole.role.name),
    };
    if (temporaryPassword) {
      response.temporaryPassword = temporaryPassword;
      response.message = `Initial password is ${temporaryPassword}. Ask the user to change it after first login.`;
    }
    return response;
  }

  private toMasjidMemberResponse(user: MasjidMember): MasjidMemberResponse {
    return {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      fatherName: user.fatherName ?? null,
      age: user.age ?? null,
      gender: user.gender ?? null,
      isFamilyHead: user.isFamilyHead ?? false,
      familyMemberCount: user.familyMemberCount ?? null,
      status: user.status,
      masjidId: user.masjidId ?? '',
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      roles: user.userRoles.map((userRole) => userRole.role.name),
    };
  }
}

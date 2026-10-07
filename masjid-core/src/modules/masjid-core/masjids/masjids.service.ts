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
import { MasjidStatus, UserStatus } from '../../../generated/prisma/enums';
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

    if (!masjid) {
      throw new ApiException(
        'Masjid not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.MASJID_NOT_FOUND,
      );
    }

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
    } catch {
      throw new ApiException(
        'Masjid not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.MASJID_NOT_FOUND,
      );
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

    const masjidId = this.resolveTargetMasjidId(callerRoles, actor, dto);
    const masjid = await this.prisma.masjid.findUnique({
      where: { id: masjidId },
      select: { id: true, status: true },
    });

    if (!masjid) {
      throw new ApiException(
        'Masjid not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.MASJID_NOT_FOUND,
      );
    }

    if (masjid.status !== MasjidStatus.APPROVED) {
      throw new ApiException(
        'Masjid is not approved',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.MASJID_NOT_APPROVED,
      );
    }

    this.assertProfileFields(dto.role, dto.isFamilyHead);

    const phone = normalizePhone(dto.phone);
    const email = dto.email?.trim().toLowerCase() || null;

    // One person = one phone number = one masjid at a time.
    const existingByPhone = await this.prisma.user.findFirst({
      where: { phone: { in: getPhoneSearchVariants(phone) } },
      select: existingUserByPhoneSelect,
    });

    if (existingByPhone) {
      this.assertCanLinkExistingUser(existingByPhone, masjidId);
    }

    if (email && !existingByPhone) {
      const existingByEmail = await this.prisma.user.findUnique({
        where: { email },
        select: { id: true },
      });

      if (existingByEmail) {
        throw new ApiException(
          'Email already exists',
          HttpStatus.CONFLICT,
          ERROR_CODES.EMAIL_ALREADY_EXISTS,
        );
      }
    }

    const role = await this.prisma.role.findUnique({
      where: { name: dto.role },
      select: { id: true, name: true },
    });

    if (!role) {
      throw new ApiException(
        'Role not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.ROLE_NOT_FOUND,
      );
    }

    // Imams and committee members log in with a password; members use OTP only
    // and get an unguessable password they never need.
    const initial = this.requiresTemporaryPassword(dto.role)
      ? initialPasswordFor(this.config)
      : null;
    const temporaryPassword = initial?.disclosable ? initial.password : null;
    const passwordHash = await bcrypt.hash(
      initial?.password ?? randomBytes(32).toString('hex'),
      BCRYPT_ROUNDS,
    );

    if (existingByPhone) {
      return this.linkExistingUser({
        actor,
        existing: existingByPhone,
        userId: existingByPhone.id,
        masjidId,
        dto,
        roleId: role.id,
        passwordHash: initial ? passwordHash : null,
        temporaryPassword,
      });
    }

    const createdUser = await this.prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
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
        },
        select: { id: true },
      });

      await tx.userRole.create({
        data: { userId: user.id, roleId: role.id },
      });

      if (dto.role === CreateMasjidUserRoleDto.IMAM) {
        // Replacing imamUserId is allowed here; the previous imam user is not deleted.
        await tx.masjid.update({
          where: { id: masjidId },
          data: { imamUserId: user.id },
          select: { id: true },
        });
      }

      const created = await tx.user.findUnique({
        where: { id: user.id },
        select: masjidUserCreateSelect,
      });
      await this.audit.record(
        {
          masjidId,
          actor,
          action: AUDIT_ACTION.CREATE,
          entity: AUDIT_ENTITY.MEMBER,
          entityId: user.id,
          summary: `Member "${dto.fullName.trim()}" added as ${dto.role}`,
          after: created,
        },
        tx,
      );
      return created;
    });

    const response = this.toCreatedMasjidUserResponse(
      this.requireMasjidUser(createdUser),
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
    const target = await this.ensureCanManageTargetUser(actor, userId);

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

    const phone = normalizePhone(dto.phone);
    const duplicatePhone = await this.prisma.user.findFirst({
      where: {
        phone: { in: getPhoneSearchVariants(phone) },
        NOT: { id: target.id },
      },
      select: { id: true },
    });
    if (duplicatePhone) {
      throw new ApiException(
        'Phone number already exists',
        HttpStatus.CONFLICT,
        ERROR_CODES.PHONE_ALREADY_EXISTS,
      );
    }

    // Omitted email: left unchanged. Empty email: cleared.
    const email =
      dto.email === undefined
        ? undefined
        : dto.email?.trim().toLowerCase() || null;
    if (email) {
      const duplicateEmail = await this.prisma.user.findFirst({
        where: { email, NOT: { id: target.id } },
        select: { id: true },
      });
      if (duplicateEmail) {
        throw new ApiException(
          'Email already exists',
          HttpStatus.CONFLICT,
          ERROR_CODES.EMAIL_ALREADY_EXISTS,
        );
      }
    }

    const updated = await this.prisma.$transaction(async (tx) => {
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
          before: target,
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

    const memberRole = await this.prisma.role.findUnique({
      where: { name: CreateMasjidUserRoleDto.MEMBER },
      select: { id: true },
    });
    if (!memberRole) {
      throw new ApiException(
        'Role not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.ROLE_NOT_FOUND,
      );
    }

    await this.prisma.$transaction(async (tx) => {
      await tx.user.update({
        where: { id: actor.id },
        data: { masjidId: null },
      });
      await tx.userRole.deleteMany({ where: { userId: actor.id } });
      await tx.userRole.create({
        data: { userId: actor.id, roleId: memberRole.id },
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
      throw new ApiException(
        'This person is already a member of another masjid. Ask them to leave that masjid from the app first, then add them again.',
        HttpStatus.CONFLICT,
        ERROR_CODES.USER_IN_ANOTHER_MASJID,
      );
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
    userId: string;
    masjidId: string;
    dto: CreateMasjidUserDto;
    roleId: string;
    passwordHash: string | null;
    temporaryPassword: string | null;
  }): Promise<CreatedMasjidUserResponse> {
    const { userId, masjidId, dto, roleId } = params;

    const linked = await this.prisma.$transaction(async (tx) => {
      await tx.user.update({
        where: { id: userId },
        data: {
          masjidId,
          status: UserStatus.ACTIVE,
          isFamilyHead: this.isFamilyHeadFor(dto),
          familyMemberCount: dto.familyMemberCount ?? null,
          // Imams and committee members need a password they know.
          ...(params.passwordHash ? { passwordHash: params.passwordHash } : {}),
        },
      });
      await tx.userRole.deleteMany({ where: { userId } });
      await tx.userRole.create({ data: { userId, roleId } });
      if (dto.role === CreateMasjidUserRoleDto.IMAM) {
        await tx.masjid.update({
          where: { id: masjidId },
          data: { imamUserId: userId },
          select: { id: true },
        });
      }
      const user = await tx.user.findUnique({
        where: { id: userId },
        select: masjidUserCreateSelect,
      });
      await this.audit.record(
        {
          masjidId,
          actor: params.actor,
          action: AUDIT_ACTION.JOIN,
          entity: AUDIT_ENTITY.MEMBER,
          entityId: userId,
          summary: `Existing user "${user?.fullName ?? dto.fullName.trim()}" joined as ${dto.role}`,
          before: params.existing,
          after: user,
        },
        tx,
      );
      return user;
    });

    const response = this.toCreatedMasjidUserResponse(
      this.requireMasjidUser(linked),
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
    const target = await this.prisma.user.findUnique({
      where: { id: userId },
      select: masjidMemberSelect,
    });

    if (!target) {
      throw new ApiException(
        'Masjid user not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.MASJID_USER_NOT_FOUND,
      );
    }

    if (this.isPlatformAdmin(callerRoles)) return target;

    // Not requireMasjidId/assertSameMasjid: a caller without a masjid gets
    // this same FORBIDDEN response, not USER_MASJID_NOT_ASSIGNED.
    if (!actor.masjidId || target.masjidId !== actor.masjidId) {
      throw new ApiException(
        'You are not allowed to manage this user',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.FORBIDDEN,
      );
    }

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

  /** A super admin without a masjid of their own picks one in the body. */
  private resolveTargetMasjidId(
    callerRoles: string[],
    actor: AuthenticatedUser,
    dto: CreateMasjidUserDto,
  ): string {
    const masjidId = this.isPlatformAdmin(callerRoles)
      ? (actor.masjidId ?? dto.masjidId)
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

  private requireMasjidUser(user: CreatedMasjidUser | null): CreatedMasjidUser {
    if (!user) {
      throw new ApiException(
        'Masjid user not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.MASJID_USER_NOT_FOUND,
      );
    }
    return user;
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

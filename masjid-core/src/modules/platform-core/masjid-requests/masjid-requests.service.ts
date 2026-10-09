import { Logger, HttpStatus, Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { randomUUID } from 'node:crypto';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { successResponse } from '../../../common/helpers/api-response.helper';
import {
  getPhoneSearchVariants,
  isValidNormalizedPhone,
  normalizePhone,
} from '../../../common/utils/phone.util';
import { Prisma } from '../../../generated/prisma/client';
import {
  Gender,
  MasjidRegistrationStatus,
  MasjidStatus,
  RoleName,
  UserStatus,
} from '../../../generated/prisma/enums';
import {
  AUDIT_ACTION,
  AUDIT_ENTITY,
  AuditService,
} from '../../../common/audit/audit.service';
import { PrismaService } from '../../../prisma/prisma.service';
import { AppConfig } from '../../../config/app-config';
import { BCRYPT_ROUNDS } from '../auth/auth.service';
import { initialPasswordFor } from '../auth/initial-password';
import { AuthenticatedUser } from '../auth/types/jwt-payload.type';
import { RolesService } from '../roles/roles.service';
import {
  CommitteeMemberDto,
  CreateMasjidRequestDto,
} from './dto/create-masjid-request.dto';
import { GetMasjidRequestsQueryDto } from './dto/get-masjid-requests-query.dto';
import {
  MasjidRequestStatusActionDto,
  UpdateMasjidRequestStatusDto,
} from './dto/update-masjid-request-status.dto';
import {
  createdMasjidSelect,
  MasjidRequestRecord,
  masjidRequestSelect,
  masjidRequestTrackingSelect,
  RequestUser,
  requestUserSelect,
} from './masjid-requests.selects';
import { pageArgs, paged } from '../../../common/pagination';

/** Committee member as stored in the request's committeeMembers JSON. */
type CommitteeMember = {
  name?: string;
  phone?: string;
  fatherName?: string;
  age?: number;
  gender?: Gender;
};

/** Either the PrismaService or the client of an open transaction. */
type Db = Prisma.TransactionClient;

/** A user to create on approval; the id is chosen up front. */
type NewUser = {
  id: string;
  fullName: string;
  email: string | null;
  phone: string | null;
  fatherName: string | null;
  age: number | null;
  gender: Gender | null;
};

/** Who gets which role in the approved masjid. */
type ApprovalPlan = {
  imamUserId: string;
  newUsers: NewUser[];
  /** Every linked user (new and existing) with the role they receive. */
  links: Array<{ userId: string; role: RoleName }>;
};

/** At most this many applications are returned by the public lookup. */
const TRACK_LIMIT = 20;

const insensitiveContains = (value: string) => ({
  contains: value,
  mode: Prisma.QueryMode.insensitive,
});

@Injectable()
export class MasjidRequestsService {
  private readonly logger = new Logger(MasjidRequestsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: AppConfig,
    private readonly audit: AuditService,
    private readonly roles: RolesService,
  ) {}

  async create(dto: CreateMasjidRequestDto): Promise<MasjidRequestRecord> {
    const imamName = dto.imamName ?? dto.imam?.name;
    const imamPhone = dto.imamPhone ?? dto.imam?.phone;
    const imamEmail = dto.imamEmail ?? dto.imam?.email;
    if (this.isIndia(dto.country) && !this.nullableString(dto.district)) {
      throw new ApiException(
        'District is required for India',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }
    const committeeMembers = this.normalizeCommitteeMembers(
      dto.committeeMembers,
    );
    this.assertDistinctImamAndCommitteePhones(
      normalizePhone(imamPhone),
      committeeMembers,
    );
    await this.assertPhonesFreeForRequest([
      { name: imamName.trim(), phone: normalizePhone(imamPhone) },
      ...committeeMembers.map((member) => ({
        name: member.name ?? '',
        phone: member.phone ?? '',
      })),
    ]);

    const masjidName = dto.masjidName.trim();
    this.logger.debug({
      message: 'Masjid request submission started',
      masjidName,
    });
    const request = await this.prisma.masjidRegistrationRequest.create({
      data: {
        requesterName: dto.requesterName.trim(),
        requesterPhone: normalizePhone(dto.requesterPhone),
        requesterEmail: this.nullableEmail(dto.requesterEmail),
        masjidName,
        country: dto.country.trim(),
        locality: dto.locality.trim(),
        district: this.isIndia(dto.country)
          ? dto.district!.trim()
          : this.nullableString(dto.district),
        state: dto.state.trim(),
        address: dto.address.trim(),
        contactNo: this.normalizeNullablePhone(dto.contactNo),
        description: this.nullableString(dto.description),
        welcomeMsg: this.nullableString(dto.welcomeMsg),
        imamName: imamName.trim(),
        imamEmail: this.nullableEmail(imamEmail),
        imamPhone: normalizePhone(imamPhone),
        imamAddress: dto.imamAddress.trim(),
        imamFatherName: dto.imamFatherName.trim(),
        imamAge: dto.imamAge,
        imamGender: dto.imamGender,
        committeeMembers,
        requestedById: null,
        status: MasjidRegistrationStatus.PENDING,
      },
      select: masjidRequestSelect,
    });
    this.logger.log({
      message: 'Masjid request submitted',
      masjidRequestId: request.id,
    });
    return request;
  }

  async findAll(query: GetMasjidRequestsQueryDto) {
    const { page, limit, skip, take } = pageArgs(query);
    const where = this.buildWhere(query);
    const [items, total] = await Promise.all([
      this.prisma.masjidRegistrationRequest.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        select: masjidRequestSelect,
      }),
      this.prisma.masjidRegistrationRequest.count({ where }),
    ]);

    return paged(items, total, page, limit);
  }

  /** One request, same shape as a list item. */
  findOne(id: string): Promise<MasjidRequestRecord> {
    return this.findByIdOrThrow(id, this.prisma);
  }

  /** Newest TRACK_LIMIT applications for the phone; not paged. */
  async trackByRequesterPhone(requesterPhone: string) {
    const normalizedPhone = normalizePhone(requesterPhone);

    if (!isValidNormalizedPhone(normalizedPhone)) {
      throw new ApiException(
        'Enter a valid phone number',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }

    const items = await this.prisma.masjidRegistrationRequest.findMany({
      where: {
        requesterPhone: { in: getPhoneSearchVariants(normalizedPhone) },
      },
      orderBy: { createdAt: 'desc' },
      take: TRACK_LIMIT,
      select: masjidRequestTrackingSelect,
    });

    const responseItems = items.map((request) => ({
      masjidName: request.masjidName,
      status: request.status,
      imamName: request.imamName,
      requestedAt: request.createdAt,
      reviewedAt: request.reviewedAt,
    }));

    return successResponse(
      responseItems.length
        ? 'Applications fetched successfully'
        : 'No application found for this phone number',
      { items: responseItems },
    );
  }

  async updateStatus(
    id: string,
    dto: UpdateMasjidRequestStatusDto,
    actor: AuthenticatedUser,
  ): Promise<MasjidRequestRecord> {
    if (
      dto.status === MasjidRequestStatusActionDto.REJECTED &&
      !this.nullableString(dto.reason)
    ) {
      throw new ApiException(
        'Reason is required when rejecting a masjid request',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }

    if (dto.status === MasjidRequestStatusActionDto.REJECTED) {
      return this.reject(id, dto, actor);
    }

    return this.approve(id, actor);
  }

  /**
   * Creates the masjid, finds or creates the imam and committee members,
   * links them to the masjid and gives them their role.
   *
   * Users are looked up with one query and passwords hashed before the
   * transaction; inside it the request is first moved PENDING -> APPROVED
   * with a conditional update, so two parallel approvals cannot both run.
   * The number of queries does not grow with the committee size.
   */
  private async approve(
    id: string,
    actor: AuthenticatedUser,
  ): Promise<MasjidRequestRecord> {
    this.logger.debug({
      message: 'Masjid request approval started',
      masjidRequestId: id,
      actorId: actor.id,
    });
    const request = await this.findByIdOrThrow(id, this.prisma);
    this.assertPending(request, 'approve');

    const plan = await this.planApproval(request);
    const [roleIds, passwordHashes] = await Promise.all([
      this.roles.validateRoleNames([RoleName.IMAM, RoleName.COMMITTEE_MEMBER]),
      this.hashInitialPasswords(plan.newUsers.length),
    ]);
    const roleIdByName = new Map(roleIds.map((role) => [role.name, role.id]));

    const approvedRequest = await this.prisma.$transaction(async (tx) => {
      const now = new Date();
      await this.claimPending(
        tx,
        id,
        {
          status: MasjidRegistrationStatus.APPROVED,
          reviewedById: actor.id,
          reviewedAt: now,
          rejectionReason: null,
        },
        'approve',
      );

      if (plan.newUsers.length) {
        await tx.user.createMany({
          data: plan.newUsers.map((user, index) => ({
            ...user,
            isFamilyHead: false,
            familyMemberCount: null,
            passwordHash: passwordHashes[index],
            status: UserStatus.ACTIVE,
          })),
        });
      }

      const masjid = await tx.masjid.create({
        data: {
          name: request.masjidName,
          locality: request.locality,
          district: request.district,
          country: request.country,
          state: request.state,
          address: request.address,
          contactNo: request.contactNo,
          description: request.description,
          welcomeMsg: request.welcomeMsg,
          requestedByName: request.requesterName,
          requestedByPhone: request.requesterPhone,
          requestedByEmail: request.requesterEmail,
          imamName: request.imamName,
          imamPhone: request.imamPhone,
          imamEmail: request.imamEmail,
          imamAddress: request.imamAddress,
          createdById: actor.id,
          imamUserId: plan.imamUserId,
          status: MasjidStatus.APPROVED,
          approvedById: actor.id,
          approvedAt: now,
          rejectionReason: null,
        },
        select: createdMasjidSelect,
      });

      // Guarded on masjidId: null so a user who joined another masjid after
      // the lookup above is not moved silently.
      const userIds = Array.from(new Set(plan.links.map((l) => l.userId)));
      const linked = await tx.user.updateMany({
        where: { id: { in: userIds }, masjidId: null },
        data: { masjidId: masjid.id },
      });
      if (linked.count !== userIds.length) {
        throw new ApiException(
          'The imam or a committee member joined another masjid meanwhile. Ask them to leave that masjid from the app first, or change the request.',
          HttpStatus.CONFLICT,
          ERROR_CODES.USER_IN_ANOTHER_MASJID,
        );
      }

      await tx.userRole.createMany({
        data: plan.links.map((link) => ({
          userId: link.userId,
          roleId: roleIdByName.get(link.role)!,
        })),
        skipDuplicates: true,
      });

      const updated = await tx.masjidRegistrationRequest.update({
        where: { id },
        data: { createdMasjidId: masjid.id },
        select: masjidRequestSelect,
      });
      await this.audit.record(
        {
          masjidId: masjid.id,
          actor,
          action: AUDIT_ACTION.APPROVE,
          entity: AUDIT_ENTITY.MASJID_REQUEST,
          entityId: request.id,
          summary: `Masjid request "${request.masjidName}" approved`,
          before: request,
          after: updated,
        },
        tx,
      );
      return updated;
    });
    this.logger.log({
      message: 'Masjid request approved',
      masjidRequestId: approvedRequest.id,
      masjidId: approvedRequest.createdMasjidId,
      newUsers: plan.newUsers.length,
      linkedUsers: plan.links.length,
    });
    return approvedRequest;
  }

  private async reject(
    id: string,
    dto: UpdateMasjidRequestStatusDto,
    actor: AuthenticatedUser,
  ): Promise<MasjidRequestRecord> {
    const request = await this.findByIdOrThrow(id, this.prisma);
    this.assertPending(request, 'reject');

    const rejectedRequest = await this.prisma.$transaction(async (tx) => {
      await this.claimPending(
        tx,
        id,
        {
          status: MasjidRegistrationStatus.REJECTED,
          reviewedById: actor.id,
          reviewedAt: new Date(),
          rejectionReason: this.nullableString(dto.reason),
        },
        'reject',
      );
      const updated = await this.findByIdOrThrow(id, tx);
      await this.audit.record(
        {
          masjidId: null,
          actor,
          action: AUDIT_ACTION.REJECT,
          entity: AUDIT_ENTITY.MASJID_REQUEST,
          entityId: request.id,
          summary: `Masjid request "${request.masjidName}" rejected: ${updated.rejectionReason ?? ''}`,
          before: request,
          after: updated,
        },
        tx,
      );
      return updated;
    });
    this.logger.warn({
      message: 'Masjid request rejected',
      masjidRequestId: rejectedRequest.id,
    });
    return rejectedRequest;
  }

  /**
   * Moves the request out of PENDING. Only one caller can win; the others
   * get the same conflict they would have got had they come later.
   */
  private async claimPending(
    tx: Db,
    id: string,
    data: Prisma.MasjidRegistrationRequestUncheckedUpdateManyInput,
    action: 'approve' | 'reject',
  ): Promise<void> {
    const claimed = await tx.masjidRegistrationRequest.updateMany({
      where: { id, status: MasjidRegistrationStatus.PENDING },
      data,
    });
    if (claimed.count === 1) return;

    const current = await tx.masjidRegistrationRequest.findUnique({
      where: { id },
      select: { status: true },
    });
    if (!current) throw this.requestNotFound();
    this.assertPending(current, action);
    // Still PENDING means the row changed under us; report it as a conflict.
    throw new ApiException(
      'Masjid request was changed by someone else. Please reload it.',
      HttpStatus.CONFLICT,
      ERROR_CODES.CONFLICT,
    );
  }

  private assertPending(
    request: { status: MasjidRegistrationStatus },
    action: 'approve' | 'reject',
  ): void {
    if (request.status === MasjidRegistrationStatus.APPROVED) {
      throw new ApiException(
        action === 'approve'
          ? 'Masjid request is already approved'
          : 'Approved masjid request cannot be rejected',
        HttpStatus.CONFLICT,
        ERROR_CODES.MASJID_REQUEST_ALREADY_APPROVED,
      );
    }

    if (request.status === MasjidRegistrationStatus.REJECTED) {
      throw new ApiException(
        action === 'approve'
          ? 'Rejected masjid request cannot be approved'
          : 'Masjid request is already rejected',
        HttpStatus.CONFLICT,
        ERROR_CODES.MASJID_REQUEST_ALREADY_REJECTED,
      );
    }
  }

  /**
   * Decides, with one query, which people already have an account (matched
   * by phone only, never by email) and which must be created.
   */
  private async planApproval(
    request: MasjidRequestRecord,
  ): Promise<ApprovalPlan> {
    const imamName = this.nullableString(request.imamName);
    const imamPhone = this.normalizeNullablePhone(request.imamPhone);
    const imamEmail = this.nullableEmail(request.imamEmail);

    if (!imamName || !imamPhone) {
      throw new ApiException(
        'Imam name and phone are required to approve this masjid request',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }

    const committeeMembers = this.parseCommitteeMembers(
      request.committeeMembers,
    );
    if (!committeeMembers.length) {
      throw new ApiException(
        'At least one committee member is required',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }

    const phones = [
      imamPhone,
      ...committeeMembers.flatMap((member) =>
        member.phone ? [member.phone] : [],
      ),
    ];
    const existingUsers = await this.prisma.user.findMany({
      where: {
        OR: [
          { phone: { in: phones.flatMap(getPhoneSearchVariants) } },
          ...(imamEmail ? [{ email: imamEmail }] : []),
        ],
      },
      select: requestUserSelect,
    });
    const userByPhone = new Map<string, RequestUser>();
    for (const user of existingUsers) {
      if (user.phone) userByPhone.set(normalizePhone(user.phone), user);
    }

    const newUsers: NewUser[] = [];
    const newUserByPhone = new Map<string, NewUser>();
    const links: ApprovalPlan['links'] = [];

    const resolve = (
      person: Omit<NewUser, 'id'>,
      label: string,
    ): string | null => {
      const existing = person.phone ? userByPhone.get(person.phone) : null;
      if (existing) {
        this.assertHasNoMasjid(existing, label, person.phone ?? '');
        return existing.id;
      }
      const queued = person.phone ? newUserByPhone.get(person.phone) : null;
      if (queued) return queued.id;
      if (!person.fullName) return null;

      const created = { ...person, id: randomUUID() };
      newUsers.push(created);
      if (person.phone) newUserByPhone.set(person.phone, created);
      return created.id;
    };

    const imamIsNew = !userByPhone.has(imamPhone);
    if (imamIsNew && imamEmail) {
      const emailOwner = existingUsers.find((user) => user.email === imamEmail);
      if (emailOwner) {
        throw new ApiException(
          `Imam email ${imamEmail} already belongs to another account with a different phone number. Change the email on the request or the phone of that account.`,
          HttpStatus.CONFLICT,
          ERROR_CODES.EMAIL_ALREADY_EXISTS,
        );
      }
    }

    const imamUserId = resolve(
      {
        fullName: imamName,
        email: imamIsNew ? imamEmail : null,
        phone: imamPhone,
        fatherName: request.imamFatherName,
        age: request.imamAge,
        gender: request.imamGender,
      },
      'Imam',
    )!;
    links.push({ userId: imamUserId, role: RoleName.IMAM });

    for (const member of committeeMembers) {
      const fullName = this.nullableString(member.name);
      const phone = member.phone ?? null;
      if (!fullName && !phone) continue;

      const userId = resolve(
        {
          fullName: fullName ?? '',
          email: null,
          phone,
          fatherName: member.fatherName ?? null,
          age: member.age ?? null,
          gender: member.gender ?? null,
        },
        'Committee member',
      );
      if (userId) links.push({ userId, role: RoleName.COMMITTEE_MEMBER });
    }

    return { imamUserId, newUsers, links };
  }

  /**
   * Dev mode: one hash of AUTH_DEV_PASSWORD shared by everyone. Otherwise a
   * random secret per user; they set a real password through the OTP reset
   * flow (milestone M6).
   */
  private async hashInitialPasswords(count: number): Promise<string[]> {
    if (!count) return [];
    if (this.config.auth.devMode) {
      const hash = await bcrypt.hash(
        initialPasswordFor(this.config).password,
        BCRYPT_ROUNDS,
      );
      return Array.from({ length: count }, () => hash);
    }
    return Promise.all(
      Array.from({ length: count }, () =>
        bcrypt.hash(initialPasswordFor(this.config).password, BCRYPT_ROUNDS),
      ),
    );
  }

  /** Empty filters are ignored (Prisma skips undefined conditions). */
  private buildWhere(
    query: GetMasjidRequestsQueryDto,
  ): Prisma.MasjidRegistrationRequestWhereInput {
    const filter = (value: string | undefined) =>
      value ? insensitiveContains(value) : undefined;
    const search = query.search;

    return {
      id: query.id || undefined,
      status: query.status || undefined,
      masjidName: filter(query.masjidName),
      locality: filter(query.locality),
      district: filter(query.district),
      country: filter(query.country),
      state: filter(query.state),
      requesterPhone: filter(query.requesterPhone),
      OR: search
        ? [
            { masjidName: insensitiveContains(search) },
            { address: insensitiveContains(search) },
            { locality: insensitiveContains(search) },
            { district: insensitiveContains(search) },
            { state: insensitiveContains(search) },
            { country: insensitiveContains(search) },
            { contactNo: insensitiveContains(search) },
            { requesterPhone: insensitiveContains(search) },
          ]
        : undefined,
    };
  }

  private async findByIdOrThrow(
    id: string,
    db: Db,
  ): Promise<MasjidRequestRecord> {
    const request = await db.masjidRegistrationRequest.findUnique({
      where: { id },
      select: masjidRequestSelect,
    });

    if (!request) throw this.requestNotFound();
    return request;
  }

  private requestNotFound(): ApiException {
    return new ApiException(
      'Masjid request not found',
      HttpStatus.NOT_FOUND,
      ERROR_CODES.MASJID_REQUEST_NOT_FOUND,
    );
  }

  /**
   * One phone number belongs to one masjid at a time. Approval stops if the
   * imam or a committee member already belongs to a masjid, so the super
   * admin can ask them to leave it first.
   */
  private assertHasNoMasjid(
    user: { masjidId: string | null },
    label: string,
    contact: string,
  ): void {
    if (user.masjidId) {
      throw new ApiException(
        `${label} ${contact} is already a member of another masjid. Ask them to leave that masjid from the app first, or change the request.`,
        HttpStatus.CONFLICT,
        ERROR_CODES.USER_IN_ANOTHER_MASJID,
      );
    }
  }

  /**
   * Refuses a request whose imam or committee member phone already belongs
   * to a masjid, so the applicant fixes it now instead of the super admin
   * hitting it on approval. Names come from the request, never from the
   * other masjid's records.
   */
  private async assertPhonesFreeForRequest(
    people: Array<{ name: string; phone: string }>,
  ): Promise<void> {
    const taken = await this.prisma.user.findMany({
      where: {
        masjidId: { not: null },
        phone: {
          in: people.flatMap((person) => getPhoneSearchVariants(person.phone)),
        },
      },
      select: { phone: true },
    });
    const takenPhones = new Set(
      taken.flatMap((user) => (user.phone ? [normalizePhone(user.phone)] : [])),
    );
    const conflicts = people.filter((person) => takenPhones.has(person.phone));
    if (!conflicts.length) return;

    const names = conflicts.map((person) => `${person.name} (${person.phone})`);
    throw new ApiException(
      `${names.join(', ')} ${conflicts.length === 1 ? 'is' : 'are'} already registered with a different masjid. Please change the phone number.`,
      HttpStatus.CONFLICT,
      ERROR_CODES.USER_IN_ANOTHER_MASJID,
      { phones: conflicts.map((person) => person.phone) },
    );
  }

  private isIndia(country: string): boolean {
    return ['india', 'in'].includes(country.trim().toLowerCase());
  }

  private normalizeNullablePhone(value: unknown): string | null {
    const phone = typeof value === 'string' ? this.nullableString(value) : null;
    return phone ? normalizePhone(phone) : null;
  }

  private normalizeCommitteeMembers(
    committeeMembers: CommitteeMemberDto[],
  ): CommitteeMember[] {
    return committeeMembers.map((member) => ({
      name: member.name.trim(),
      phone: normalizePhone(member.phone),
      fatherName: member.fatherName?.trim(),
      age: member.age,
      gender: member.gender,
    }));
  }

  private assertDistinctImamAndCommitteePhones(
    imamPhone: string,
    committeeMembers: CommitteeMember[],
  ): void {
    const seenCommitteePhones = new Set<string>();

    for (const member of committeeMembers) {
      const phone = normalizePhone(member.phone ?? '');
      if (phone === imamPhone) {
        throw new ApiException(
          'Imam cannot also be a committee member.',
          HttpStatus.BAD_REQUEST,
          ERROR_CODES.BAD_REQUEST,
        );
      }
      if (seenCommitteePhones.has(phone)) {
        throw new ApiException(
          'Committee member mobile number is duplicated.',
          HttpStatus.BAD_REQUEST,
          ERROR_CODES.BAD_REQUEST,
        );
      }
      seenCommitteePhones.add(phone);
    }
  }

  /** Reads committee members back from the stored JSON. */
  private parseCommitteeMembers(value: unknown): CommitteeMember[] {
    if (!Array.isArray(value)) {
      return [];
    }

    return value
      .filter((member): member is Record<string, unknown> =>
        this.isRecord(member),
      )
      .map((member) => ({
        name:
          typeof member.name === 'string'
            ? (this.nullableString(member.name) ?? undefined)
            : undefined,
        phone:
          typeof member.phone === 'string'
            ? (this.normalizeNullablePhone(member.phone) ?? undefined)
            : undefined,
        fatherName:
          typeof member.fatherName === 'string'
            ? (this.nullableString(member.fatherName) ?? undefined)
            : undefined,
        age: typeof member.age === 'number' ? member.age : undefined,
        gender: Object.values(Gender).includes(member.gender as Gender)
          ? (member.gender as Gender)
          : undefined,
      }))
      .filter((member) => member.name || member.phone);
  }

  private nullableString(value?: string | null): string | null {
    if (typeof value !== 'string') {
      return null;
    }

    const trimmed = value.trim();
    return trimmed || null;
  }

  private nullableEmail(value?: string | null): string | null {
    return this.nullableString(value)?.toLowerCase() ?? null;
  }

  private isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === 'object' && value !== null && !Array.isArray(value);
  }
}

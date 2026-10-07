import { Logger, HttpStatus, Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
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
import { PrismaService } from '../../../prisma/prisma.service';
import { AppConfig } from '../../../config/app-config';
import { BCRYPT_ROUNDS } from '../auth/auth.service';
import { initialPasswordFor } from '../auth/initial-password';
import { AuthenticatedUser } from '../auth/types/jwt-payload.type';
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

    this.logger.debug({
      message: 'Masjid request submission started',
      masjidName: dto.masjidName,
    });
    const request = await this.prisma.masjidRegistrationRequest.create({
      data: {
        requesterName: dto.requesterName.trim(),
        requesterPhone: normalizePhone(dto.requesterPhone),
        requesterEmail: this.nullableEmail(dto.requesterEmail),
        masjidName: dto.masjidName,
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
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const where = this.buildWhere(query);
    const [items, total] = await Promise.all([
      this.prisma.masjidRegistrationRequest.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: masjidRequestSelect,
      }),
      this.prisma.masjidRegistrationRequest.count({ where }),
    ]);

    return {
      items,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

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
   * Creates the masjid, then finds or creates the imam and committee members
   * (one query each), links them to the masjid and gives them their role.
   * Everything happens in one transaction.
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
    const approvedRequest = await this.prisma.$transaction(async (tx) => {
      const request = await this.findByIdOrThrow(id, tx);
      this.assertCanApprove(request);

      const imamUser = await this.createOrFindImamUser(request, tx);
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
          imamUserId: imamUser.id,
          status: MasjidStatus.APPROVED,
          approvedById: actor.id,
          approvedAt: new Date(),
          rejectionReason: null,
        },
        select: createdMasjidSelect,
      });

      await this.linkUserToMasjid(imamUser.id, masjid.id, tx);
      await this.assignRoleToUser(imamUser.id, RoleName.IMAM, tx);

      await this.createOrLinkCommitteeMembers(request, masjid.id, tx);

      return tx.masjidRegistrationRequest.update({
        where: { id: request.id },
        data: {
          status: MasjidRegistrationStatus.APPROVED,
          reviewedById: actor.id,
          reviewedAt: new Date(),
          createdMasjidId: masjid.id,
          rejectionReason: null,
        },
        select: masjidRequestSelect,
      });
    });
    this.logger.log({
      message: 'Masjid request approved',
      masjidRequestId: approvedRequest.id,
      masjidId: approvedRequest.createdMasjidId,
    });
    return approvedRequest;
  }

  private async reject(
    id: string,
    dto: UpdateMasjidRequestStatusDto,
    actor: AuthenticatedUser,
  ): Promise<MasjidRequestRecord> {
    const request = await this.findByIdOrThrow(id, this.prisma);

    if (request.status === MasjidRegistrationStatus.APPROVED) {
      throw new ApiException(
        'Approved masjid request cannot be rejected',
        HttpStatus.CONFLICT,
        ERROR_CODES.MASJID_REQUEST_ALREADY_APPROVED,
      );
    }

    if (request.status === MasjidRegistrationStatus.REJECTED) {
      throw new ApiException(
        'Masjid request is already rejected',
        HttpStatus.CONFLICT,
        ERROR_CODES.MASJID_REQUEST_ALREADY_REJECTED,
      );
    }

    const rejectedRequest = await this.prisma.masjidRegistrationRequest.update({
      where: { id: request.id },
      data: {
        status: MasjidRegistrationStatus.REJECTED,
        reviewedById: actor.id,
        reviewedAt: new Date(),
        rejectionReason: this.nullableString(dto.reason),
      },
      select: masjidRequestSelect,
    });
    this.logger.warn({
      message: 'Masjid request rejected',
      masjidRequestId: rejectedRequest.id,
    });
    return rejectedRequest;
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

    if (!request) {
      throw new ApiException(
        'Masjid request not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.MASJID_REQUEST_NOT_FOUND,
      );
    }

    return request;
  }

  private assertCanApprove(request: MasjidRequestRecord): void {
    if (request.status === MasjidRegistrationStatus.APPROVED) {
      throw new ApiException(
        'Masjid request is already approved',
        HttpStatus.CONFLICT,
        ERROR_CODES.MASJID_REQUEST_ALREADY_APPROVED,
      );
    }

    if (request.status === MasjidRegistrationStatus.REJECTED) {
      throw new ApiException(
        'Rejected masjid request cannot be approved',
        HttpStatus.CONFLICT,
        ERROR_CODES.MASJID_REQUEST_ALREADY_REJECTED,
      );
    }
  }

  private async createOrFindImamUser(
    request: MasjidRequestRecord,
    db: Db,
  ): Promise<RequestUser> {
    const fullName = this.nullableString(request.imamName);
    const email = this.nullableEmail(request.imamEmail);
    const phone = this.nullableString(request.imamPhone);

    if (!fullName || !phone) {
      throw new ApiException(
        'Imam name and phone are required to approve this masjid request',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }

    const existingUser = await this.findUserByPhoneOrEmail(phone, email, db);
    if (existingUser) {
      return existingUser;
    }

    return this.createTemporaryUser(
      {
        fullName,
        email,
        phone,
        fatherName: request.imamFatherName,
        age: request.imamAge,
        gender: request.imamGender,
      },
      db,
    );
  }

  private async createOrLinkCommitteeMembers(
    request: MasjidRequestRecord,
    masjidId: string,
    db: Db,
  ): Promise<void> {
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

    for (const member of committeeMembers) {
      const fullName = this.nullableString(member.name);
      const phone = this.nullableString(member.phone);

      if (!fullName && !phone) {
        continue;
      }

      let user = phone
        ? await this.findUserByPhoneOrEmail(phone, null, db)
        : null;

      if (!user && fullName) {
        user = await this.createTemporaryUser(
          {
            fullName,
            email: null,
            phone,
            fatherName: member.fatherName ?? null,
            age: member.age ?? null,
            gender: member.gender ?? null,
          },
          db,
        );
      }

      if (!user) {
        continue;
      }

      await this.linkUserToMasjid(user.id, masjidId, db);
      await this.assignRoleToUser(user.id, RoleName.COMMITTEE_MEMBER, db);
    }
  }

  private async findUserByPhoneOrEmail(
    phone: string | null,
    email: string | null,
    db: Db,
  ): Promise<RequestUser | null> {
    if (phone) {
      const user = await db.user.findFirst({
        where: { phone: { in: getPhoneSearchVariants(phone) } },
        select: requestUserSelect,
      });

      if (user) {
        return user;
      }
    }

    if (email) {
      return db.user.findFirst({
        where: { email },
        select: requestUserSelect,
      });
    }

    return null;
  }

  private async createTemporaryUser(
    data: {
      fullName: string;
      email: string | null;
      phone: string | null;
      fatherName?: string | null;
      age?: number | null;
      gender?: Gender | null;
    },
    db: Db,
  ): Promise<RequestUser> {
    // Dev mode: AUTH_DEV_PASSWORD. Otherwise a random secret; the user sets a
    // real password through the OTP reset flow (milestone M6).
    const passwordHash = await bcrypt.hash(
      initialPasswordFor(this.config).password,
      BCRYPT_ROUNDS,
    );

    return db.user.create({
      data: {
        fullName: data.fullName,
        email: data.email,
        phone: data.phone,
        fatherName: data.fatherName ?? null,
        age: data.age ?? null,
        gender: data.gender ?? null,
        isFamilyHead: false,
        familyMemberCount: null,
        passwordHash,
        status: UserStatus.ACTIVE,
      },
      select: requestUserSelect,
    });
  }

  private async linkUserToMasjid(
    userId: string,
    masjidId: string,
    db: Db,
  ): Promise<RequestUser> {
    return db.user.update({
      where: { id: userId },
      data: { masjidId },
      select: requestUserSelect,
    });
  }

  private async assignRoleToUser(
    userId: string,
    roleName: RoleName,
    db: Db,
  ): Promise<void> {
    const role = await db.role.findFirst({
      where: { name: roleName },
      select: { id: true },
    });

    if (!role) {
      throw new ApiException(
        `${roleName} role was not found`,
        HttpStatus.NOT_FOUND,
        ERROR_CODES.ROLE_NOT_FOUND,
      );
    }

    const existingUserRole = await db.userRole.findFirst({
      where: { userId, roleId: role.id },
      select: { id: true },
    });

    if (existingUserRole) {
      return;
    }

    await db.userRole.create({
      data: { userId, roleId: role.id },
      select: { id: true },
    });
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

  /**
   * Reads name and phone back from the stored JSON. Father name, age and
   * gender are not read, so committee members created on approval get none.
   */
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

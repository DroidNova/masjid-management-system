import { HttpStatus, Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { getPhoneSearchVariants, normalizePhone } from '../../../common/utils/phone.util';
import { PrismaService } from '../../../prisma/prisma.service';
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

const MASJID_ADMIN_ROLE = 'MASJID_ADMIN';
const IMAM_ROLE = 'IMAM';
const COMMITTEE_MEMBER_ROLE = 'COMMITTEE_MEMBER';
const TEMPORARY_USER_PASSWORD = '12345678';
const BCRYPT_SALT_ROUNDS = 10;

enum MasjidRegistrationRequestStatus {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
}

enum MasjidStatus {
  APPROVED = 'APPROVED',
}

type BasicUser = {
  id: string;
  fullName: string;
  email: string | null;
  phone: string | null;
};

type RequestUser = BasicUser & {
  masjidId: string | null;
};

type CreatedMasjid = {
  id: string;
  name: string;
  status?: string;
  createdAt: Date;
};

type CommitteeMember = {
  name?: string;
  phone?: string;
};

type MasjidRequestRecord = {
  id: string;
  requestedById: string | null;
  reviewedById: string | null;
  requesterName: string | null;
  requesterPhone: string | null;
  requesterEmail: string | null;
  status: string;
  masjidName: string;
  village: string | null;
  city: string | null;
  district: string | null;
  state: string | null;
  address: string | null;
  contactNo: string | null;
  description: string | null;
  welcomeMsg: string | null;
  imamName: string | null;
  imamEmail: string | null;
  imamPhone: string | null;
  imamAddress: string | null;
  committeeMembers: unknown | null;
  rejectionReason: string | null;
  reviewedAt: Date | null;
  createdMasjidId: string | null;
  createdAt: Date;
  updatedAt: Date;
  requestedBy?: BasicUser | null;
  reviewedBy?: BasicUser | null;
  createdMasjid?: CreatedMasjid | null;
};

type RoleName =
  | typeof MASJID_ADMIN_ROLE
  | typeof IMAM_ROLE
  | typeof COMMITTEE_MEMBER_ROLE;

type RequestCreateData = {
  requestedById?: string | null;
  requesterName?: string | null;
  requesterPhone?: string | null;
  requesterEmail?: string | null;
  status: MasjidRegistrationRequestStatus;
  masjidName: string;
  village?: string | null;
  city?: string | null;
  district?: string | null;
  state?: string | null;
  address?: string | null;
  contactNo?: string | null;
  description?: string | null;
  welcomeMsg?: string | null;
  imamName?: string | null;
  imamEmail?: string | null;
  imamPhone?: string | null;
  imamAddress?: string | null;
  committeeMembers?: CommitteeMember[] | null;
};

type RequestUpdateData = {
  status?: MasjidRegistrationRequestStatus;
  reviewedById?: string | null;
  reviewedAt?: Date | null;
  rejectionReason?: string | null;
  createdMasjidId?: string | null;
};

type UserCreateData = {
  fullName: string;
  email?: string | null;
  phone?: string | null;
  passwordHash: string;
  status: string;
};

type UserUpdateData = {
  masjidId?: string | null;
};

type MasjidCreateData = {
  name: string;
  village?: string | null;
  city?: string | null;
  district?: string | null;
  state?: string | null;
  address?: string | null;
  contactNo?: string | null;
  description?: string | null;
  welcomeMsg?: string | null;
  createdById: string;
  imamUserId?: string | null;
  status?: MasjidStatus;
  approvedById?: string;
  approvedAt?: Date;
  rejectionReason?: string | null;
};

type MasjidRequestDelegate = {
  create(args: {
    data: RequestCreateData;
    select: typeof masjidRequestDetailSelect;
  }): Promise<MasjidRequestRecord>;
  findMany(args: {
    where: Record<string, unknown>;
    skip?: number;
    take?: number;
    orderBy: { createdAt: 'desc' };
    select: typeof masjidRequestListSelect;
  }): Promise<MasjidRequestRecord[]>;
  count(args: { where: Record<string, unknown> }): Promise<number>;
  findUnique(args: {
    where: { id: string };
    select: typeof masjidRequestDetailSelect;
  }): Promise<MasjidRequestRecord | null>;
  update(args: {
    where: { id: string };
    data: RequestUpdateData;
    select: typeof masjidRequestDetailSelect;
  }): Promise<MasjidRequestRecord>;
};

type UserDelegate = {
  findUnique(args: {
    where: { id: string };
    select: typeof requestUserSelect;
  }): Promise<RequestUser | null>;
  findFirst(args: {
    where: Record<string, unknown>;
    select: typeof requestUserSelect;
  }): Promise<RequestUser | null>;
  create(args: {
    data: UserCreateData;
    select: typeof requestUserSelect;
  }): Promise<RequestUser>;
  update(args: {
    where: { id: string };
    data: UserUpdateData;
    select: typeof requestUserSelect;
  }): Promise<RequestUser>;
};

type RoleDelegate = {
  findFirst(args: {
    where: { name: string };
    select: { id: true };
  }): Promise<{ id: string } | null>;
};

type UserRoleDelegate = {
  findFirst(args: {
    where: { userId: string; roleId: string };
    select: { id: true };
  }): Promise<{ id: string } | null>;
  create(args: {
    data: { userId: string; roleId: string };
    select: { id: true };
  }): Promise<{ id: string }>;
};

type MasjidDelegate = {
  create(args: {
    data: MasjidCreateData;
    select: typeof createdMasjidSelect;
  }): Promise<CreatedMasjid>;
};

type MasjidRequestsPrismaDelegate = {
  masjidRegistrationRequest: MasjidRequestDelegate;
  user: UserDelegate;
  role: RoleDelegate;
  userRole: UserRoleDelegate;
  masjid: MasjidDelegate;
  $transaction<T>(
    callback: (tx: MasjidRequestsPrismaDelegate) => Promise<T>,
  ): Promise<T>;
};

const basicUserSelect = {
  id: true,
  fullName: true,
  email: true,
  phone: true,
} as const;

const requestUserSelect = {
  ...basicUserSelect,
  masjidId: true,
} as const;

const createdMasjidSelect = {
  id: true,
  name: true,
  status: true,
  createdAt: true,
} as const;

const masjidRequestListSelect = {
  id: true,
  requestedById: true,
  reviewedById: true,
  requesterName: true,
  requesterPhone: true,
  requesterEmail: true,
  status: true,
  masjidName: true,
  village: true,
  city: true,
  district: true,
  state: true,
  address: true,
  contactNo: true,
  description: true,
  welcomeMsg: true,
  imamName: true,
  imamEmail: true,
  imamPhone: true,
  imamAddress: true,
  committeeMembers: true,
  rejectionReason: true,
  reviewedAt: true,
  createdMasjidId: true,
  createdAt: true,
  updatedAt: true,
  requestedBy: { select: basicUserSelect },
  reviewedBy: { select: basicUserSelect },
  createdMasjid: { select: createdMasjidSelect },
} as const;

const masjidRequestDetailSelect = {
  ...masjidRequestListSelect,
} as const;

@Injectable()
export class MasjidRequestsService {
  constructor(private readonly prisma: PrismaService) {}

  private get db(): MasjidRequestsPrismaDelegate {
    return this.prisma as unknown as MasjidRequestsPrismaDelegate;
  }

  async create(dto: CreateMasjidRequestDto): Promise<MasjidRequestRecord> {
    return this.db.masjidRegistrationRequest.create({
      data: {
        requesterName: this.nullableString(dto.requesterName),
        requesterPhone: this.normalizeNullablePhone(dto.requesterPhone),
        requesterEmail: this.nullableEmail(dto.requesterEmail),
        masjidName: dto.masjidName,
        village: this.nullableString(dto.village),
        city: this.nullableString(dto.city),
        district: this.nullableString(dto.district),
        state: this.nullableString(dto.state),
        address: this.nullableString(dto.address),
        contactNo: this.normalizeNullablePhone(dto.contactNo),
        description: this.nullableString(dto.description),
        welcomeMsg: this.nullableString(dto.welcomeMsg),
        imamName: this.nullableString(dto.imam?.name),
        imamEmail: this.nullableEmail(dto.imam?.email),
        imamPhone: this.normalizeNullablePhone(dto.imam?.phone),
        imamAddress: this.nullableString(dto.imam?.address),
        committeeMembers: this.toCommitteeMembersJson(dto.committeeMembers),
        requestedById: null,
        status: MasjidRegistrationRequestStatus.PENDING,
      },
      select: masjidRequestDetailSelect,
    });
  }

  async findAll(query: GetMasjidRequestsQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const where = this.buildWhere(query);
    const [items, total] = await Promise.all([
      this.db.masjidRegistrationRequest.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: masjidRequestListSelect,
      }),
      this.db.masjidRegistrationRequest.count({ where }),
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

  private async approve(
    id: string,
    actor: AuthenticatedUser,
  ): Promise<MasjidRequestRecord> {
    return this.db.$transaction(async (tx) => {
      const request = await this.findByIdOrThrow(id, tx);
      this.assertCanApprove(request);

      const requesterUser = await this.resolveRequesterAdminUser(request, tx);
      const imamUser = await this.createOrFindImamUser(request, tx);
      const masjid = await tx.masjid.create({
        data: {
          name: request.masjidName,
          village: request.village,
          city: request.city,
          district: request.district,
          state: request.state,
          address: request.address,
          contactNo: request.contactNo,
          description: request.description,
          welcomeMsg: request.welcomeMsg,
          createdById: requesterUser.id,
          imamUserId: imamUser?.id ?? null,
          status: MasjidStatus.APPROVED,
          approvedById: actor.id,
          approvedAt: new Date(),
          rejectionReason: null,
        },
        select: createdMasjidSelect,
      });

      await this.linkUserToMasjid(requesterUser.id, masjid.id, tx);
      await this.assignRoleToUser(requesterUser.id, MASJID_ADMIN_ROLE, tx);

      if (imamUser) {
        await this.linkUserToMasjid(imamUser.id, masjid.id, tx);
        await this.assignRoleToUser(imamUser.id, IMAM_ROLE, tx);
      }

      await this.createOrLinkCommitteeMembers(request, masjid.id, tx);

      return tx.masjidRegistrationRequest.update({
        where: { id: request.id },
        data: {
          status: MasjidRegistrationRequestStatus.APPROVED,
          reviewedById: actor.id,
          reviewedAt: new Date(),
          createdMasjidId: masjid.id,
          rejectionReason: null,
        },
        select: masjidRequestDetailSelect,
      });
    });
  }

  private async reject(
    id: string,
    dto: UpdateMasjidRequestStatusDto,
    actor: AuthenticatedUser,
  ): Promise<MasjidRequestRecord> {
    const request = await this.findByIdOrThrow(id, this.db);

    if (request.status === MasjidRegistrationRequestStatus.APPROVED) {
      throw new ApiException(
        'Approved masjid request cannot be rejected',
        HttpStatus.CONFLICT,
        ERROR_CODES.MASJID_REQUEST_ALREADY_APPROVED,
      );
    }

    if (request.status === MasjidRegistrationRequestStatus.REJECTED) {
      throw new ApiException(
        'Masjid request is already rejected',
        HttpStatus.CONFLICT,
        ERROR_CODES.MASJID_REQUEST_ALREADY_REJECTED,
      );
    }

    return this.db.masjidRegistrationRequest.update({
      where: { id: request.id },
      data: {
        status: MasjidRegistrationRequestStatus.REJECTED,
        reviewedById: actor.id,
        reviewedAt: new Date(),
        rejectionReason: this.nullableString(dto.reason),
      },
      select: masjidRequestDetailSelect,
    });
  }

  private buildWhere(
    query: GetMasjidRequestsQueryDto,
  ): Record<string, unknown> {
    const where: Record<string, unknown> = {};

    if (query.id) {
      where.id = query.id;
    }

    if (query.status) {
      where.status = query.status;
    }

    if (query.masjidName) {
      where.masjidName = {
        contains: query.masjidName,
        mode: 'insensitive',
      };
    }

    if (query.city) {
      where.city = {
        contains: query.city,
        mode: 'insensitive',
      };
    }

    if (query.district) {
      where.district = {
        contains: query.district,
        mode: 'insensitive',
      };
    }

    if (query.state) {
      where.state = {
        contains: query.state,
        mode: 'insensitive',
      };
    }

    if (query.requesterPhone) {
      where.requesterPhone = {
        contains: query.requesterPhone,
        mode: 'insensitive',
      };
    }

    if (query.search) {
      where.OR = [
        'masjidName',
        'city',
        'district',
        'state',
        'contactNo',
        'requesterPhone',
      ].map((field) => ({
        [field]: { contains: query.search, mode: 'insensitive' },
      }));
    }

    return where;
  }

  private async findByIdOrThrow(
    id: string,
    db: MasjidRequestsPrismaDelegate,
  ): Promise<MasjidRequestRecord> {
    const request = await db.masjidRegistrationRequest.findUnique({
      where: { id },
      select: masjidRequestDetailSelect,
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
    if (request.status === MasjidRegistrationRequestStatus.APPROVED) {
      throw new ApiException(
        'Masjid request is already approved',
        HttpStatus.CONFLICT,
        ERROR_CODES.MASJID_REQUEST_ALREADY_APPROVED,
      );
    }

    if (request.status === MasjidRegistrationRequestStatus.REJECTED) {
      throw new ApiException(
        'Rejected masjid request cannot be approved',
        HttpStatus.CONFLICT,
        ERROR_CODES.MASJID_REQUEST_ALREADY_REJECTED,
      );
    }
  }

  private async resolveRequesterAdminUser(
    request: MasjidRequestRecord,
    db: MasjidRequestsPrismaDelegate,
  ): Promise<RequestUser> {
    if (request.requestedById) {
      const requestedBy = await db.user.findUnique({
        where: { id: request.requestedById },
        select: requestUserSelect,
      });

      if (requestedBy) {
        return requestedBy;
      }
    }

    const fullName = this.nullableString(request.requesterName);
    const phone = this.nullableString(request.requesterPhone);
    const email = this.nullableEmail(request.requesterEmail);

    if (!fullName || !phone) {
      throw new ApiException(
        'Requester contact details are required to approve this masjid request',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.MASJID_REQUEST_REQUESTER_DETAILS_REQUIRED,
      );
    }

    const existingUser = await this.findUserByPhoneOrEmail(phone, email, db);

    if (existingUser) {
      return existingUser;
    }

    return this.createTemporaryUser({ fullName, email, phone }, db);
  }

  private async createOrFindImamUser(
    request: MasjidRequestRecord,
    db: MasjidRequestsPrismaDelegate,
  ): Promise<RequestUser | null> {
    const fullName = this.nullableString(request.imamName);
    const email = this.nullableEmail(request.imamEmail);
    const phone = this.nullableString(request.imamPhone);

    if (!fullName && !email && !phone) {
      return null;
    }

    const existingUser = await this.findUserByPhoneOrEmail(phone, email, db);

    if (existingUser) {
      return existingUser;
    }

    if (!fullName) {
      return null;
    }

    return this.createTemporaryUser({ fullName, email, phone }, db);
  }

  private async createOrLinkCommitteeMembers(
    request: MasjidRequestRecord,
    masjidId: string,
    db: MasjidRequestsPrismaDelegate,
  ): Promise<void> {
    const committeeMembers = this.parseCommitteeMembers(
      request.committeeMembers,
    );

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
          { fullName, email: null, phone },
          db,
        );
      }

      if (!user) {
        continue;
      }

      await this.linkUserToMasjid(user.id, masjidId, db);
      await this.assignRoleToUser(user.id, COMMITTEE_MEMBER_ROLE, db);
    }
  }

  private async findUserByPhoneOrEmail(
    phone: string | null,
    email: string | null,
    db: MasjidRequestsPrismaDelegate,
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
    data: { fullName: string; email: string | null; phone: string | null },
    db: MasjidRequestsPrismaDelegate,
  ): Promise<RequestUser> {
    // TODO: Replace temporary password with OTP/email/SMS invitation before production.
    const passwordHash = await bcrypt.hash(
      TEMPORARY_USER_PASSWORD,
      BCRYPT_SALT_ROUNDS,
    );

    return db.user.create({
      data: {
        fullName: data.fullName,
        email: data.email,
        phone: data.phone,
        passwordHash,
        status: 'ACTIVE',
      },
      select: requestUserSelect,
    });
  }

  private async linkUserToMasjid(
    userId: string,
    masjidId: string,
    db: MasjidRequestsPrismaDelegate,
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
    db: MasjidRequestsPrismaDelegate,
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


  private normalizeNullablePhone(value: unknown): string | null {
    const phone = this.nullableString(value);
    return phone ? normalizePhone(phone) : null;
  }

  private toCommitteeMembersJson(
    committeeMembers?: CommitteeMemberDto[],
  ): CommitteeMember[] | null {
    if (!committeeMembers?.length) {
      return null;
    }

    const sanitizedMembers = committeeMembers
      .map((member) => ({
        name: this.nullableString(member.name) ?? undefined,
        phone: this.normalizeNullablePhone(member.phone) ?? undefined,
      }))
      .filter((member) => member.name || member.phone);

    return sanitizedMembers.length ? sanitizedMembers : null;
  }

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

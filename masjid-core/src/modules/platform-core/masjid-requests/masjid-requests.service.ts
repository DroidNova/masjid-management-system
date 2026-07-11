import { HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { normalizePhone } from '../../../common/utils/phone.util';
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
  requesterName: string;
  requesterPhone: string;
  requesterEmail: string | null;
  status: string;
  masjidName: string;
  village: string | null;
  city: string | null;
  district: string | null;
  state: string;
  country: string;
  address: string;
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

type RequestCreateData = {
  requestedById?: string | null;
  requesterName: string;
  requesterPhone: string;
  requesterEmail?: string | null;
  status: MasjidRegistrationRequestStatus;
  masjidName: string;
  village?: string | null;
  city?: string | null;
  district?: string | null;
  state: string;
  country: string;
  address: string;
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

type MasjidCreateData = {
  name: string;
  village?: string | null;
  city?: string | null;
  district?: string | null;
  state: string;
  country: string;
  address: string;
  contactNo?: string | null;
  description?: string | null;
  welcomeMsg?: string | null;
  requestedByName: string;
  requestedByPhone: string;
  requestedByEmail?: string | null;
  createdById?: string | null;
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

type MasjidDelegate = {
  create(args: {
    data: MasjidCreateData;
    select: typeof createdMasjidSelect;
  }): Promise<CreatedMasjid>;
};

type MasjidRequestsPrismaDelegate = {
  masjidRegistrationRequest: MasjidRequestDelegate;
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
  country: true,
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
        requesterName: this.requiredString(dto.requesterName, 'Requester name'),
        requesterPhone: normalizePhone(dto.requesterPhone),
        requesterEmail: this.nullableEmail(dto.requesterEmail),
        masjidName: dto.masjidName,
        village: this.nullableString(dto.village),
        city: this.nullableString(dto.city),
        district: this.nullableString(dto.district),
        state: this.requiredString(dto.state, 'State'),
        country: this.requiredString(dto.country, 'Country'),
        address: this.requiredString(dto.address, 'Address'),
        contactNo: this.nullablePhone(dto.contactNo),
        description: this.nullableString(dto.description),
        welcomeMsg: this.nullableString(dto.welcomeMsg),
        imamName: this.nullableString(dto.imam?.name),
        imamEmail: this.nullableEmail(dto.imam?.email),
        imamPhone: this.nullablePhone(dto.imam?.phone),
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

      const now = new Date();
      const masjid = await tx.masjid.create({
        data: {
          name: request.masjidName,
          village: request.village,
          city: request.city,
          district: request.district,
          state: request.state,
          country: request.country,
          address: request.address,
          contactNo: request.contactNo,
          description: request.description,
          welcomeMsg: request.welcomeMsg,
          requestedByName: request.requesterName,
          requestedByPhone: request.requesterPhone,
          requestedByEmail: request.requesterEmail,
          createdById: null,
          imamUserId: null,
          status: MasjidStatus.APPROVED,
          approvedById: actor.id,
          approvedAt: now,
          rejectionReason: null,
        },
        select: createdMasjidSelect,
      });

      return tx.masjidRegistrationRequest.update({
        where: { id: request.id },
        data: {
          status: MasjidRegistrationRequestStatus.APPROVED,
          reviewedById: actor.id,
          reviewedAt: now,
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

  private toCommitteeMembersJson(
    committeeMembers?: CommitteeMemberDto[],
  ): CommitteeMember[] | null {
    if (!committeeMembers?.length) {
      return null;
    }

    const sanitizedMembers = committeeMembers
      .map((member) => ({
        name: this.nullableString(member.name) ?? undefined,
        phone: this.nullablePhone(member.phone) ?? undefined,
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
            ? (this.nullableString(member.phone) ?? undefined)
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


  private requiredString(value: unknown, label: string): string {
    const text = this.nullableString(value as string | null);
    if (!text) {
      throw new ApiException(
        `${label} is required`,
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }
    return text;
  }

  private nullablePhone(value: unknown): string | null {
    const text = this.nullableString(value as string | null);
    return text ? normalizePhone(text) : null;
  }

  private nullableEmail(value?: string | null): string | null {
    return this.nullableString(value)?.toLowerCase() ?? null;
  }

  private isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === 'object' && value !== null && !Array.isArray(value);
  }
}

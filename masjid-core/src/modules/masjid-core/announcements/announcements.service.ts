import { HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { getCreateAuditFields, getUpdateAuditFields } from '../../../common/utils/audit.util';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { CreateAnnouncementDto } from './dto/create-announcement.dto';
import { GetAnnouncementsQueryDto } from './dto/get-announcements-query.dto';
import { UpdateAnnouncementDto } from './dto/update-announcement.dto';

type AnnouncementRecord = {
  id: string;
  masjidId: string;
  title: string;
  message: string;
  isActive: boolean;
  createdById: string | null;
  createdByName: string | null;
  updatedById: string | null;
  updatedByName: string | null;
  createdAt: Date;
  updatedAt: Date;
};

type AnnouncementListResponse = {
  items: AnnouncementRecord[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
};

type AnnouncementWhereInput = {
  masjidId: string;
  isActive?: boolean;
  OR?: Array<{
    title?: { contains: string; mode: 'insensitive' };
    message?: { contains: string; mode: 'insensitive' };
  }>;
};

type AnnouncementCreateData = {
  masjidId: string;
  createdById?: string;
  createdByName?: string;
  title: string;
  message: string;
  isActive: boolean;
};

type AnnouncementUpdateData = Partial<{
  title: string;
  message: string;
  isActive: boolean;
}>;

type AnnouncementsAnnouncementDelegate = {
  findMany(args: {
    where: AnnouncementWhereInput;
    skip: number;
    take: number;
    orderBy: { createdAt: 'desc' };
    select: typeof announcementSelect;
  }): Promise<AnnouncementRecord[]>;
  count(args: { where: AnnouncementWhereInput }): Promise<number>;
  create(args: {
    data: AnnouncementCreateData;
    select: typeof announcementSelect;
  }): Promise<AnnouncementRecord>;
  findUnique(args: {
    where: { id: string };
    select: typeof announcementOwnershipSelect;
  }): Promise<{ id: string; masjidId: string } | null>;
  update(args: {
    where: { id: string };
    data: AnnouncementUpdateData & ReturnType<typeof getUpdateAuditFields>;
    select: typeof announcementSelect;
  }): Promise<AnnouncementRecord>;
};

type AnnouncementsPrismaDelegate = {
  announcement: AnnouncementsAnnouncementDelegate;
};

const announcementSelect = {
  id: true,
  masjidId: true,
  title: true,
  message: true,
  isActive: true,
  createdById: true,
  createdByName: true,
  updatedById: true,
  updatedByName: true,
  createdAt: true,
  updatedAt: true,
} as const;

const announcementOwnershipSelect = {
  id: true,
  masjidId: true,
} as const;

@Injectable()
export class AnnouncementsService {
  constructor(private readonly prisma: PrismaService) {}

  private get db(): AnnouncementsPrismaDelegate {
    return this.prisma as unknown as AnnouncementsPrismaDelegate;
  }

  async findMyMasjidAnnouncements(
    query: GetAnnouncementsQueryDto,
    actor: AuthenticatedUser,
  ): Promise<AnnouncementListResponse> {
    const masjidId = this.getCurrentUserMasjidId(actor);
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const where = this.buildAnnouncementWhere(masjidId, query);

    const [items, total] = await Promise.all([
      this.db.announcement.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: announcementSelect,
      }),
      this.db.announcement.count({ where }),
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

  async create(
    dto: CreateAnnouncementDto,
    actor: AuthenticatedUser,
  ): Promise<AnnouncementRecord> {
    const masjidId = this.getCurrentUserMasjidId(actor);

    return this.db.announcement.create({
      data: {
        masjidId,
        ...getCreateAuditFields(actor),
        title: dto.title,
        message: dto.message,
        isActive: dto.isActive ?? true,
      },
      select: announcementSelect,
    });
  }

  async update(
    id: string,
    dto: UpdateAnnouncementDto,
    actor: AuthenticatedUser,
  ): Promise<AnnouncementRecord> {
    const masjidId = this.getCurrentUserMasjidId(actor);
    await this.ensureAnnouncementBelongsToMasjid(id, masjidId);

    const data = this.buildUpdateData(dto);

    if (Object.keys(data).length === 0) {
      throw new ApiException(
        'At least one announcement field must be provided',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }

    return this.db.announcement.update({
      where: { id },
      data: { ...data, ...getUpdateAuditFields(actor) },
      select: announcementSelect,
    });
  }

  async deactivate(
    id: string,
    actor: AuthenticatedUser,
  ): Promise<AnnouncementRecord> {
    const masjidId = this.getCurrentUserMasjidId(actor);
    await this.ensureAnnouncementBelongsToMasjid(id, masjidId);

    return this.db.announcement.update({
      where: { id },
      data: { isActive: false, ...getUpdateAuditFields(actor) },
      select: announcementSelect,
    });
  }

  private getCurrentUserMasjidId(actor: AuthenticatedUser): string {
    if (!actor.masjidId) {
      throw new ApiException(
        'Current user is not assigned to a masjid',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.USER_MASJID_NOT_ASSIGNED,
      );
    }

    return actor.masjidId;
  }

  private async ensureAnnouncementBelongsToMasjid(
    id: string,
    masjidId: string,
  ): Promise<void> {
    const announcement = await this.db.announcement.findUnique({
      where: { id },
      select: announcementOwnershipSelect,
    });

    if (!announcement) {
      throw new ApiException(
        'Announcement not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.ANNOUNCEMENT_NOT_FOUND,
      );
    }

    if (announcement.masjidId !== masjidId) {
      throw new ApiException(
        'You are not allowed to access this announcement',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.ANNOUNCEMENT_ACCESS_FORBIDDEN,
      );
    }
  }

  private buildAnnouncementWhere(
    masjidId: string,
    query: GetAnnouncementsQueryDto,
  ): AnnouncementWhereInput {
    const where: AnnouncementWhereInput = { masjidId };

    if (query.isActive !== undefined) {
      where.isActive = query.isActive;
    }

    if (query.search) {
      where.OR = [
        { title: { contains: query.search, mode: 'insensitive' } },
        { message: { contains: query.search, mode: 'insensitive' } },
      ];
    }

    return where;
  }

  private buildUpdateData(dto: UpdateAnnouncementDto): AnnouncementUpdateData {
    const data: AnnouncementUpdateData = {};

    if (dto.title !== undefined) {
      data.title = dto.title;
    }

    if (dto.message !== undefined) {
      data.message = dto.message;
    }

    if (dto.isActive !== undefined) {
      data.isActive = dto.isActive;
    }

    return data;
  }
}

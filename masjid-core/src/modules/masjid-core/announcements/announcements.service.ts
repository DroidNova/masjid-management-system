import { Logger, HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { requireMasjidId } from '../../../common/tenant';
import { Prisma } from '../../../generated/prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { CreateAnnouncementDto } from './dto/create-announcement.dto';
import { GetAnnouncementsQueryDto } from './dto/get-announcements-query.dto';
import { UpdateAnnouncementDto } from './dto/update-announcement.dto';
import { PageMeta, pageArgs, paged } from '../../../common/pagination';
import { isPrismaError } from '../prisma-errors';

const announcementSelect = {
  id: true,
  masjidId: true,
  title: true,
  message: true,
  isActive: true,
  createdAt: true,
  updatedAt: true,
} as const satisfies Prisma.AnnouncementSelect;

type AnnouncementRecord = Prisma.AnnouncementGetPayload<{
  select: typeof announcementSelect;
}>;

type AnnouncementListResponse = {
  items: AnnouncementRecord[];
  meta: PageMeta;
};

@Injectable()
export class AnnouncementsService {
  private readonly logger = new Logger(AnnouncementsService.name);

  constructor(private readonly prisma: PrismaService) {}

  async findMyMasjidAnnouncements(
    query: GetAnnouncementsQueryDto,
    actor: AuthenticatedUser,
  ): Promise<AnnouncementListResponse> {
    const masjidId = requireMasjidId(actor);
    const { page, limit, skip, take } = pageArgs(query);
    const where = this.buildAnnouncementWhere(masjidId, query);

    const [items, total] = await Promise.all([
      this.prisma.announcement.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        select: announcementSelect,
      }),
      this.prisma.announcement.count({ where }),
    ]);

    return paged(items, total, page, limit);
  }

  /** One announcement of the signed-in user's masjid (for edit screens). */
  async findOne(id: string, actor: AuthenticatedUser) {
    const announcement = await this.prisma.announcement.findFirst({
      where: { id, masjidId: requireMasjidId(actor) },
      select: announcementSelect,
    });
    if (!announcement) throw this.notFound();
    return announcement;
  }

  async create(
    dto: CreateAnnouncementDto,
    actor: AuthenticatedUser,
  ): Promise<AnnouncementRecord> {
    const masjidId = requireMasjidId(actor);

    const announcement = await this.prisma.announcement.create({
      data: {
        masjidId,
        title: dto.title,
        message: dto.message,
        isActive: dto.isActive ?? true,
      },
      select: announcementSelect,
    });
    this.logger.log({
      message: 'Announcement created',
      announcementId: announcement.id,
      masjidId,
    });
    return announcement;
  }

  async update(
    id: string,
    dto: UpdateAnnouncementDto,
    actor: AuthenticatedUser,
  ): Promise<AnnouncementRecord> {
    const masjidId = requireMasjidId(actor);
    const data = this.buildUpdateData(dto);

    if (Object.keys(data).length === 0) {
      throw new ApiException(
        'At least one announcement field must be provided',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }

    const announcement = await this.updateScoped(id, masjidId, data);
    this.logger.log({
      message: 'Announcement updated',
      announcementId: announcement.id,
      masjidId,
    });
    return announcement;
  }

  async deactivate(
    id: string,
    actor: AuthenticatedUser,
  ): Promise<AnnouncementRecord> {
    const masjidId = requireMasjidId(actor);
    const announcement = await this.updateScoped(id, masjidId, {
      isActive: false,
    });
    this.logger.warn({
      message: 'Announcement deactivated',
      announcementId: announcement.id,
      masjidId,
    });
    return announcement;
  }

  /**
   * One UPDATE scoped to the masjid. A missing id or another masjid's id
   * matches no row (Prisma P2025) and becomes ANNOUNCEMENT_NOT_FOUND.
   */
  private async updateScoped(
    id: string,
    masjidId: string,
    data: Prisma.AnnouncementUpdateInput,
  ): Promise<AnnouncementRecord> {
    try {
      return await this.prisma.announcement.update({
        where: { id, masjidId },
        data,
        select: announcementSelect,
      });
    } catch (error) {
      if (isPrismaError(error, 'P2025')) throw this.notFound();
      throw error;
    }
  }

  private notFound(): ApiException {
    return new ApiException(
      'Announcement not found',
      HttpStatus.NOT_FOUND,
      ERROR_CODES.ANNOUNCEMENT_NOT_FOUND,
    );
  }

  private buildAnnouncementWhere(
    masjidId: string,
    query: GetAnnouncementsQueryDto,
  ): Prisma.AnnouncementWhereInput {
    const where: Prisma.AnnouncementWhereInput = { masjidId };

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

  private buildUpdateData(
    dto: UpdateAnnouncementDto,
  ): Prisma.AnnouncementUpdateInput {
    const data: Prisma.AnnouncementUpdateInput = {};

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

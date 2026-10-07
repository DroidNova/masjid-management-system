import { Logger, HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { toAmount } from '../../../common/money';
import { assertSameMasjid, requireMasjidId } from '../../../common/tenant';
import { Prisma } from '../../../generated/prisma/client';
import { FinanceEntryStatus } from '../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { CreateCollectionDto } from './dto/create-collection.dto';
import { GetCollectionsQueryDto } from './dto/get-collections-query.dto';
import { UpdateCollectionDto } from './dto/update-collection.dto';

const collectionSelect = {
  id: true,
  masjidId: true,
  type: true,
  amount: true,
  title: true,
  description: true,
  collectedAt: true,
  status: true,
  createdById: true,
  createdAt: true,
  updatedAt: true,
} as const satisfies Prisma.CollectionSelect;

type CollectionRecord = Prisma.CollectionGetPayload<{
  select: typeof collectionSelect;
}>;

type CollectionResponse = Omit<CollectionRecord, 'amount'> & { amount: number };

@Injectable()
export class CollectionsService {
  private readonly logger = new Logger(CollectionsService.name);

  constructor(private readonly prisma: PrismaService) {}

  async findMyMasjidCollections(
    query: GetCollectionsQueryDto,
    actor: AuthenticatedUser,
  ) {
    const masjidId = requireMasjidId(actor);
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const where = this.buildWhere(masjidId, query);

    const [items, total] = await Promise.all([
      this.prisma.collection.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { collectedAt: 'desc' },
        select: collectionSelect,
      }),
      this.prisma.collection.count({ where }),
    ]);

    return {
      items: items.map((item) => this.toResponse(item)),
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  }

  async create(
    dto: CreateCollectionDto,
    actor: AuthenticatedUser,
  ): Promise<CollectionResponse> {
    const masjidId = requireMasjidId(actor);
    const collection = await this.prisma.collection.create({
      data: {
        masjidId,
        createdById: actor.id,
        type: dto.type,
        amount: dto.amount,
        ...(dto.title !== undefined ? { title: dto.title } : {}),
        ...(dto.description !== undefined
          ? { description: dto.description }
          : {}),
        ...(dto.collectedAt ? { collectedAt: new Date(dto.collectedAt) } : {}),
      },
      select: collectionSelect,
    });

    this.logger.log({
      message: 'Collection created',
      collectionId: collection.id,
      masjidId,
    });
    return this.toResponse(collection);
  }

  async findOne(
    id: string,
    actor: AuthenticatedUser,
  ): Promise<CollectionResponse> {
    const masjidId = requireMasjidId(actor);
    const collection = await this.ensureCollectionBelongsToMasjid(id, masjidId);
    return this.toResponse(collection);
  }

  async update(
    id: string,
    dto: UpdateCollectionDto,
    actor: AuthenticatedUser,
  ): Promise<CollectionResponse> {
    const masjidId = requireMasjidId(actor);
    await this.ensureCollectionBelongsToMasjid(id, masjidId);
    const data = this.buildUpdateData(dto);

    if (Object.keys(data).length === 0) {
      throw new ApiException(
        'At least one collection field must be provided',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }

    const collection = await this.prisma.collection.update({
      where: { id },
      data,
      select: collectionSelect,
    });
    this.logger.log({
      message: 'Collection updated',
      collectionId: collection.id,
      masjidId,
    });
    return this.toResponse(collection);
  }

  async cancel(
    id: string,
    actor: AuthenticatedUser,
  ): Promise<CollectionResponse> {
    const masjidId = requireMasjidId(actor);
    await this.ensureCollectionBelongsToMasjid(id, masjidId);
    const collection = await this.prisma.collection.update({
      where: { id },
      data: { status: FinanceEntryStatus.CANCELLED },
      select: collectionSelect,
    });
    this.logger.warn({
      message: 'Collection cancelled',
      collectionId: collection.id,
      masjidId,
    });
    return this.toResponse(collection);
  }

  private async ensureCollectionBelongsToMasjid(
    id: string,
    masjidId: string,
  ): Promise<CollectionRecord> {
    const collection = await this.prisma.collection.findUnique({
      where: { id },
      select: collectionSelect,
    });

    if (!collection) {
      throw new ApiException(
        'Collection not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.COLLECTION_NOT_FOUND,
      );
    }

    assertSameMasjid(
      collection.masjidId,
      masjidId,
      'You are not allowed to access this finance entry',
      ERROR_CODES.FINANCE_ACCESS_FORBIDDEN,
    );

    return collection;
  }

  private buildWhere(
    masjidId: string,
    query: GetCollectionsQueryDto,
  ): Prisma.CollectionWhereInput {
    const where: Prisma.CollectionWhereInput = { masjidId };
    if (query.type !== undefined) where.type = query.type;
    if (query.status !== undefined) where.status = query.status;
    if (query.fromDate || query.toDate) {
      const collectedAt: Prisma.DateTimeFilter<'Collection'> = {};
      if (query.fromDate) collectedAt.gte = new Date(query.fromDate);
      if (query.toDate) collectedAt.lte = new Date(query.toDate);
      where.collectedAt = collectedAt;
    }
    if (query.search) {
      where.OR = [
        { title: { contains: query.search, mode: 'insensitive' } },
        { description: { contains: query.search, mode: 'insensitive' } },
      ];
    }
    return where;
  }

  private buildUpdateData(
    dto: UpdateCollectionDto,
  ): Prisma.CollectionUpdateInput {
    const data: Prisma.CollectionUpdateInput = {};
    if (dto.type !== undefined) data.type = dto.type;
    if (dto.amount !== undefined) data.amount = dto.amount;
    if (dto.title !== undefined) data.title = dto.title;
    if (dto.description !== undefined) data.description = dto.description;
    if (dto.collectedAt !== undefined)
      data.collectedAt = new Date(dto.collectedAt);
    if (dto.status !== undefined) data.status = dto.status;
    return data;
  }

  private toResponse(collection: CollectionRecord): CollectionResponse {
    return { ...collection, amount: toAmount(collection.amount) };
  }
}

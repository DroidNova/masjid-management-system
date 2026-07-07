import { HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import {
  CollectionTypeDto,
  CreateCollectionDto,
  FinanceEntryStatusDto,
} from './dto/create-collection.dto';
import { GetCollectionsQueryDto } from './dto/get-collections-query.dto';
import { UpdateCollectionDto } from './dto/update-collection.dto';

type DecimalLike =
  | number
  | string
  | { toNumber?: () => number; toString: () => string };

type CollectionRecord = {
  id: string;
  masjidId: string;
  type: string;
  amount: DecimalLike;
  title: string | null;
  description: string | null;
  collectedAt: Date;
  status: string;
  createdById: string | null;
  createdAt: Date;
  updatedAt: Date;
};

type CollectionResponse = Omit<CollectionRecord, 'amount'> & { amount: number };

type CollectionWhereInput = {
  masjidId: string;
  type?: CollectionTypeDto;
  status?: FinanceEntryStatusDto;
  collectedAt?: { gte?: Date; lte?: Date };
  OR?: Array<{
    title?: { contains: string; mode: 'insensitive' };
    description?: { contains: string; mode: 'insensitive' };
  }>;
};

type CollectionCreateData = {
  masjidId: string;
  createdById: string;
  type: CollectionTypeDto;
  amount: number;
  title?: string;
  description?: string;
  collectedAt?: Date;
};

type CollectionUpdateData = Partial<{
  type: CollectionTypeDto;
  amount: number;
  title: string | null;
  description: string | null;
  collectedAt: Date;
  status: FinanceEntryStatusDto;
}>;

type CollectionsDelegate = {
  findMany(args: {
    where: CollectionWhereInput;
    skip: number;
    take: number;
    orderBy: { collectedAt: 'desc' };
    select: typeof collectionSelect;
  }): Promise<CollectionRecord[]>;
  count(args: { where: CollectionWhereInput }): Promise<number>;
  create(args: {
    data: CollectionCreateData;
    select: typeof collectionSelect;
  }): Promise<CollectionRecord>;
  findUnique(args: {
    where: { id: string };
    select: typeof collectionSelect;
  }): Promise<CollectionRecord | null>;
  update(args: {
    where: { id: string };
    data: CollectionUpdateData;
    select: typeof collectionSelect;
  }): Promise<CollectionRecord>;
};

type CollectionsPrismaDelegate = {
  collection: CollectionsDelegate;
};

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
} as const;

@Injectable()
export class CollectionsService {
  constructor(private readonly prisma: PrismaService) {}

  private get db(): CollectionsPrismaDelegate {
    return this.prisma as unknown as CollectionsPrismaDelegate;
  }

  async findMyMasjidCollections(
    query: GetCollectionsQueryDto,
    actor: AuthenticatedUser,
  ) {
    const masjidId = this.getCurrentUserMasjidId(actor);
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const where = this.buildWhere(masjidId, query);

    const [items, total] = await Promise.all([
      this.db.collection.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { collectedAt: 'desc' },
        select: collectionSelect,
      }),
      this.db.collection.count({ where }),
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
    const masjidId = this.getCurrentUserMasjidId(actor);
    const collection = await this.db.collection.create({
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

    return this.toResponse(collection);
  }

  async findOne(
    id: string,
    actor: AuthenticatedUser,
  ): Promise<CollectionResponse> {
    const masjidId = this.getCurrentUserMasjidId(actor);
    const collection = await this.ensureCollectionBelongsToMasjid(id, masjidId);
    return this.toResponse(collection);
  }

  async update(
    id: string,
    dto: UpdateCollectionDto,
    actor: AuthenticatedUser,
  ): Promise<CollectionResponse> {
    const masjidId = this.getCurrentUserMasjidId(actor);
    await this.ensureCollectionBelongsToMasjid(id, masjidId);
    const data = this.buildUpdateData(dto);

    if (Object.keys(data).length === 0) {
      throw new ApiException(
        'At least one collection field must be provided',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }

    const collection = await this.db.collection.update({
      where: { id },
      data,
      select: collectionSelect,
    });
    return this.toResponse(collection);
  }

  async cancel(
    id: string,
    actor: AuthenticatedUser,
  ): Promise<CollectionResponse> {
    const masjidId = this.getCurrentUserMasjidId(actor);
    await this.ensureCollectionBelongsToMasjid(id, masjidId);
    const collection = await this.db.collection.update({
      where: { id },
      data: { status: FinanceEntryStatusDto.CANCELLED },
      select: collectionSelect,
    });
    return this.toResponse(collection);
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

  private async ensureCollectionBelongsToMasjid(
    id: string,
    masjidId: string,
  ): Promise<CollectionRecord> {
    const collection = await this.db.collection.findUnique({
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

    if (collection.masjidId !== masjidId) {
      throw new ApiException(
        'You are not allowed to access this finance entry',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.FINANCE_ACCESS_FORBIDDEN,
      );
    }

    return collection;
  }

  private buildWhere(
    masjidId: string,
    query: GetCollectionsQueryDto,
  ): CollectionWhereInput {
    const where: CollectionWhereInput = { masjidId };
    if (query.type !== undefined) where.type = query.type;
    if (query.status !== undefined) where.status = query.status;
    if (query.fromDate || query.toDate) {
      where.collectedAt = {};
      if (query.fromDate) where.collectedAt.gte = new Date(query.fromDate);
      if (query.toDate) where.collectedAt.lte = new Date(query.toDate);
    }
    if (query.search) {
      where.OR = [
        { title: { contains: query.search, mode: 'insensitive' } },
        { description: { contains: query.search, mode: 'insensitive' } },
      ];
    }
    return where;
  }

  private buildUpdateData(dto: UpdateCollectionDto): CollectionUpdateData {
    const data: CollectionUpdateData = {};
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
    return { ...collection, amount: this.toNumber(collection.amount) };
  }

  private toNumber(value: DecimalLike): number {
    if (typeof value === 'number') return value;
    if (typeof value === 'string') return Number(value);
    if (typeof value.toNumber === 'function') return value.toNumber();
    return Number(value.toString());
  }
}

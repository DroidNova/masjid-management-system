import { Logger, HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import {
  AUDIT_ACTION,
  AUDIT_ENTITY,
  AuditService,
} from '../../../common/audit/audit.service';
import {
  formatMoney,
  money,
  MoneyInput,
  toAmount,
} from '../../../common/money';
import {
  NOTIFICATION_KIND,
  NotificationKind,
  NotificationsService,
} from '../notifications/notifications.service';
import { requireMasjidId } from '../../../common/tenant';
import { Prisma } from '../../../generated/prisma/client';
import { FinanceEntryStatus } from '../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { CreateCollectionDto } from './dto/create-collection.dto';
import { GetCollectionsQueryDto } from './dto/get-collections-query.dto';
import { UpdateCollectionDto } from './dto/update-collection.dto';
import { pageArgs, paged } from '../../../common/pagination';
import { dateRange } from '../shared-date';

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

type Db = PrismaService | Prisma.TransactionClient;

@Injectable()
export class CollectionsService {
  private readonly logger = new Logger(CollectionsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly notifications: NotificationsService,
  ) {}

  async findMyMasjidCollections(
    query: GetCollectionsQueryDto,
    actor: AuthenticatedUser,
  ) {
    const masjidId = requireMasjidId(actor);
    const { page, limit, skip, take } = pageArgs(query);
    const where = this.buildWhere(masjidId, query);

    const [items, total] = await Promise.all([
      this.prisma.collection.findMany({
        where,
        skip,
        take,
        orderBy: { collectedAt: 'desc' },
        select: collectionSelect,
      }),
      this.prisma.collection.count({ where }),
    ]);

    return paged(
      items.map((item) => this.toResponse(item)),
      total,
      page,
      limit,
    );
  }

  async create(
    dto: CreateCollectionDto,
    actor: AuthenticatedUser,
  ): Promise<CollectionResponse> {
    const masjidId = requireMasjidId(actor);
    const collection = await this.prisma.$transaction(async (tx) => {
      const created = await tx.collection.create({
        data: {
          masjidId,
          createdById: actor.id,
          type: dto.type,
          amount: dto.amount,
          ...(dto.title !== undefined ? { title: dto.title } : {}),
          ...(dto.description !== undefined
            ? { description: dto.description }
            : {}),
          ...(dto.collectedAt
            ? { collectedAt: new Date(dto.collectedAt) }
            : {}),
        },
        select: collectionSelect,
      });
      await this.audit.record(
        {
          masjidId,
          actor,
          action: AUDIT_ACTION.CREATE,
          entity: AUDIT_ENTITY.COLLECTION,
          entityId: created.id,
          summary: this.auditSummary(created),
          after: created,
        },
        tx,
      );
      return created;
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
    const collection = await this.findScoped(this.prisma, id, masjidId);
    return this.toResponse(collection);
  }

  async update(
    id: string,
    dto: UpdateCollectionDto,
    actor: AuthenticatedUser,
  ): Promise<CollectionResponse> {
    const masjidId = requireMasjidId(actor);
    const data = this.buildUpdateData(dto);

    if (Object.keys(data).length === 0) {
      throw new ApiException(
        'At least one collection field must be provided',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }

    const collection = await this.prisma.$transaction(async (tx) => {
      const before = await this.findScoped(tx, id, masjidId);
      const updated = await tx.collection.update({
        where: { id: before.id },
        data,
        select: collectionSelect,
      });
      await this.audit.record(
        {
          masjidId,
          actor,
          action: AUDIT_ACTION.UPDATE,
          entity: AUDIT_ENTITY.COLLECTION,
          entityId: updated.id,
          summary: this.auditSummary(updated),
          before,
          after: updated,
        },
        tx,
      );
      const amountChanged = !money(before.amount).equals(updated.amount);
      await this.tellGiver(tx, masjidId, before.id, actor, {
        kind: NOTIFICATION_KIND.PAYMENT_CHANGED,
        amount: before.amount,
        ...(amountChanged ? { newAmount: updated.amount } : {}),
        collectionType: updated.type,
      });
      return updated;
    });
    this.logger.log({
      message: 'Collection updated',
      collectionId: collection.id,
      masjidId,
    });
    return this.toResponse(collection);
  }

  /**
   * Cancels (soft-deletes) a collection. Cancelling an already cancelled
   * entry returns it unchanged and writes no audit entry.
   *
   * A collection created for a collection contribution can be cancelled too;
   * the CollectionContribution row is kept as the historical record of the
   * payment (it is not deleted).
   */
  async cancel(
    id: string,
    actor: AuthenticatedUser,
  ): Promise<CollectionResponse> {
    const masjidId = requireMasjidId(actor);
    const { collection, changed } = await this.prisma.$transaction(
      async (tx) => {
        const before = await this.findScoped(tx, id, masjidId);
        if (before.status === FinanceEntryStatus.CANCELLED) {
          return { collection: before, changed: false };
        }
        const cancelled = await tx.collection.update({
          where: { id: before.id },
          data: { status: FinanceEntryStatus.CANCELLED },
          select: collectionSelect,
        });
        await this.audit.record(
          {
            masjidId,
            actor,
            action: AUDIT_ACTION.CANCEL,
            entity: AUDIT_ENTITY.COLLECTION,
            entityId: cancelled.id,
            summary: `${this.auditSummary(cancelled)} cancelled`,
            before,
            after: cancelled,
          },
          tx,
        );
        await this.tellGiver(tx, masjidId, before.id, actor, {
          kind: NOTIFICATION_KIND.PAYMENT_CANCELLED,
          amount: before.amount,
          collectionType: before.type,
        });
        return { collection: cancelled, changed: true };
      },
    );
    if (changed) {
      this.logger.warn({
        message: 'Collection cancelled',
        collectionId: collection.id,
        masjidId,
      });
    }
    return this.toResponse(collection);
  }

  /**
   * When this entry was made for a member's gift, tells that member it was
   * changed or cancelled (inside the same transaction).
   */
  private async tellGiver(
    tx: Prisma.TransactionClient,
    masjidId: string,
    collectionId: string,
    actor: AuthenticatedUser,
    change: {
      kind: NotificationKind;
      amount: MoneyInput;
      newAmount?: MoneyInput;
      collectionType: string;
    },
  ): Promise<void> {
    const contribution = await tx.collectionContribution.findUnique({
      where: { collectionId },
      select: { id: true, memberId: true },
    });
    if (!contribution?.memberId) return;
    const { collectionType, ...amounts } = change;
    await this.notifications.paymentNotice(
      {
        masjidId,
        memberId: contribution.memberId,
        actor,
        entity: AUDIT_ENTITY.COLLECTION_CONTRIBUTION,
        entityId: contribution.id,
        ...amounts,
        paymentFor: { purpose: 'DONATION', collectionType },
      },
      tx,
    );
  }

  /** The collection with this id in this masjid; 404 otherwise (also for another masjid's id). */
  private async findScoped(
    db: Db,
    id: string,
    masjidId: string,
  ): Promise<CollectionRecord> {
    const collection = await db.collection.findFirst({
      where: { id, masjidId },
      select: collectionSelect,
    });

    if (!collection) {
      throw new ApiException(
        'Collection not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.COLLECTION_NOT_FOUND,
      );
    }

    return collection;
  }

  private buildWhere(
    masjidId: string,
    query: GetCollectionsQueryDto,
  ): Prisma.CollectionWhereInput {
    const where: Prisma.CollectionWhereInput = { masjidId };
    if (query.type !== undefined) where.type = query.type;
    if (query.status !== undefined) where.status = query.status;
    const collectedAt = dateRange(query.fromDate, query.toDate);
    if (collectedAt) where.collectedAt = collectedAt;
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
    return data;
  }

  private auditSummary(collection: CollectionRecord): string {
    return `Collection ${collection.type} ${formatMoney(collection.amount)}`;
  }

  private toResponse(collection: CollectionRecord): CollectionResponse {
    return { ...collection, amount: toAmount(collection.amount) };
  }
}

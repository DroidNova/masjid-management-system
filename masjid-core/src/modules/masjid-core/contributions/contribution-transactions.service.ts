import { HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { successResponse } from '../../../common/helpers/api-response.helper';
import {
  AUDIT_ACTION,
  AUDIT_ENTITY,
  AuditService,
} from '../../../common/audit/audit.service';
import { formatMoney, toAmount } from '../../../common/money';
import { requireMasjidId } from '../../../common/tenant';
import { Prisma } from '../../../generated/prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import {
  CollectionContributionListQueryDto,
  ContributionListQueryDto,
} from './dto/contribution-list-query.dto';
import {
  CreateCollectionContributionDto,
  CreateContributionDto,
} from './dto/create-contribution.dto';
import { pageArgs, paged } from '../../../common/pagination';
import { dateRange } from '../shared-date';

const contributionSelect = {
  id: true,
  projectId: true,
  contributorName: true,
  contributorPhone: true,
  amount: true,
  paymentMode: true,
  paidAt: true,
  collectedByName: true,
  note: true,
} satisfies Prisma.ProjectContributionSelect;

const collectionContributionSelect = {
  id: true,
  collectionType: true,
  contributorName: true,
  contributorPhone: true,
  amount: true,
  paymentMode: true,
  paidAt: true,
  collectedByName: true,
  note: true,
} satisfies Prisma.CollectionContributionSelect;

const contributionOrderBy = [
  { paidAt: 'desc' },
  { createdAt: 'desc' },
] satisfies Prisma.ProjectContributionOrderByWithRelationInput[] &
  Prisma.CollectionContributionOrderByWithRelationInput[];

@Injectable()
export class ContributionTransactionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
  ) {}

  async createProjectContribution(
    projectId: string,
    dto: CreateContributionDto,
    actor: AuthenticatedUser,
  ) {
    const masjidId = requireMasjidId(actor);
    return this.prisma.$transaction(async (tx) => {
      // Scoped atomic increment: doubles as the "project exists in this
      // masjid" check and locks the row until the transaction ends.
      const { count } = await tx.project.updateMany({
        where: { id: projectId, masjidId },
        data: { collectedAmount: { increment: dto.amount } },
      });
      if (count === 0)
        this.notFound('Project not found', ERROR_CODES.PROJECT_NOT_FOUND);
      await this.validateMember(tx, dto.memberId, masjidId);
      const contribution = await tx.projectContribution.create({
        data: {
          masjidId,
          projectId,
          ...this.baseData(dto, actor),
        },
        select: contributionSelect,
      });
      await this.audit.record(
        {
          masjidId,
          actor,
          action: AUDIT_ACTION.CREATE,
          entity: AUDIT_ENTITY.PROJECT_CONTRIBUTION,
          entityId: contribution.id,
          summary: `Project contribution ${formatMoney(contribution.amount)} ${contribution.paymentMode} from ${contribution.contributorName}`,
          after: { ...contribution, masjidId },
        },
        tx,
      );
      return successResponse(
        'Project contribution added successfully',
        this.serialize(contribution),
      );
    });
  }

  async listProjectContributions(
    projectId: string,
    query: ContributionListQueryDto,
    actor: AuthenticatedUser,
  ) {
    const masjidId = requireMasjidId(actor);
    const where: Prisma.ProjectContributionWhereInput = {
      projectId,
      masjidId,
      ...this.filters(query),
    };
    const { page, limit, skip, take } = pageArgs(query);
    // The rows are scoped by masjidId, so the project check can run in parallel.
    const [project, items, total] = await Promise.all([
      this.prisma.project.findFirst({
        where: { id: projectId, masjidId },
        select: { id: true },
      }),
      this.prisma.projectContribution.findMany({
        where,
        skip,
        take,
        orderBy: contributionOrderBy,
        select: contributionSelect,
      }),
      this.prisma.projectContribution.count({ where }),
    ]);
    if (!project)
      this.notFound('Project not found', ERROR_CODES.PROJECT_NOT_FOUND);
    return successResponse(
      'Project contributions fetched successfully',
      paged(
        items.map((item) => this.serialize(item)),
        total,
        page,
        limit,
      ),
    );
  }

  async createCollectionContribution(
    dto: CreateCollectionContributionDto,
    actor: AuthenticatedUser,
  ) {
    const masjidId = requireMasjidId(actor);
    return this.prisma.$transaction(async (tx) => {
      await this.validateMember(tx, dto.memberId, masjidId);
      // The finance entry that counts this money in the masjid totals. If it
      // is cancelled later, the contribution row stays as the historical
      // record of the payment (it is linked, not cascade-deleted).
      const collection = await tx.collection.create({
        data: {
          masjidId,
          type: dto.collectionType,
          amount: dto.amount,
          title: dto.contributorName.trim(),
          description: dto.note?.trim() || null,
          collectedAt: new Date(dto.paidAt),
          createdById: actor.id,
        },
        select: { id: true },
      });
      const contribution = await tx.collectionContribution.create({
        data: {
          masjidId,
          collectionId: collection.id,
          collectionType: dto.collectionType,
          ...this.baseData(dto, actor),
        },
        select: collectionContributionSelect,
      });
      await this.audit.record(
        {
          masjidId,
          actor,
          action: AUDIT_ACTION.CREATE,
          entity: AUDIT_ENTITY.COLLECTION_CONTRIBUTION,
          entityId: contribution.id,
          summary: `Collection contribution ${contribution.collectionType} ${formatMoney(contribution.amount)} ${contribution.paymentMode} from ${contribution.contributorName}`,
          after: { ...contribution, masjidId, collectionId: collection.id },
        },
        tx,
      );
      return successResponse(
        'Collection contribution added successfully',
        this.serialize(contribution),
      );
    });
  }

  async listCollectionContributions(
    query: CollectionContributionListQueryDto,
    actor: AuthenticatedUser,
  ) {
    const where: Prisma.CollectionContributionWhereInput = {
      masjidId: requireMasjidId(actor),
      ...(query.collectionType ? { collectionType: query.collectionType } : {}),
      ...this.filters(query),
    };
    const { page, limit, skip, take } = pageArgs(query);
    const [items, total] = await Promise.all([
      this.prisma.collectionContribution.findMany({
        where,
        skip,
        take,
        orderBy: contributionOrderBy,
        select: collectionContributionSelect,
      }),
      this.prisma.collectionContribution.count({ where }),
    ]);
    return successResponse(
      'Collection contributions fetched successfully',
      paged(
        items.map((item) => this.serialize(item)),
        total,
        page,
        limit,
      ),
    );
  }

  private baseData(dto: CreateContributionDto, actor: AuthenticatedUser) {
    return {
      memberId: dto.memberId,
      contributorName: dto.contributorName.trim(),
      contributorPhone: dto.contributorPhone?.trim() || null,
      amount: dto.amount,
      paymentMode: dto.paymentMode,
      paidAt: new Date(dto.paidAt),
      collectedById: actor.id,
      collectedByName: actor.fullName,
      note: dto.note?.trim() || null,
    };
  }

  private async validateMember(
    tx: Prisma.TransactionClient,
    memberId: string | undefined,
    masjidId: string,
  ) {
    if (!memberId) return;
    const member = await tx.user.findFirst({
      where: { id: memberId, masjidId },
      select: { id: true },
    });
    if (!member) {
      throw new ApiException(
        'Member does not belong to this masjid',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.MASJID_USER_FORBIDDEN,
      );
    }
  }

  /** Filters shared by the project and collection contribution lists. */
  private filters(query: ContributionListQueryDto) {
    const search = query.search?.trim();
    const paidAt = dateRange(query.fromDate, query.toDate);
    return {
      ...(query.paymentMode ? { paymentMode: query.paymentMode } : {}),
      ...(search
        ? {
            OR: [
              {
                contributorName: {
                  contains: search,
                  mode: 'insensitive' as const,
                },
              },
              { contributorPhone: { contains: search } },
            ],
          }
        : {}),
      ...(paidAt ? { paidAt } : {}),
    };
  }

  private serialize<T extends { amount: Prisma.Decimal }>(item: T) {
    return { ...item, amount: toAmount(item.amount) };
  }

  private notFound(
    message: string,
    code: typeof ERROR_CODES.PROJECT_NOT_FOUND,
  ): never {
    throw new ApiException(message, HttpStatus.NOT_FOUND, code);
  }
}

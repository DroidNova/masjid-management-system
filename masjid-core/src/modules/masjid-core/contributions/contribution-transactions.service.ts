import { HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { successResponse } from '../../../common/helpers/api-response.helper';
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

type DynamicDb = Record<string, any>;

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
} as const;

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
} as const;

@Injectable()
export class ContributionTransactionsService {
  constructor(private readonly prisma: PrismaService) {}
  private get db(): DynamicDb {
    return this.prisma as unknown as DynamicDb;
  }

  async createProjectContribution(
    projectId: string,
    dto: CreateContributionDto,
    actor: AuthenticatedUser,
  ) {
    const masjidId = this.masjidId(actor);
    return this.db.$transaction(async (tx: DynamicDb) => {
      const project = await tx.project.findFirst({
        where: { id: projectId, masjidId },
        select: { id: true },
      });
      if (!project)
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
      await tx.project.update({
        where: { id: projectId },
        data: { collectedAmount: { increment: dto.amount } },
      });
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
    const masjidId = this.masjidId(actor);
    const project = await this.db.project.findFirst({
      where: { id: projectId, masjidId },
      select: { id: true },
    });
    if (!project)
      this.notFound('Project not found', ERROR_CODES.PROJECT_NOT_FOUND);
    const where = { projectId, masjidId, ...this.filters(query) };
    return successResponse(
      'Project contributions fetched successfully',
      await this.page(
        this.db.projectContribution,
        where,
        query,
        contributionSelect,
      ),
    );
  }

  async createCollectionContribution(
    dto: CreateCollectionContributionDto,
    actor: AuthenticatedUser,
  ) {
    const masjidId = this.masjidId(actor);
    return this.db.$transaction(async (tx: DynamicDb) => {
      await this.validateMember(tx, dto.memberId, masjidId);
      const contribution = await tx.collectionContribution.create({
        data: {
          masjidId,
          collectionType: dto.collectionType,
          ...this.baseData(dto, actor),
        },
        select: collectionContributionSelect,
      });
      await tx.collection.create({
        data: {
          masjidId,
          type: dto.collectionType,
          amount: dto.amount,
          title: dto.contributorName.trim(),
          description: dto.note?.trim() || null,
          collectedAt: new Date(dto.paidAt),
          createdById: actor.id,
        },
      });
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
    const where = {
      masjidId: this.masjidId(actor),
      ...(query.collectionType ? { collectionType: query.collectionType } : {}),
      ...this.filters(query),
    };
    return successResponse(
      'Collection contributions fetched successfully',
      await this.page(
        this.db.collectionContribution,
        where,
        query,
        collectionContributionSelect,
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
    tx: DynamicDb,
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

  private filters(query: ContributionListQueryDto) {
    const search = query.search?.trim();
    return {
      ...(query.paymentMode ? { paymentMode: query.paymentMode } : {}),
      ...(search
        ? {
            OR: [
              { contributorName: { contains: search, mode: 'insensitive' } },
              { contributorPhone: { contains: search } },
            ],
          }
        : {}),
      ...(query.fromDate || query.toDate
        ? {
            paidAt: {
              ...(query.fromDate ? { gte: new Date(query.fromDate) } : {}),
              ...(query.toDate ? { lte: this.endOfDay(query.toDate) } : {}),
            },
          }
        : {}),
    };
  }

  private async page(
    delegate: DynamicDb,
    where: DynamicDb,
    query: { page?: number; limit?: number },
    select: DynamicDb,
  ) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const [items, total] = await Promise.all([
      delegate.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: [{ paidAt: 'desc' }, { createdAt: 'desc' }],
        select,
      }),
      delegate.count({ where }),
    ]);
    const totalPages = Math.ceil(total / limit);
    return {
      items: items.map((item: DynamicDb) => this.serialize(item)),
      total,
      page,
      limit,
      totalPages,
      hasNextPage: page < totalPages,
    };
  }

  private masjidId(actor: AuthenticatedUser): string {
    if (!actor.masjidId)
      throw new ApiException(
        'Current user is not assigned to a masjid',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.USER_MASJID_NOT_ASSIGNED,
      );
    return actor.masjidId;
  }
  private notFound(
    message: string,
    code: typeof ERROR_CODES.PROJECT_NOT_FOUND,
  ): never {
    throw new ApiException(message, HttpStatus.NOT_FOUND, code);
  }
  private endOfDay(value: string): Date {
    const date = new Date(value);
    date.setUTCHours(23, 59, 59, 999);
    return date;
  }
  private serialize<T>(value: T): T {
    return JSON.parse(
      JSON.stringify(value, (_key, item: unknown) =>
        item &&
        typeof item === 'object' &&
        'toNumber' in item &&
        typeof (item as { toNumber?: unknown }).toNumber === 'function'
          ? (item as { toNumber: () => number }).toNumber()
          : item,
      ),
    ) as T;
  }
}

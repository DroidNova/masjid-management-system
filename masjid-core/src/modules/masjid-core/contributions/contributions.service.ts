import { HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { successResponse } from '../../../common/helpers/api-response.helper';
import { money, sumMoney, toAmount } from '../../../common/money';
import { requireMasjidId } from '../../../common/tenant';
import { Prisma } from '../../../generated/prisma/client';
import { ImamSalaryAssignmentStatus } from '../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { MyContributionListQueryDto } from './dto/contribution-list-query.dto';
import { MyContributionQueryDto } from './dto/my-contribution-query.dto';
import { MyPaymentsQueryDto } from './dto/my-payments-query.dto';

const contributionOrderBy = [
  { paidAt: 'desc' },
  { createdAt: 'desc' },
] satisfies Prisma.ProjectContributionOrderByWithRelationInput[] &
  Prisma.CollectionContributionOrderByWithRelationInput[] &
  Prisma.ImamSalaryPaymentOrderByWithRelationInput[];

const salaryMonthOrderBy = [
  { imamSalaryMonth: { year: 'desc' } },
  { imamSalaryMonth: { month: 'desc' } },
] satisfies Prisma.ImamSalaryAssignmentOrderByWithRelationInput[];

@Injectable()
export class ContributionsService {
  constructor(private readonly prisma: PrismaService) {}

  async getSummary(actor: AuthenticatedUser) {
    const { user, masjidId } = await this.getCurrentUser(actor);
    const assignments = await this.prisma.imamSalaryAssignment.findMany({
      where: { memberId: actor.id, masjidId },
      take: 6,
      orderBy: salaryMonthOrderBy,
      select: {
        expectedAmount: true,
        paidAmount: true,
        dueAmount: true,
        status: true,
      },
    });

    const [projectAggregate, collectionAggregate] = await Promise.all([
      this.prisma.projectContribution.aggregate({
        where: { memberId: actor.id, masjidId },
        _sum: { amount: true },
      }),
      this.prisma.collectionContribution.aggregate({
        where: { memberId: actor.id, masjidId },
        _sum: { amount: true },
      }),
    ]);
    const projectContributionTotal = money(projectAggregate._sum.amount);
    const collectionContributionTotal = money(collectionAggregate._sum.amount);

    const sum = (field: 'expectedAmount' | 'paidAmount' | 'dueAmount') =>
      sumMoney(assignments.map((assignment) => assignment[field]));
    const countStatus = (status: ImamSalaryAssignmentStatus) =>
      assignments.filter((assignment) => assignment.status === status).length;

    return successResponse('Contribution summary fetched successfully', {
      user: {
        id: user.id,
        fullName: user.fullName,
        phone: user.phone,
        isFamilyHead: user.isFamilyHead,
      },
      projectContributionTotal: toAmount(projectContributionTotal),
      collectionContributionTotal: toAmount(collectionContributionTotal),
      totalContributionAmount: toAmount(
        sum('paidAmount')
          .plus(projectContributionTotal)
          .plus(collectionContributionTotal),
      ),
      imamSalary: {
        monthsShown: 6,
        totalExpected: toAmount(sum('expectedAmount')),
        totalPaid: toAmount(sum('paidAmount')),
        totalDue: toAmount(sum('dueAmount')),
        paidMonths: countStatus('PAID'),
        partialMonths: countStatus('PARTIAL'),
        unpaidMonths: countStatus('UNPAID'),
      },
    });
  }

  async getMyProjectContributions(
    query: MyContributionListQueryDto,
    actor: AuthenticatedUser,
  ) {
    const { masjidId } = await this.getCurrentUser(actor);
    const where: Prisma.ProjectContributionWhereInput = {
      memberId: actor.id,
      masjidId,
      ...this.dateFilter(query),
    };
    const { page, limit, skip } = this.pageArgs(query);
    const [items, total] = await Promise.all([
      this.prisma.projectContribution.findMany({
        where,
        skip,
        take: limit,
        orderBy: contributionOrderBy,
        select: {
          id: true,
          projectId: true,
          contributorName: true,
          contributorPhone: true,
          amount: true,
          paymentMode: true,
          paidAt: true,
          collectedByName: true,
          note: true,
          project: { select: { title: true } },
        },
      }),
      this.prisma.projectContribution.count({ where }),
    ]);
    return successResponse('Project contributions fetched successfully', {
      items: items.map((item) => this.withAmount(item)),
      ...this.pagination(total, page, limit),
    });
  }

  async getMyCollectionContributions(
    query: MyContributionListQueryDto,
    actor: AuthenticatedUser,
  ) {
    const { masjidId } = await this.getCurrentUser(actor);
    const where: Prisma.CollectionContributionWhereInput = {
      memberId: actor.id,
      masjidId,
      ...this.dateFilter(query),
    };
    const { page, limit, skip } = this.pageArgs(query);
    const [items, total] = await Promise.all([
      this.prisma.collectionContribution.findMany({
        where,
        skip,
        take: limit,
        orderBy: contributionOrderBy,
        select: {
          id: true,
          collectionType: true,
          contributorName: true,
          contributorPhone: true,
          amount: true,
          paymentMode: true,
          paidAt: true,
          collectedByName: true,
          note: true,
        },
      }),
      this.prisma.collectionContribution.count({ where }),
    ]);
    return successResponse('Collection contributions fetched successfully', {
      items: items.map((item) => this.withAmount(item)),
      ...this.pagination(total, page, limit),
    });
  }

  async getImamSalaryHistory(
    query: MyContributionQueryDto,
    actor: AuthenticatedUser,
  ) {
    const { masjidId } = await this.getCurrentUser(actor);
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const monthsBack = query.monthsBack ?? 6;
    const where: Prisma.ImamSalaryAssignmentWhereInput = {
      memberId: actor.id,
      masjidId,
    };
    const totalAvailable = await this.prisma.imamSalaryAssignment.count({
      where,
    });
    const total = Math.min(totalAvailable, monthsBack);
    const skip = (page - 1) * limit;

    const assignments =
      skip >= total
        ? []
        : await this.prisma.imamSalaryAssignment.findMany({
            where,
            skip,
            take: Math.min(limit, total - skip),
            orderBy: salaryMonthOrderBy,
            select: {
              expectedAmount: true,
              paidAmount: true,
              dueAmount: true,
              status: true,
              imamSalaryMonth: { select: { month: true, year: true } },
              _count: { select: { payments: true } },
              payments: {
                take: 1,
                orderBy: { paidAt: 'desc' },
                select: { paidAt: true },
              },
            },
          });

    return successResponse('Imam salary contributions fetched successfully', {
      ...this.pagination(total, page, limit),
      items: assignments.map((assignment) => ({
        month: assignment.imamSalaryMonth.month,
        year: assignment.imamSalaryMonth.year,
        expectedAmount: toAmount(assignment.expectedAmount),
        paidAmount: toAmount(assignment.paidAmount),
        dueAmount: toAmount(assignment.dueAmount),
        status: assignment.status,
        paymentsCount: assignment._count.payments,
        lastPaidAt: assignment.payments[0]?.paidAt ?? null,
      })),
    });
  }

  async getImamSalaryPayments(
    month: number,
    year: number,
    query: MyPaymentsQueryDto,
    actor: AuthenticatedUser,
  ) {
    this.validateMonthYear(month, year);
    const { masjidId } = await this.getCurrentUser(actor);
    const { page, limit, skip } = this.pageArgs(query);
    const where: Prisma.ImamSalaryPaymentWhereInput = {
      memberId: actor.id,
      masjidId,
      paymentForMonth: month,
      paymentForYear: year,
    };
    const [payments, total] = await Promise.all([
      this.prisma.imamSalaryPayment.findMany({
        where,
        skip,
        take: limit,
        orderBy: contributionOrderBy,
        select: {
          id: true,
          amount: true,
          paymentMode: true,
          paidAt: true,
          collectedByName: true,
          note: true,
        },
      }),
      this.prisma.imamSalaryPayment.count({ where }),
    ]);

    return successResponse('Imam salary payments fetched successfully', {
      ...this.pagination(total, page, limit),
      items: payments.map((payment) => this.withAmount(payment)),
    });
  }

  /** Loads the signed-in user; the masjid is read from the database, not the token. */
  private async getCurrentUser(actor: AuthenticatedUser) {
    const user = await this.prisma.user.findUnique({
      where: { id: actor.id },
      select: {
        id: true,
        fullName: true,
        phone: true,
        isFamilyHead: true,
        masjidId: true,
      },
    });
    const masjidId = requireMasjidId(user ?? { masjidId: null });
    return { user: user!, masjidId };
  }

  private dateFilter(query: MyContributionListQueryDto) {
    if (!query.fromDate && !query.toDate) return {};
    return {
      paidAt: {
        ...(query.fromDate ? { gte: new Date(query.fromDate) } : {}),
        ...(query.toDate ? { lte: this.endOfDay(query.toDate) } : {}),
      },
    };
  }

  private endOfDay(value: string): Date {
    const date = new Date(value);
    date.setUTCHours(23, 59, 59, 999);
    return date;
  }

  private withAmount<T extends { amount: Prisma.Decimal }>(item: T) {
    return { ...item, amount: toAmount(item.amount) };
  }

  private pageArgs(query: { page?: number; limit?: number }) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    return { page, limit, skip: (page - 1) * limit };
  }

  private pagination(total: number, page: number, limit: number) {
    const totalPages = Math.ceil(total / limit);
    return {
      total,
      page,
      limit,
      totalPages,
      hasNextPage: page < totalPages,
    };
  }

  private validateMonthYear(month: number, year: number): void {
    if (month < 1 || month > 12 || year < 2000 || year > 2200) {
      throw new ApiException(
        'Enter a valid month and year',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.VALIDATION_ERROR,
      );
    }
  }
}

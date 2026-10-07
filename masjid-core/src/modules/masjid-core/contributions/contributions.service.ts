import { HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { successResponse } from '../../../common/helpers/api-response.helper';
import { money, sumMoney, toAmount } from '../../../common/money';
import { pageArgs, paged } from '../../../common/pagination';
import { requireMasjidId } from '../../../common/tenant';
import { Prisma } from '../../../generated/prisma/client';
import { ImamSalaryAssignmentStatus } from '../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { dateRange } from '../shared-date';
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

/**
 * The signed-in user's own contributions. Everything is scoped to the user
 * id and masjid in the access token (no extra user lookup per request).
 */
@Injectable()
export class ContributionsService {
  constructor(private readonly prisma: PrismaService) {}

  async getSummary(actor: AuthenticatedUser) {
    const masjidId = requireMasjidId(actor);
    const mine = { memberId: actor.id, masjidId };
    const [assignments, projectAggregate, collectionAggregate] =
      await Promise.all([
        this.prisma.imamSalaryAssignment.findMany({
          where: mine,
          take: 6,
          orderBy: salaryMonthOrderBy,
          select: {
            expectedAmount: true,
            paidAmount: true,
            dueAmount: true,
            status: true,
          },
        }),
        this.prisma.projectContribution.aggregate({
          where: mine,
          _sum: { amount: true },
        }),
        this.prisma.collectionContribution.aggregate({
          where: mine,
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
        id: actor.id,
        fullName: actor.fullName,
        phone: actor.phone,
        isFamilyHead: actor.isFamilyHead,
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
    const where: Prisma.ProjectContributionWhereInput = {
      memberId: actor.id,
      masjidId: requireMasjidId(actor),
      ...this.paidAtFilter(query),
    };
    const { page, limit, skip, take } = pageArgs(query);
    const [items, total] = await Promise.all([
      this.prisma.projectContribution.findMany({
        where,
        skip,
        take,
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
    return successResponse(
      'Project contributions fetched successfully',
      paged(
        items.map((item) => this.withAmount(item)),
        total,
        page,
        limit,
      ),
    );
  }

  async getMyCollectionContributions(
    query: MyContributionListQueryDto,
    actor: AuthenticatedUser,
  ) {
    const where: Prisma.CollectionContributionWhereInput = {
      memberId: actor.id,
      masjidId: requireMasjidId(actor),
      ...this.paidAtFilter(query),
    };
    const { page, limit, skip, take } = pageArgs(query);
    const [items, total] = await Promise.all([
      this.prisma.collectionContribution.findMany({
        where,
        skip,
        take,
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
    return successResponse(
      'Collection contributions fetched successfully',
      paged(
        items.map((item) => this.withAmount(item)),
        total,
        page,
        limit,
      ),
    );
  }

  /** Only the latest `monthsBack` months are listed (and counted). */
  async getImamSalaryHistory(
    query: MyContributionQueryDto,
    actor: AuthenticatedUser,
  ) {
    const where: Prisma.ImamSalaryAssignmentWhereInput = {
      memberId: actor.id,
      masjidId: requireMasjidId(actor),
    };
    const { page, limit, skip } = pageArgs(query);
    const monthsBack = query.monthsBack ?? 6;
    const take = Math.min(limit, monthsBack - skip);

    const [totalAvailable, assignments] = await Promise.all([
      this.prisma.imamSalaryAssignment.count({ where }),
      take <= 0
        ? Promise.resolve([])
        : this.prisma.imamSalaryAssignment.findMany({
            where,
            skip,
            take,
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
          }),
    ]);

    return successResponse(
      'Imam salary contributions fetched successfully',
      paged(
        assignments.map((assignment) => ({
          month: assignment.imamSalaryMonth.month,
          year: assignment.imamSalaryMonth.year,
          expectedAmount: toAmount(assignment.expectedAmount),
          paidAmount: toAmount(assignment.paidAmount),
          dueAmount: toAmount(assignment.dueAmount),
          status: assignment.status,
          paymentsCount: assignment._count.payments,
          lastPaidAt: assignment.payments[0]?.paidAt ?? null,
        })),
        Math.min(totalAvailable, monthsBack),
        page,
        limit,
      ),
    );
  }

  async getImamSalaryPayments(
    month: number,
    year: number,
    query: MyPaymentsQueryDto,
    actor: AuthenticatedUser,
  ) {
    this.validateMonthYear(month, year);
    const where: Prisma.ImamSalaryPaymentWhereInput = {
      memberId: actor.id,
      masjidId: requireMasjidId(actor),
      paymentForMonth: month,
      paymentForYear: year,
    };
    const { page, limit, skip, take } = pageArgs(query);
    const [payments, total] = await Promise.all([
      this.prisma.imamSalaryPayment.findMany({
        where,
        skip,
        take,
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

    return successResponse(
      'Imam salary payments fetched successfully',
      paged(
        payments.map((payment) => this.withAmount(payment)),
        total,
        page,
        limit,
      ),
    );
  }

  private paidAtFilter(query: MyContributionListQueryDto) {
    const paidAt = dateRange(query.fromDate, query.toDate);
    return paidAt ? { paidAt } : {};
  }

  private withAmount<T extends { amount: Prisma.Decimal }>(item: T) {
    return { ...item, amount: toAmount(item.amount) };
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

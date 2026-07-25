import { HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { successResponse } from '../../../common/helpers/api-response.helper';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { MyContributionQueryDto } from './dto/my-contribution-query.dto';
import { MyPaymentsQueryDto } from './dto/my-payments-query.dto';

type DecimalValue = number | string | { toNumber(): number };
type DynamicDelegate = Record<string, (args: unknown) => Promise<unknown>>;
type ContributionsDb = {
  user: DynamicDelegate;
  imamSalaryAssignment: DynamicDelegate;
  imamSalaryPayment: DynamicDelegate;
};

type AssignmentRow = {
  expectedAmount: DecimalValue;
  paidAmount: DecimalValue;
  dueAmount: DecimalValue;
  status: 'PAID' | 'PARTIAL' | 'UNPAID';
  imamSalaryMonth: { month: number; year: number };
  payments: Array<{ paidAt: Date }>;
  _count: { payments: number };
};

type PaymentRow = {
  id: string;
  amount: DecimalValue;
  paymentMode: 'CASH' | 'ONLINE';
  paidAt: Date;
  collectedByName: string;
  note: string | null;
};

@Injectable()
export class ContributionsService {
  constructor(private readonly prisma: PrismaService) {}

  private get db(): ContributionsDb {
    return this.prisma as unknown as ContributionsDb;
  }

  async getSummary(actor: AuthenticatedUser) {
    const user = await this.getCurrentUser(actor);
    const assignments = (await this.db.imamSalaryAssignment.findMany({
      where: { memberId: actor.id, masjidId: user.masjidId },
      take: 6,
      orderBy: [
        { imamSalaryMonth: { year: 'desc' } },
        { imamSalaryMonth: { month: 'desc' } },
      ],
      select: {
        expectedAmount: true,
        paidAmount: true,
        dueAmount: true,
        status: true,
      },
    } as never)) as unknown as AssignmentRow[];

    const sum = (field: 'expectedAmount' | 'paidAmount' | 'dueAmount') =>
      assignments.reduce((total, assignment) => {
        return total + this.toNumber(assignment[field]);
      }, 0);

    return successResponse('Contribution summary fetched successfully', {
      user: {
        id: user.id,
        fullName: user.fullName,
        phone: user.phone,
        isFamilyHead: user.isFamilyHead,
      },
      imamSalary: {
        monthsShown: 6,
        totalExpected: sum('expectedAmount'),
        totalPaid: sum('paidAmount'),
        totalDue: sum('dueAmount'),
        paidMonths: this.countStatus(assignments, 'PAID'),
        partialMonths: this.countStatus(assignments, 'PARTIAL'),
        unpaidMonths: this.countStatus(assignments, 'UNPAID'),
      },
    });
  }

  async getImamSalaryHistory(
    query: MyContributionQueryDto,
    actor: AuthenticatedUser,
  ) {
    const user = await this.getCurrentUser(actor);
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const monthsBack = query.monthsBack ?? 6;
    const where = { memberId: actor.id, masjidId: user.masjidId };
    const totalAvailable = (await this.db.imamSalaryAssignment.count({
      where,
    } as never)) as unknown as number;
    const total = Math.min(totalAvailable, monthsBack);
    const skip = (page - 1) * limit;

    const assignments =
      skip >= total
        ? []
        : ((await this.db.imamSalaryAssignment.findMany({
            where,
            skip,
            take: Math.min(limit, total - skip),
            orderBy: [
              { imamSalaryMonth: { year: 'desc' } },
              { imamSalaryMonth: { month: 'desc' } },
            ],
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
          } as never)) as unknown as AssignmentRow[]);

    return successResponse('Imam salary contributions fetched successfully', {
      ...this.pagination(total, page, limit),
      items: assignments.map((assignment) => ({
        month: assignment.imamSalaryMonth.month,
        year: assignment.imamSalaryMonth.year,
        expectedAmount: this.toNumber(assignment.expectedAmount),
        paidAmount: this.toNumber(assignment.paidAmount),
        dueAmount: this.toNumber(assignment.dueAmount),
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
    const user = await this.getCurrentUser(actor);
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const where = {
      memberId: actor.id,
      masjidId: user.masjidId,
      paymentForMonth: month,
      paymentForYear: year,
    };
    const [payments, total] = (await Promise.all([
      this.db.imamSalaryPayment.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: [{ paidAt: 'desc' }, { createdAt: 'desc' }],
        select: {
          id: true,
          amount: true,
          paymentMode: true,
          paidAt: true,
          collectedByName: true,
          note: true,
        },
      } as never),
      this.db.imamSalaryPayment.count({ where } as never),
    ])) as unknown as [PaymentRow[], number];

    return successResponse('Imam salary payments fetched successfully', {
      ...this.pagination(total, page, limit),
      items: payments.map((payment) => ({
        ...payment,
        amount: this.toNumber(payment.amount),
      })),
    });
  }

  private async getCurrentUser(actor: AuthenticatedUser) {
    const user = (await this.db.user.findUnique({
      where: { id: actor.id },
      select: {
        id: true,
        fullName: true,
        phone: true,
        isFamilyHead: true,
        masjidId: true,
      },
    } as never)) as unknown as {
      id: string;
      fullName: string;
      phone: string | null;
      isFamilyHead: boolean;
      masjidId: string | null;
    } | null;

    if (!user?.masjidId) {
      throw new ApiException(
        'Current user is not assigned to a masjid',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.USER_MASJID_NOT_ASSIGNED,
      );
    }

    return user;
  }

  private countStatus(assignments: AssignmentRow[], status: string): number {
    return assignments.filter((assignment) => assignment.status === status)
      .length;
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

  private toNumber(value: DecimalValue): number {
    if (typeof value === 'number') return value;
    if (typeof value === 'string') return Number(value);
    return value.toNumber();
  }
}

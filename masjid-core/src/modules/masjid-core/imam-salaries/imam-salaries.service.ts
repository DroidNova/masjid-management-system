import { HttpStatus, Injectable } from '@nestjs/common';
import {
  ERROR_CODES,
  type ErrorCode,
} from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import {
  AUDIT_ACTION,
  AUDIT_ENTITY,
  AuditService,
} from '../../../common/audit/audit.service';
import {
  type Money,
  formatMoney,
  money,
  toAmount,
  ZERO,
} from '../../../common/money';
import { Prisma } from '../../../generated/prisma/client';
import {
  ImamSalaryAssignmentStatus,
  RoleName,
  UserStatus,
} from '../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import {
  CreateSalaryMonthDto,
  CreateSalaryPaymentDto,
  MySalaryHistoryQueryDto,
  SalaryAssignmentsQueryDto,
  SalaryMonthsQueryDto,
  SalaryPaymentsQueryDto,
  UpdateSalaryAmountDto,
} from './dto/imam-salary-ledger.dto';
import { pageArgs, paged } from '../../../common/pagination';
import { requireMasjidId } from '../../../common/tenant';
import { isPrismaError } from '../prisma-errors';

type Db = PrismaService | Prisma.TransactionClient;

/** Month fields the app reads (no masjidId / createdById / updatedById). */
const monthSelect = {
  id: true,
  month: true,
  year: true,
  amountPerHead: true,
  totalExpected: true,
  totalCollected: true,
  totalDue: true,
  paidCount: true,
  partialCount: true,
  unpaidCount: true,
  status: true,
  note: true,
  createdByName: true,
  updatedByName: true,
  createdAt: true,
  updatedAt: true,
} as const satisfies Prisma.ImamSalaryMonthSelect;

const assignmentSelect = {
  id: true,
  imamSalaryMonthId: true,
  memberId: true,
  memberName: true,
  memberPhone: true,
  expectedAmount: true,
  paidAmount: true,
  dueAmount: true,
  status: true,
  createdAt: true,
  updatedAt: true,
} as const satisfies Prisma.ImamSalaryAssignmentSelect;

const paymentSelect = {
  id: true,
  imamSalaryMonthId: true,
  assignmentId: true,
  memberId: true,
  memberName: true,
  memberPhone: true,
  amount: true,
  paymentMode: true,
  paymentForMonth: true,
  paymentForYear: true,
  paidAt: true,
  collectedByName: true,
  note: true,
  createdAt: true,
} as const satisfies Prisma.ImamSalaryPaymentSelect;

type MonthRow = Prisma.ImamSalaryMonthGetPayload<{
  select: typeof monthSelect;
}>;
type AssignmentRow = Prisma.ImamSalaryAssignmentGetPayload<{
  select: typeof assignmentSelect;
}>;
type PaymentRow = Prisma.ImamSalaryPaymentGetPayload<{
  select: typeof paymentSelect;
}>;

type StatusCounts = {
  paidCount: number;
  partialCount: number;
  unpaidCount: number;
};

const COUNT_FIELD: Record<ImamSalaryAssignmentStatus, keyof StatusCounts> = {
  PAID: 'paidCount',
  PARTIAL: 'partialCount',
  UNPAID: 'unpaidCount',
};

@Injectable()
export class ImamSalariesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
  ) {}

  /**
   * Creates a month and one assignment per active family head. A second
   * month for the same masjid/month/year hits the unique key (P2002) and
   * becomes 409 IMAM_SALARY_ALREADY_EXISTS.
   */
  async createMonth(dto: CreateSalaryMonthDto, actor: AuthenticatedUser) {
    const masjidId = this.masjidId(actor);
    const amountPerHead = money(dto.amountPerHead);
    try {
      return await this.prisma.$transaction(async (tx) => {
        // Read inside the transaction so the head list and the month agree.
        const heads = await tx.user.findMany({
          where: {
            masjidId,
            status: UserStatus.ACTIVE,
            isFamilyHead: true,
            userRoles: { some: { role: { name: RoleName.MEMBER } } },
          },
          select: { id: true, fullName: true, phone: true },
        });
        const total = amountPerHead.times(heads.length);
        const month = await tx.imamSalaryMonth.create({
          data: {
            masjidId,
            month: dto.month,
            year: dto.year,
            amountPerHead,
            totalExpected: total,
            totalDue: total,
            unpaidCount: heads.length,
            note: dto.note?.trim() || null,
            createdById: actor.id,
            createdByName: actor.fullName,
          },
          select: monthSelect,
        });
        if (heads.length)
          await tx.imamSalaryAssignment.createMany({
            data: heads.map((member) => ({
              masjidId,
              imamSalaryMonthId: month.id,
              memberId: member.id,
              memberName: member.fullName,
              memberPhone: member.phone ?? '',
              expectedAmount: amountPerHead,
              dueAmount: amountPerHead,
            })),
          });
        await this.audit.record(
          {
            masjidId,
            actor,
            action: AUDIT_ACTION.CREATE,
            entity: AUDIT_ENTITY.SALARY_MONTH,
            entityId: month.id,
            summary: `Salary month ${month.month}/${month.year} at ${formatMoney(month.amountPerHead)} per head for ${heads.length} heads, total ${formatMoney(month.totalExpected)}`,
            after: { ...month, masjidId },
          },
          tx,
        );
        return this.toMonth(month);
      });
    } catch (error) {
      if (isPrismaError(error, 'P2002'))
        this.fail(
          'Salary month already exists',
          HttpStatus.CONFLICT,
          ERROR_CODES.IMAM_SALARY_ALREADY_EXISTS,
        );
      throw error;
    }
  }

  async listMonths(query: SalaryMonthsQueryDto, actor: AuthenticatedUser) {
    const where: Prisma.ImamSalaryMonthWhereInput = {
      masjidId: this.masjidId(actor),
      ...(query.month ? { month: query.month } : {}),
      ...(query.year ? { year: query.year } : {}),
    };
    const { page, limit, skip, take } = pageArgs(query);
    const [rows, total] = await Promise.all([
      this.prisma.imamSalaryMonth.findMany({
        where,
        skip,
        take,
        orderBy: [{ year: 'desc' }, { month: 'desc' }],
        select: monthSelect,
      }),
      this.prisma.imamSalaryMonth.count({ where }),
    ]);
    return paged(
      rows.map((row) => this.toMonth(row)),
      total,
      page,
      limit,
    );
  }

  async getMonth(id: string, actor: AuthenticatedUser) {
    return this.toMonth(await this.findMonth(id, this.masjidId(actor)));
  }

  async listAssignments(
    id: string,
    query: SalaryAssignmentsQueryDto,
    actor: AuthenticatedUser,
  ) {
    const masjidId = this.masjidId(actor);
    const search = query.search?.trim();
    const where: Prisma.ImamSalaryAssignmentWhereInput = {
      masjidId,
      imamSalaryMonthId: id,
      ...(query.status ? { status: query.status } : {}),
      ...(search
        ? {
            OR: [
              { memberName: { contains: search, mode: 'insensitive' } },
              { memberPhone: { contains: search } },
            ],
          }
        : {}),
    };
    const { page, limit, skip, take } = pageArgs(query);
    // Rows are scoped by masjidId, so the month check runs in parallel.
    const [, rows, total] = await Promise.all([
      this.findMonth(id, masjidId),
      this.prisma.imamSalaryAssignment.findMany({
        where,
        skip,
        take,
        orderBy: [{ memberName: 'asc' }],
        select: assignmentSelect,
      }),
      this.prisma.imamSalaryAssignment.count({ where }),
    ]);
    return paged(
      rows.map((row) => this.toAssignment(row)),
      total,
      page,
      limit,
    );
  }

  /**
   * Raises the amount per head. Every assignment is updated by one SQL
   * statement (expected = new amount, due = expected - paid, status from
   * paid); the month totals are then computed once and written once.
   * No "below an amount already paid" check is needed: paid never exceeds
   * the old amount, and the new amount is not lower.
   */
  async updateAmount(
    id: string,
    dto: UpdateSalaryAmountDto,
    actor: AuthenticatedUser,
  ) {
    const masjidId = this.masjidId(actor);
    const amountPerHead = money(dto.amountPerHead);
    return this.prisma.$transaction(async (tx) => {
      const before = await this.findMonth(id, masjidId, tx);
      if (amountPerHead.lessThan(before.amountPerHead))
        this.fail('Monthly amount can only be increased');

      const amount = amountPerHead.toFixed(2);
      await tx.$executeRaw`
        UPDATE "ImamSalaryAssignment"
        SET "expectedAmount" = ${amount}::numeric,
            "dueAmount" = ${amount}::numeric - "paidAmount",
            "status" = (CASE
              WHEN "paidAmount" <= 0 THEN 'UNPAID'
              WHEN "paidAmount" >= ${amount}::numeric THEN 'PAID'
              ELSE 'PARTIAL'
            END)::"ImamSalaryAssignmentStatus",
            "updatedAt" = (NOW() AT TIME ZONE 'UTC')
        WHERE "imamSalaryMonthId" = ${id}::uuid
          AND "masjidId" = ${masjidId}::uuid`;

      const groups = await tx.imamSalaryAssignment.groupBy({
        by: ['status'],
        where: { imamSalaryMonthId: id },
        _count: { _all: true },
        _sum: { expectedAmount: true, paidAmount: true, dueAmount: true },
      });
      const counts: StatusCounts = {
        paidCount: 0,
        partialCount: 0,
        unpaidCount: 0,
      };
      let totalExpected = ZERO;
      let totalCollected = ZERO;
      let totalDue = ZERO;
      for (const group of groups) {
        counts[COUNT_FIELD[group.status]] = group._count._all;
        totalExpected = totalExpected.plus(money(group._sum.expectedAmount));
        totalCollected = totalCollected.plus(money(group._sum.paidAmount));
        totalDue = totalDue.plus(money(group._sum.dueAmount));
      }

      const reason = dto.reason?.trim();
      const updated = await tx.imamSalaryMonth.update({
        where: { id },
        data: {
          amountPerHead,
          totalExpected,
          totalCollected,
          totalDue,
          ...counts,
          status: this.status(totalCollected, totalExpected),
          note: reason
            ? [before.note, reason].filter(Boolean).join('\n')
            : before.note,
          updatedById: actor.id,
          updatedByName: actor.fullName,
        },
        select: monthSelect,
      });
      await this.audit.record(
        {
          masjidId,
          actor,
          action: AUDIT_ACTION.UPDATE,
          entity: AUDIT_ENTITY.SALARY_MONTH,
          entityId: id,
          summary: `Salary month ${before.month}/${before.year} amount per head ${formatMoney(before.amountPerHead)} -> ${formatMoney(amountPerHead)}${reason ? ` (${reason})` : ''}`,
          before,
          // Same plain-number shape as the API response.
          after: this.toMonth(updated),
        },
        tx,
      );
      return this.toMonth(updated);
    });
  }

  /**
   * Records a payment without locking the whole month or re-reading every
   * assignment:
   *
   * 1. One conditional UPDATE on the assignment that only matches while
   *    `dueAmount >= amount`, adding to paid and subtracting from due in the
   *    database. Two concurrent payments can never overpay: the second one
   *    re-checks the condition against the first one's committed row.
   * 2. The new status is derived from the updated row; the month gets
   *    increments for its totals and +/-1 for the old and new status counts.
   */
  async addPayment(dto: CreateSalaryPaymentDto, actor: AuthenticatedUser) {
    const masjidId = this.masjidId(actor);
    const amount = money(dto.amount);
    return this.prisma.$transaction(async (tx) => {
      const { count } = await tx.imamSalaryAssignment.updateMany({
        where: {
          id: dto.assignmentId,
          masjidId,
          dueAmount: { gte: amount },
        },
        data: {
          paidAmount: { increment: amount },
          dueAmount: { decrement: amount },
        },
      });
      if (count === 0) {
        const exists = await tx.imamSalaryAssignment.findFirst({
          where: { id: dto.assignmentId, masjidId },
          select: { id: true },
        });
        if (!exists)
          this.fail(
            'Salary assignment not found',
            HttpStatus.NOT_FOUND,
            ERROR_CODES.IMAM_SALARY_NOT_FOUND,
          );
        this.fail('Payment amount cannot exceed current due amount');
      }

      // This transaction now holds the row lock, so `status` is still the
      // status from before this payment.
      const assignment = await tx.imamSalaryAssignment.findUniqueOrThrow({
        where: { id: dto.assignmentId },
        select: {
          id: true,
          imamSalaryMonthId: true,
          memberId: true,
          memberName: true,
          memberPhone: true,
          expectedAmount: true,
          paidAmount: true,
          status: true,
          imamSalaryMonth: { select: { month: true, year: true } },
        },
      });
      const oldStatus = assignment.status;
      const newStatus = this.status(
        money(assignment.paidAmount),
        money(assignment.expectedAmount),
      );
      if (newStatus !== oldStatus)
        await tx.imamSalaryAssignment.update({
          where: { id: assignment.id },
          data: { status: newStatus },
          select: { id: true },
        });

      await this.applyToMonth(
        tx,
        assignment.imamSalaryMonthId,
        amount,
        oldStatus,
        newStatus,
      );

      const payment = await tx.imamSalaryPayment.create({
        data: {
          masjidId,
          imamSalaryMonthId: assignment.imamSalaryMonthId,
          assignmentId: assignment.id,
          memberId: assignment.memberId,
          memberName: assignment.memberName,
          memberPhone: assignment.memberPhone,
          amount,
          paymentMode: dto.paymentMode,
          paidAt: new Date(dto.paidAt),
          paymentForMonth: assignment.imamSalaryMonth.month,
          paymentForYear: assignment.imamSalaryMonth.year,
          collectedById: actor.id,
          collectedByName: actor.fullName,
          note: dto.note?.trim() || null,
        },
        select: paymentSelect,
      });
      await this.audit.record(
        {
          masjidId,
          actor,
          action: AUDIT_ACTION.CREATE,
          entity: AUDIT_ENTITY.SALARY_PAYMENT,
          entityId: payment.id,
          summary: `Payment ${formatMoney(payment.amount)} ${payment.paymentMode} from ${payment.memberName} for ${payment.paymentForMonth}/${payment.paymentForYear}`,
          after: { ...payment, masjidId, collectedById: actor.id },
        },
        tx,
      );
      return this.toPayment(payment);
    });
  }

  async listPayments(query: SalaryPaymentsQueryDto, actor: AuthenticatedUser) {
    const search = query.search?.trim();
    const where: Prisma.ImamSalaryPaymentWhereInput = {
      masjidId: this.masjidId(actor),
      ...(query.month ? { paymentForMonth: query.month } : {}),
      ...(query.year ? { paymentForYear: query.year } : {}),
      ...(query.paymentMode ? { paymentMode: query.paymentMode } : {}),
      ...(search
        ? {
            OR: [
              { memberName: { contains: search, mode: 'insensitive' } },
              { memberPhone: { contains: search } },
            ],
          }
        : {}),
    };
    const { page, limit, skip, take } = pageArgs(query);
    const [rows, total] = await Promise.all([
      this.prisma.imamSalaryPayment.findMany({
        where,
        skip,
        take,
        orderBy: [{ paidAt: 'desc' }, { createdAt: 'desc' }],
        select: paymentSelect,
      }),
      this.prisma.imamSalaryPayment.count({ where }),
    ]);
    return paged(
      rows.map((row) => this.toPayment(row)),
      total,
      page,
      limit,
    );
  }

  async myHistory(query: MySalaryHistoryQueryDto, actor: AuthenticatedUser) {
    const masjidId = this.masjidId(actor);
    const items = await this.prisma.imamSalaryAssignment.findMany({
      where: { masjidId, memberId: actor.id },
      take: query.monthsBack ?? 6,
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
        payments: {
          orderBy: { paidAt: 'desc' },
          select: {
            id: true,
            amount: true,
            paymentMode: true,
            paidAt: true,
            note: true,
          },
        },
      },
    });
    return {
      items: items.map((item) => ({
        month: item.imamSalaryMonth.month,
        year: item.imamSalaryMonth.year,
        expectedAmount: toAmount(item.expectedAmount),
        paidAmount: toAmount(item.paidAmount),
        dueAmount: toAmount(item.dueAmount),
        status: item.status,
        payments: item.payments.map((payment) => ({
          ...payment,
          amount: toAmount(payment.amount),
        })),
      })),
    };
  }

  /**
   * Adds one payment to the month: totals by increment, counts by moving one
   * assignment from its old status to its new one. The status is rewritten
   * only when the new totals change it.
   */
  private async applyToMonth(
    tx: Prisma.TransactionClient,
    monthId: string,
    amount: Money,
    oldStatus: ImamSalaryAssignmentStatus,
    newStatus: ImamSalaryAssignmentStatus,
  ): Promise<void> {
    const countDeltas: Prisma.ImamSalaryMonthUpdateInput = {};
    if (oldStatus !== newStatus) {
      countDeltas[COUNT_FIELD[oldStatus]] = { decrement: 1 };
      countDeltas[COUNT_FIELD[newStatus]] = { increment: 1 };
    }
    const month = await tx.imamSalaryMonth.update({
      where: { id: monthId },
      data: {
        totalCollected: { increment: amount },
        totalDue: { decrement: amount },
        ...countDeltas,
      },
      select: { totalCollected: true, totalExpected: true, status: true },
    });
    const monthStatus = this.status(
      money(month.totalCollected),
      money(month.totalExpected),
    );
    if (monthStatus !== (month.status as string))
      await tx.imamSalaryMonth.update({
        where: { id: monthId },
        data: { status: monthStatus },
        select: { id: true },
      });
  }

  private status(paid: Money, expected: Money): ImamSalaryAssignmentStatus {
    if (paid.lessThanOrEqualTo(0)) return ImamSalaryAssignmentStatus.UNPAID;
    return paid.greaterThanOrEqualTo(expected)
      ? ImamSalaryAssignmentStatus.PAID
      : ImamSalaryAssignmentStatus.PARTIAL;
  }

  private async findMonth(
    id: string,
    masjidId: string,
    db: Db = this.prisma,
  ): Promise<MonthRow> {
    const month = await db.imamSalaryMonth.findFirst({
      where: { id, masjidId },
      select: monthSelect,
    });
    if (!month) {
      this.fail(
        'Salary month not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.IMAM_SALARY_NOT_FOUND,
      );
    }
    return month;
  }

  private masjidId(actor: AuthenticatedUser): string {
    return requireMasjidId(actor);
  }

  private fail(
    message: string,
    status = HttpStatus.BAD_REQUEST,
    errorCode: ErrorCode = ERROR_CODES.BAD_REQUEST,
  ): never {
    throw new ApiException(message, status, errorCode);
  }

  private toMonth(month: MonthRow) {
    return {
      ...month,
      amountPerHead: toAmount(month.amountPerHead),
      totalExpected: toAmount(month.totalExpected),
      totalCollected: toAmount(month.totalCollected),
      totalDue: toAmount(month.totalDue),
    };
  }

  private toAssignment(assignment: AssignmentRow) {
    return {
      ...assignment,
      expectedAmount: toAmount(assignment.expectedAmount),
      paidAmount: toAmount(assignment.paidAmount),
      dueAmount: toAmount(assignment.dueAmount),
    };
  }

  private toPayment(payment: PaymentRow) {
    return { ...payment, amount: toAmount(payment.amount) };
  }
}

import { HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { type Money, money, sumMoney, toAmount } from '../../../common/money';
import {
  Prisma,
  type ImamSalaryAssignment,
  type ImamSalaryMonth,
  type ImamSalaryPayment,
} from '../../../generated/prisma/client';
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

type Db = PrismaService | Prisma.TransactionClient;
type Pagination = { page?: number; limit?: number };

const SERIALIZABLE = {
  isolationLevel: Prisma.TransactionIsolationLevel.Serializable,
};

@Injectable()
export class ImamSalariesService {
  constructor(private readonly prisma: PrismaService) {}

  async createMonth(dto: CreateSalaryMonthDto, actor: AuthenticatedUser) {
    const masjidId = this.masjidId(actor);
    const amountPerHead = money(dto.amountPerHead);
    return this.prisma.$transaction(async (tx) => {
      const existing = await tx.imamSalaryMonth.findUnique({
        where: {
          masjidId_month_year: { masjidId, month: dto.month, year: dto.year },
        },
        select: { id: true },
      });
      if (existing)
        this.fail('Salary month already exists', HttpStatus.CONFLICT);
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
      return this.toMonth(month);
    }, SERIALIZABLE);
  }

  async listMonths(query: SalaryMonthsQueryDto, actor: AuthenticatedUser) {
    const where: Prisma.ImamSalaryMonthWhereInput = {
      masjidId: this.masjidId(actor),
      ...(query.month ? { month: query.month } : {}),
      ...(query.year ? { year: query.year } : {}),
    };
    const { page, limit, skip } = this.paging(query);
    const [rows, total] = await Promise.all([
      this.prisma.imamSalaryMonth.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ year: 'desc' }, { month: 'desc' }],
      }),
      this.prisma.imamSalaryMonth.count({ where }),
    ]);
    return this.envelope(
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
    await this.findMonth(id, masjidId);
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
    const { page, limit, skip } = this.paging(query);
    const [rows, total] = await Promise.all([
      this.prisma.imamSalaryAssignment.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ memberName: 'asc' }],
      }),
      this.prisma.imamSalaryAssignment.count({ where }),
    ]);
    return this.envelope(
      rows.map((row) => this.toAssignment(row)),
      total,
      page,
      limit,
    );
  }

  async updateAmount(
    id: string,
    dto: UpdateSalaryAmountDto,
    actor: AuthenticatedUser,
  ) {
    const masjidId = this.masjidId(actor);
    const amountPerHead = money(dto.amountPerHead);
    return this.prisma.$transaction(async (tx) => {
      const month = await this.findMonth(id, masjidId, tx);
      if (amountPerHead.lessThan(month.amountPerHead))
        this.fail('Monthly amount can only be increased');
      const assignments = await tx.imamSalaryAssignment.findMany({
        where: { imamSalaryMonthId: id },
        select: { id: true, paidAmount: true },
      });
      if (assignments.some((a) => amountPerHead.lessThan(a.paidAmount)))
        this.fail('Amount cannot be lower than an amount already paid');

      // Assignments with the same paid amount end up with the same
      // expected/due/status, so update them in one statement per paid amount.
      const byPaid = new Map<string, { paid: Money; ids: string[] }>();
      for (const assignment of assignments) {
        const paid = money(assignment.paidAmount);
        const key = paid.toFixed(2);
        const group = byPaid.get(key) ?? { paid, ids: [] };
        group.ids.push(assignment.id);
        byPaid.set(key, group);
      }
      for (const { paid, ids } of byPaid.values()) {
        await tx.imamSalaryAssignment.updateMany({
          where: { id: { in: ids } },
          data: {
            expectedAmount: amountPerHead,
            dueAmount: amountPerHead.minus(paid),
            status: this.status(paid, amountPerHead),
          },
        });
      }

      const reason = dto.reason?.trim();
      await tx.imamSalaryMonth.update({
        where: { id },
        data: {
          amountPerHead,
          note: reason
            ? [month.note, reason].filter(Boolean).join('\n')
            : month.note,
          updatedById: actor.id,
          updatedByName: actor.fullName,
        },
      });
      return this.recalculate(tx, id);
    }, SERIALIZABLE);
  }

  async addPayment(dto: CreateSalaryPaymentDto, actor: AuthenticatedUser) {
    const masjidId = this.masjidId(actor);
    const amount = money(dto.amount);
    return this.prisma.$transaction(async (tx) => {
      const assignment = await tx.imamSalaryAssignment.findFirst({
        where: { id: dto.assignmentId, masjidId },
        include: { imamSalaryMonth: { select: { month: true, year: true } } },
      });
      if (!assignment)
        this.fail('Salary assignment not found', HttpStatus.NOT_FOUND);
      if (amount.greaterThan(assignment.dueAmount))
        this.fail('Payment amount cannot exceed current due amount');
      const expected = money(assignment.expectedAmount);
      const paidAmount = money(assignment.paidAmount).plus(amount);
      const dueAmount = expected.minus(paidAmount);
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
      });
      await tx.imamSalaryAssignment.update({
        where: { id: assignment.id },
        data: {
          paidAmount,
          dueAmount,
          status: this.status(paidAmount, expected),
        },
      });
      await this.recalculate(tx, assignment.imamSalaryMonthId);
      return this.toPayment(payment);
    }, SERIALIZABLE);
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
    const { page, limit, skip } = this.paging(query);
    const [rows, total] = await Promise.all([
      this.prisma.imamSalaryPayment.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ paidAt: 'desc' }, { createdAt: 'desc' }],
      }),
      this.prisma.imamSalaryPayment.count({ where }),
    ]);
    return this.envelope(
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
      include: {
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

  /** Re-derives month totals, counts and status from its assignments. */
  private async recalculate(tx: Prisma.TransactionClient, id: string) {
    const rows = await tx.imamSalaryAssignment.findMany({
      where: { imamSalaryMonthId: id },
      select: {
        expectedAmount: true,
        paidAmount: true,
        dueAmount: true,
        status: true,
      },
    });
    const totalExpected = sumMoney(rows.map((r) => r.expectedAmount));
    const totalCollected = sumMoney(rows.map((r) => r.paidAmount));
    const count = (status: ImamSalaryAssignmentStatus) =>
      rows.filter((r) => r.status === status).length;
    const month = await tx.imamSalaryMonth.update({
      where: { id },
      data: {
        totalExpected,
        totalCollected,
        totalDue: sumMoney(rows.map((r) => r.dueAmount)),
        paidCount: count(ImamSalaryAssignmentStatus.PAID),
        partialCount: count(ImamSalaryAssignmentStatus.PARTIAL),
        unpaidCount: count(ImamSalaryAssignmentStatus.UNPAID),
        status: this.status(totalCollected, totalExpected),
      },
    });
    return this.toMonth(month);
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
  ): Promise<ImamSalaryMonth> {
    const month = await db.imamSalaryMonth.findFirst({
      where: { id, masjidId },
    });
    if (!month) this.fail('Salary month not found', HttpStatus.NOT_FOUND);
    return month;
  }

  /**
   * Same check as requireMasjidId() in common/tenant.ts, kept local so the
   * response keeps its current errorCode (BAD_REQUEST, see fail()).
   */
  private masjidId(actor: AuthenticatedUser): string {
    if (!actor.masjidId)
      this.fail(
        'Current user is not assigned to a masjid',
        HttpStatus.FORBIDDEN,
      );
    return actor.masjidId;
  }

  /** Note: stamps errorCode BAD_REQUEST on every status, 404/409/403 too. */
  private fail(message: string, status = HttpStatus.BAD_REQUEST): never {
    throw new ApiException(message, status, ERROR_CODES.BAD_REQUEST);
  }

  private paging(query: Pagination) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    return { page, limit, skip: (page - 1) * limit };
  }

  private envelope<T>(items: T[], total: number, page: number, limit: number) {
    const totalPages = Math.ceil(total / limit);
    return {
      items,
      total,
      page,
      limit,
      totalPages,
      hasNextPage: page < totalPages,
    };
  }

  private toMonth(month: ImamSalaryMonth) {
    return {
      ...month,
      amountPerHead: toAmount(month.amountPerHead),
      totalExpected: toAmount(month.totalExpected),
      totalCollected: toAmount(month.totalCollected),
      totalDue: toAmount(month.totalDue),
    };
  }

  private toAssignment(assignment: ImamSalaryAssignment) {
    return {
      ...assignment,
      expectedAmount: toAmount(assignment.expectedAmount),
      paidAmount: toAmount(assignment.paidAmount),
      dueAmount: toAmount(assignment.dueAmount),
    };
  }

  private toPayment(payment: ImamSalaryPayment) {
    return { ...payment, amount: toAmount(payment.amount) };
  }
}

import { HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import {
  AssignmentStatusDto,
  CreateSalaryMonthDto,
  CreateSalaryPaymentDto,
  MySalaryHistoryQueryDto,
  SalaryAssignmentsQueryDto,
  SalaryMonthsQueryDto,
  SalaryPaymentsQueryDto,
  UpdateSalaryAmountDto,
} from './dto/imam-salary-ledger.dto';

type DynamicDb = Record<string, any>;

@Injectable()
export class ImamSalariesService {
  constructor(private readonly prisma: PrismaService) {}
  private get db(): DynamicDb {
    return this.prisma as unknown as DynamicDb;
  }

  async createMonth(dto: CreateSalaryMonthDto, actor: AuthenticatedUser) {
    const masjidId = this.masjidId(actor);
    const existing = await this.db.imamSalaryMonth.findUnique({
      where: {
        masjidId_month_year: { masjidId, month: dto.month, year: dto.year },
      },
    });
    if (existing) this.fail('Salary month already exists', HttpStatus.CONFLICT);
    const heads = await this.db.user.findMany({
      where: {
        masjidId,
        status: 'ACTIVE',
        isFamilyHead: true,
        userRoles: { some: { role: { name: 'MEMBER' } } },
      },
      select: { id: true, fullName: true, phone: true },
    });
    return this.db.$transaction(
      async (tx: DynamicDb) => {
        const total = dto.amountPerHead * heads.length;
        const month = await tx.imamSalaryMonth.create({
          data: {
            masjidId,
            month: dto.month,
            year: dto.year,
            amountPerHead: dto.amountPerHead,
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
            data: heads.map(
              (member: {
                id: string;
                fullName: string;
                phone: string | null;
              }) => ({
                masjidId,
                imamSalaryMonthId: month.id,
                memberId: member.id,
                memberName: member.fullName,
                memberPhone: member.phone ?? '',
                expectedAmount: dto.amountPerHead,
                dueAmount: dto.amountPerHead,
              }),
            ),
          });
        return this.serialize(month);
      },
      { isolationLevel: 'Serializable' },
    );
  }

  async listMonths(query: SalaryMonthsQueryDto, actor: AuthenticatedUser) {
    const where = {
      masjidId: this.masjidId(actor),
      ...(query.month ? { month: query.month } : {}),
      ...(query.year ? { year: query.year } : {}),
    };
    return this.page(this.db.imamSalaryMonth, where, query, [
      { year: 'desc' },
      { month: 'desc' },
    ]);
  }
  async getMonth(id: string, actor: AuthenticatedUser) {
    return this.serialize(await this.month(id, this.masjidId(actor)));
  }

  async listAssignments(
    id: string,
    query: SalaryAssignmentsQueryDto,
    actor: AuthenticatedUser,
  ) {
    const masjidId = this.masjidId(actor);
    await this.month(id, masjidId);
    const search = query.search?.trim();
    const where = {
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
    return this.page(this.db.imamSalaryAssignment, where, query, [
      { memberName: 'asc' },
    ]);
  }

  async updateAmount(
    id: string,
    dto: UpdateSalaryAmountDto,
    actor: AuthenticatedUser,
  ) {
    const masjidId = this.masjidId(actor);
    return this.db.$transaction(
      async (tx: DynamicDb) => {
        const month = await this.month(id, masjidId, tx);
        if (dto.amountPerHead < Number(month.amountPerHead))
          this.fail('Monthly amount can only be increased');
        const assignments = await tx.imamSalaryAssignment.findMany({
          where: { imamSalaryMonthId: id },
        });
        for (const assignment of assignments) {
          const paid = Number(assignment.paidAmount);
          if (dto.amountPerHead < paid)
            this.fail('Amount cannot be lower than an amount already paid');
          const due = dto.amountPerHead - paid;
          await tx.imamSalaryAssignment.update({
            where: { id: assignment.id },
            data: {
              expectedAmount: dto.amountPerHead,
              dueAmount: due,
              status: this.status(paid, dto.amountPerHead),
            },
          });
        }
        await tx.imamSalaryMonth.update({
          where: { id },
          data: {
            amountPerHead: dto.amountPerHead,
            note: dto.reason?.trim()
              ? [month.note, dto.reason.trim()].filter(Boolean).join('\n')
              : month.note,
            updatedById: actor.id,
            updatedByName: actor.fullName,
          },
        });
        return this.recalculate(tx, id);
      },
      { isolationLevel: 'Serializable' },
    );
  }

  async addPayment(dto: CreateSalaryPaymentDto, actor: AuthenticatedUser) {
    const masjidId = this.masjidId(actor);
    return this.db.$transaction(
      async (tx: DynamicDb) => {
        const assignment = await tx.imamSalaryAssignment.findFirst({
          where: { id: dto.assignmentId, masjidId },
          include: { imamSalaryMonth: true },
        });
        if (!assignment)
          this.fail('Salary assignment not found', HttpStatus.NOT_FOUND);
        const due = Number(assignment.dueAmount);
        if (dto.amount > due)
          this.fail('Payment amount cannot exceed current due amount');
        const paidAmount = Number(assignment.paidAmount) + dto.amount;
        const dueAmount = Number(assignment.expectedAmount) - paidAmount;
        const payment = await tx.imamSalaryPayment.create({
          data: {
            masjidId,
            imamSalaryMonthId: assignment.imamSalaryMonthId,
            assignmentId: assignment.id,
            memberId: assignment.memberId,
            memberName: assignment.memberName,
            memberPhone: assignment.memberPhone,
            amount: dto.amount,
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
            status: this.status(paidAmount, Number(assignment.expectedAmount)),
          },
        });
        await this.recalculate(tx, assignment.imamSalaryMonthId);
        return this.serialize(payment);
      },
      { isolationLevel: 'Serializable' },
    );
  }

  async listPayments(query: SalaryPaymentsQueryDto, actor: AuthenticatedUser) {
    const search = query.search?.trim();
    const where = {
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
    return this.page(this.db.imamSalaryPayment, where, query, [
      { paidAt: 'desc' },
      { createdAt: 'desc' },
    ]);
  }

  async myHistory(query: MySalaryHistoryQueryDto, actor: AuthenticatedUser) {
    const masjidId = this.masjidId(actor);
    const take = query.monthsBack ?? 6;
    const items = await this.db.imamSalaryAssignment.findMany({
      where: { masjidId, memberId: actor.id },
      take,
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
      items: items.map((item: any) =>
        this.serialize({
          month: item.imamSalaryMonth.month,
          year: item.imamSalaryMonth.year,
          expectedAmount: item.expectedAmount,
          paidAmount: item.paidAmount,
          dueAmount: item.dueAmount,
          status: item.status,
          payments: item.payments,
        }),
      ),
    };
  }

  private async recalculate(tx: DynamicDb, id: string) {
    const rows = await tx.imamSalaryAssignment.findMany({
      where: { imamSalaryMonthId: id },
      select: {
        expectedAmount: true,
        paidAmount: true,
        dueAmount: true,
        status: true,
      },
    });
    const sum = (key: string) =>
      rows.reduce(
        (value: number, row: DynamicDb) => value + Number(row[key]),
        0,
      );
    const data = {
      totalExpected: sum('expectedAmount'),
      totalCollected: sum('paidAmount'),
      totalDue: sum('dueAmount'),
      paidCount: rows.filter((r: DynamicDb) => r.status === 'PAID').length,
      partialCount: rows.filter((r: DynamicDb) => r.status === 'PARTIAL')
        .length,
      unpaidCount: rows.filter((r: DynamicDb) => r.status === 'UNPAID').length,
    };
    return this.serialize(
      await tx.imamSalaryMonth.update({
        where: { id },
        data: {
          ...data,
          status: this.status(data.totalCollected, data.totalExpected),
        },
      }),
    );
  }
  private status(paid: number, expected: number): AssignmentStatusDto {
    return paid <= 0
      ? AssignmentStatusDto.UNPAID
      : paid >= expected
        ? AssignmentStatusDto.PAID
        : AssignmentStatusDto.PARTIAL;
  }
  private async month(id: string, masjidId: string, db: DynamicDb = this.db) {
    const month = await db.imamSalaryMonth.findFirst({
      where: { id, masjidId },
    });
    if (!month) this.fail('Salary month not found', HttpStatus.NOT_FOUND);
    return month;
  }
  private masjidId(actor: AuthenticatedUser) {
    if (!actor.masjidId)
      this.fail(
        'Current user is not assigned to a masjid',
        HttpStatus.FORBIDDEN,
      );
    return actor.masjidId as string;
  }
  private fail(message: string, status = HttpStatus.BAD_REQUEST): never {
    throw new ApiException(message, status, ERROR_CODES.BAD_REQUEST);
  }
  private async page(
    delegate: DynamicDb,
    where: DynamicDb,
    query: { page?: number; limit?: number },
    orderBy: DynamicDb[],
  ) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const [rows, total] = await Promise.all([
      delegate.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy,
      }),
      delegate.count({ where }),
    ]);
    const totalPages = Math.ceil(total / limit);
    return {
      items: rows.map((row: DynamicDb) => this.serialize(row)),
      total,
      page,
      limit,
      totalPages,
      hasNextPage: page < totalPages,
    };
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

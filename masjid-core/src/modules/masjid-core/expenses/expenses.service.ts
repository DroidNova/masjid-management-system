import { Logger, HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import {
  AUDIT_ACTION,
  AUDIT_ENTITY,
  AuditService,
} from '../../../common/audit/audit.service';
import { formatMoney, toAmount } from '../../../common/money';
import { requireMasjidId } from '../../../common/tenant';
import { Prisma } from '../../../generated/prisma/client';
import { FinanceEntryStatus } from '../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { GetExpensesQueryDto } from './dto/get-expenses-query.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';
import { pageArgs, paged } from '../../../common/pagination';
import { dateRange } from '../shared-date';

const expenseSelect = {
  id: true,
  masjidId: true,
  type: true,
  amount: true,
  title: true,
  description: true,
  spentAt: true,
  status: true,
  createdById: true,
  createdAt: true,
  updatedAt: true,
} as const satisfies Prisma.ExpenseSelect;

type ExpenseRecord = Prisma.ExpenseGetPayload<{
  select: typeof expenseSelect;
}>;

type ExpenseResponse = Omit<ExpenseRecord, 'amount'> & { amount: number };

type Db = PrismaService | Prisma.TransactionClient;

@Injectable()
export class ExpensesService {
  private readonly logger = new Logger(ExpensesService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
  ) {}

  async findMyMasjidExpenses(
    query: GetExpensesQueryDto,
    actor: AuthenticatedUser,
  ) {
    const masjidId = requireMasjidId(actor);
    const { page, limit, skip, take } = pageArgs(query);
    const where = this.buildWhere(masjidId, query);

    const [items, total] = await Promise.all([
      this.prisma.expense.findMany({
        where,
        skip,
        take,
        orderBy: { spentAt: 'desc' },
        select: expenseSelect,
      }),
      this.prisma.expense.count({ where }),
    ]);

    return paged(
      items.map((item) => this.toResponse(item)),
      total,
      page,
      limit,
    );
  }

  async create(
    dto: CreateExpenseDto,
    actor: AuthenticatedUser,
  ): Promise<ExpenseResponse> {
    const masjidId = requireMasjidId(actor);
    const expense = await this.prisma.$transaction(async (tx) => {
      const created = await tx.expense.create({
        data: {
          masjidId,
          createdById: actor.id,
          type: dto.type,
          amount: dto.amount,
          ...(dto.title !== undefined ? { title: dto.title } : {}),
          ...(dto.description !== undefined
            ? { description: dto.description }
            : {}),
          ...(dto.spentAt ? { spentAt: new Date(dto.spentAt) } : {}),
        },
        select: expenseSelect,
      });
      await this.audit.record(
        {
          masjidId,
          actor,
          action: AUDIT_ACTION.CREATE,
          entity: AUDIT_ENTITY.EXPENSE,
          entityId: created.id,
          summary: this.auditSummary(created),
          after: created,
        },
        tx,
      );
      return created;
    });

    this.logger.log({
      message: 'Expense created',
      expenseId: expense.id,
      masjidId,
    });
    return this.toResponse(expense);
  }

  async findOne(
    id: string,
    actor: AuthenticatedUser,
  ): Promise<ExpenseResponse> {
    const masjidId = requireMasjidId(actor);
    const expense = await this.findScoped(this.prisma, id, masjidId);
    return this.toResponse(expense);
  }

  async update(
    id: string,
    dto: UpdateExpenseDto,
    actor: AuthenticatedUser,
  ): Promise<ExpenseResponse> {
    const masjidId = requireMasjidId(actor);
    const data = this.buildUpdateData(dto);

    if (Object.keys(data).length === 0) {
      throw new ApiException(
        'At least one expense field must be provided',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }

    const expense = await this.prisma.$transaction(async (tx) => {
      const before = await this.findScoped(tx, id, masjidId);
      const updated = await tx.expense.update({
        where: { id: before.id },
        data,
        select: expenseSelect,
      });
      await this.audit.record(
        {
          masjidId,
          actor,
          action: AUDIT_ACTION.UPDATE,
          entity: AUDIT_ENTITY.EXPENSE,
          entityId: updated.id,
          summary: this.auditSummary(updated),
          before,
          after: updated,
        },
        tx,
      );
      return updated;
    });
    this.logger.log({
      message: 'Expense updated',
      expenseId: expense.id,
      masjidId,
    });
    return this.toResponse(expense);
  }

  /**
   * Cancels (soft-deletes) an expense. Cancelling an already cancelled
   * entry returns it unchanged and writes no audit entry.
   */
  async cancel(id: string, actor: AuthenticatedUser): Promise<ExpenseResponse> {
    const masjidId = requireMasjidId(actor);
    const { expense, changed } = await this.prisma.$transaction(async (tx) => {
      const before = await this.findScoped(tx, id, masjidId);
      if (before.status === FinanceEntryStatus.CANCELLED) {
        return { expense: before, changed: false };
      }
      const cancelled = await tx.expense.update({
        where: { id: before.id },
        data: { status: FinanceEntryStatus.CANCELLED },
        select: expenseSelect,
      });
      await this.audit.record(
        {
          masjidId,
          actor,
          action: AUDIT_ACTION.CANCEL,
          entity: AUDIT_ENTITY.EXPENSE,
          entityId: cancelled.id,
          summary: `${this.auditSummary(cancelled)} cancelled`,
          before,
          after: cancelled,
        },
        tx,
      );
      return { expense: cancelled, changed: true };
    });
    if (changed) {
      this.logger.warn({
        message: 'Expense cancelled',
        expenseId: expense.id,
        masjidId,
      });
    }
    return this.toResponse(expense);
  }

  /** The expense with this id in this masjid; 404 otherwise (also for another masjid's id). */
  private async findScoped(
    db: Db,
    id: string,
    masjidId: string,
  ): Promise<ExpenseRecord> {
    const expense = await db.expense.findFirst({
      where: { id, masjidId },
      select: expenseSelect,
    });

    if (!expense) {
      throw new ApiException(
        'Expense not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.EXPENSE_NOT_FOUND,
      );
    }

    return expense;
  }

  private buildWhere(
    masjidId: string,
    query: GetExpensesQueryDto,
  ): Prisma.ExpenseWhereInput {
    const where: Prisma.ExpenseWhereInput = { masjidId };
    if (query.type !== undefined) where.type = query.type;
    if (query.status !== undefined) where.status = query.status;
    const spentAt = dateRange(query.fromDate, query.toDate);
    if (spentAt) where.spentAt = spentAt;
    if (query.search) {
      where.OR = [
        { title: { contains: query.search, mode: 'insensitive' } },
        { description: { contains: query.search, mode: 'insensitive' } },
      ];
    }
    return where;
  }

  private buildUpdateData(dto: UpdateExpenseDto): Prisma.ExpenseUpdateInput {
    const data: Prisma.ExpenseUpdateInput = {};
    if (dto.type !== undefined) data.type = dto.type;
    if (dto.amount !== undefined) data.amount = dto.amount;
    if (dto.title !== undefined) data.title = dto.title;
    if (dto.description !== undefined) data.description = dto.description;
    if (dto.spentAt !== undefined) data.spentAt = new Date(dto.spentAt);
    return data;
  }

  private auditSummary(expense: ExpenseRecord): string {
    return `Expense ${expense.type} ${formatMoney(expense.amount)}`;
  }

  private toResponse(expense: ExpenseRecord): ExpenseResponse {
    return { ...expense, amount: toAmount(expense.amount) };
  }
}

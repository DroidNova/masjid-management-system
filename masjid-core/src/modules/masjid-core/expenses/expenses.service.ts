import { Logger, HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import {
  CreateExpenseDto,
  ExpenseTypeDto,
  FinanceEntryStatusDto,
} from './dto/create-expense.dto';
import { GetExpensesQueryDto } from './dto/get-expenses-query.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';

type DecimalLike =
  | number
  | string
  | { toNumber?: () => number; toString: () => string };

type ExpenseRecord = {
  id: string;
  masjidId: string;
  type: string;
  amount: DecimalLike;
  title: string | null;
  description: string | null;
  spentAt: Date;
  status: string;
  createdById: string | null;
  createdAt: Date;
  updatedAt: Date;
};

type ExpenseResponse = Omit<ExpenseRecord, 'amount'> & { amount: number };

type ExpenseWhereInput = {
  masjidId: string;
  type?: ExpenseTypeDto;
  status?: FinanceEntryStatusDto;
  spentAt?: { gte?: Date; lte?: Date };
  OR?: Array<{
    title?: { contains: string; mode: 'insensitive' };
    description?: { contains: string; mode: 'insensitive' };
  }>;
};

type ExpenseCreateData = {
  masjidId: string;
  createdById: string;
  type: ExpenseTypeDto;
  amount: number;
  title?: string;
  description?: string;
  spentAt?: Date;
};

type ExpenseUpdateData = Partial<{
  type: ExpenseTypeDto;
  amount: number;
  title: string | null;
  description: string | null;
  spentAt: Date;
  status: FinanceEntryStatusDto;
}>;

type ExpensesDelegate = {
  findMany(args: {
    where: ExpenseWhereInput;
    skip: number;
    take: number;
    orderBy: { spentAt: 'desc' };
    select: typeof expenseSelect;
  }): Promise<ExpenseRecord[]>;
  count(args: { where: ExpenseWhereInput }): Promise<number>;
  create(args: {
    data: ExpenseCreateData;
    select: typeof expenseSelect;
  }): Promise<ExpenseRecord>;
  findUnique(args: {
    where: { id: string };
    select: typeof expenseSelect;
  }): Promise<ExpenseRecord | null>;
  update(args: {
    where: { id: string };
    data: ExpenseUpdateData;
    select: typeof expenseSelect;
  }): Promise<ExpenseRecord>;
};

type ExpensesPrismaDelegate = {
  expense: ExpensesDelegate;
};

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
} as const;

@Injectable()
export class ExpensesService {
  private readonly logger = new Logger(ExpensesService.name);

  constructor(private readonly prisma: PrismaService) {}

  private get db(): ExpensesPrismaDelegate {
    return this.prisma as unknown as ExpensesPrismaDelegate;
  }

  async findMyMasjidExpenses(
    query: GetExpensesQueryDto,
    actor: AuthenticatedUser,
  ) {
    const masjidId = this.getCurrentUserMasjidId(actor);
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const where = this.buildWhere(masjidId, query);

    const [items, total] = await Promise.all([
      this.db.expense.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { spentAt: 'desc' },
        select: expenseSelect,
      }),
      this.db.expense.count({ where }),
    ]);

    return {
      items: items.map((item) => this.toResponse(item)),
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  }

  async create(
    dto: CreateExpenseDto,
    actor: AuthenticatedUser,
  ): Promise<ExpenseResponse> {
    const masjidId = this.getCurrentUserMasjidId(actor);
    const expense = await this.db.expense.create({
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

    this.logger.log({ message: 'Expense created', expenseId: expense.id, masjidId });
    return this.toResponse(expense);
  }

  async findOne(
    id: string,
    actor: AuthenticatedUser,
  ): Promise<ExpenseResponse> {
    const masjidId = this.getCurrentUserMasjidId(actor);
    const expense = await this.ensureExpenseBelongsToMasjid(id, masjidId);
    return this.toResponse(expense);
  }

  async update(
    id: string,
    dto: UpdateExpenseDto,
    actor: AuthenticatedUser,
  ): Promise<ExpenseResponse> {
    const masjidId = this.getCurrentUserMasjidId(actor);
    await this.ensureExpenseBelongsToMasjid(id, masjidId);
    const data = this.buildUpdateData(dto);

    if (Object.keys(data).length === 0) {
      throw new ApiException(
        'At least one expense field must be provided',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }

    const expense = await this.db.expense.update({
      where: { id },
      data,
      select: expenseSelect,
    });
    this.logger.log({ message: 'Expense updated', expenseId: expense.id, masjidId });
    return this.toResponse(expense);
  }

  async cancel(id: string, actor: AuthenticatedUser): Promise<ExpenseResponse> {
    const masjidId = this.getCurrentUserMasjidId(actor);
    await this.ensureExpenseBelongsToMasjid(id, masjidId);
    const expense = await this.db.expense.update({
      where: { id },
      data: { status: FinanceEntryStatusDto.CANCELLED },
      select: expenseSelect,
    });
    this.logger.warn({ message: 'Expense cancelled', expenseId: expense.id, masjidId });
    return this.toResponse(expense);
  }

  private getCurrentUserMasjidId(actor: AuthenticatedUser): string {
    if (!actor.masjidId) {
      throw new ApiException(
        'Current user is not assigned to a masjid',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.USER_MASJID_NOT_ASSIGNED,
      );
    }

    return actor.masjidId;
  }

  private async ensureExpenseBelongsToMasjid(
    id: string,
    masjidId: string,
  ): Promise<ExpenseRecord> {
    const expense = await this.db.expense.findUnique({
      where: { id },
      select: expenseSelect,
    });

    if (!expense) {
      throw new ApiException(
        'Expense not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.EXPENSE_NOT_FOUND,
      );
    }

    if (expense.masjidId !== masjidId) {
      throw new ApiException(
        'You are not allowed to access this finance entry',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.FINANCE_ACCESS_FORBIDDEN,
      );
    }

    return expense;
  }

  private buildWhere(
    masjidId: string,
    query: GetExpensesQueryDto,
  ): ExpenseWhereInput {
    const where: ExpenseWhereInput = { masjidId };
    if (query.type !== undefined) where.type = query.type;
    if (query.status !== undefined) where.status = query.status;
    if (query.fromDate || query.toDate) {
      where.spentAt = {};
      if (query.fromDate) where.spentAt.gte = new Date(query.fromDate);
      if (query.toDate) where.spentAt.lte = new Date(query.toDate);
    }
    if (query.search) {
      where.OR = [
        { title: { contains: query.search, mode: 'insensitive' } },
        { description: { contains: query.search, mode: 'insensitive' } },
      ];
    }
    return where;
  }

  private buildUpdateData(dto: UpdateExpenseDto): ExpenseUpdateData {
    const data: ExpenseUpdateData = {};
    if (dto.type !== undefined) data.type = dto.type;
    if (dto.amount !== undefined) data.amount = dto.amount;
    if (dto.title !== undefined) data.title = dto.title;
    if (dto.description !== undefined) data.description = dto.description;
    if (dto.spentAt !== undefined) data.spentAt = new Date(dto.spentAt);
    if (dto.status !== undefined) data.status = dto.status;
    return data;
  }

  private toResponse(expense: ExpenseRecord): ExpenseResponse {
    return { ...expense, amount: this.toNumber(expense.amount) };
  }

  private toNumber(value: DecimalLike): number {
    if (typeof value === 'number') return value;
    if (typeof value === 'string') return Number(value);
    if (typeof value.toNumber === 'function') return value.toNumber();
    return Number(value.toString());
  }
}

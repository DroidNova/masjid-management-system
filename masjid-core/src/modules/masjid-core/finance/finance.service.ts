import { HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';

type DecimalLike =
  | number
  | string
  | { toNumber?: () => number; toString: () => string };

type FinanceSummaryQuery = {
  fromDate?: string;
  toDate?: string;
  month?: number;
  year?: number;
};

type DateRange = { gte?: Date; lte?: Date };

type FinanceWhereInput = {
  masjidId: string;
  status: 'ACTIVE';
  collectedAt?: DateRange;
  spentAt?: DateRange;
};

type AggregateResult = { _sum: { amount: DecimalLike | null } };

type FinanceAggregateDelegate = {
  aggregate(args: {
    where: FinanceWhereInput;
    _sum: { amount: true };
  }): Promise<AggregateResult>;
};

type FinancePrismaDelegate = {
  collection: FinanceAggregateDelegate;
  expense: FinanceAggregateDelegate;
};

@Injectable()
export class FinanceService {
  constructor(private readonly prisma: PrismaService) {}

  private get db(): FinancePrismaDelegate {
    return this.prisma as unknown as FinancePrismaDelegate;
  }

  async getMyMasjidSummary(
    query: FinanceSummaryQuery,
    actor: AuthenticatedUser,
  ) {
    const masjidId = this.getCurrentUserMasjidId(actor);
    const period = this.resolvePeriod(query);
    const totalCollectionWhere = { masjidId, status: 'ACTIVE' as const };
    const totalExpenseWhere = { masjidId, status: 'ACTIVE' as const };
    const periodCollectionWhere = {
      ...totalCollectionWhere,
      ...(period ? { collectedAt: period } : {}),
    };
    const periodExpenseWhere = {
      ...totalExpenseWhere,
      ...(period ? { spentAt: period } : {}),
    };

    const [
      totalCollection,
      totalExpense,
      thisMonthCollection,
      thisMonthExpense,
    ] = await Promise.all([
      this.sumCollection(totalCollectionWhere),
      this.sumExpense(totalExpenseWhere),
      this.sumCollection(periodCollectionWhere),
      this.sumExpense(periodExpenseWhere),
    ]);

    return {
      totalCollection,
      totalExpense,
      currentBalance: totalCollection - totalExpense,
      thisMonthCollection,
      thisMonthExpense,
      thisMonthBalance: thisMonthCollection - thisMonthExpense,
      period: period
        ? {
            fromDate: period.gte?.toISOString() ?? null,
            toDate: period.lte?.toISOString() ?? null,
          }
        : null,
    };
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

  private resolvePeriod(query: FinanceSummaryQuery): DateRange | null {
    if (query.month !== undefined && query.year !== undefined) {
      const fromDate = new Date(Date.UTC(query.year, query.month - 1, 1));
      const toDate = new Date(
        Date.UTC(query.year, query.month, 0, 23, 59, 59, 999),
      );
      return { gte: fromDate, lte: toDate };
    }

    if (query.fromDate || query.toDate) {
      return {
        ...(query.fromDate ? { gte: new Date(query.fromDate) } : {}),
        ...(query.toDate ? { lte: new Date(query.toDate) } : {}),
      };
    }

    const now = new Date();
    const fromDate = new Date(
      Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1),
    );
    const toDate = new Date(
      Date.UTC(now.getUTCFullYear(), now.getUTCMonth() + 1, 0, 23, 59, 59, 999),
    );
    return { gte: fromDate, lte: toDate };
  }

  private async sumCollection(where: FinanceWhereInput): Promise<number> {
    const result = await this.db.collection.aggregate({
      where,
      _sum: { amount: true },
    });
    return this.toNumber(result._sum.amount);
  }

  private async sumExpense(where: FinanceWhereInput): Promise<number> {
    const result = await this.db.expense.aggregate({
      where,
      _sum: { amount: true },
    });
    return this.toNumber(result._sum.amount);
  }

  private toNumber(value: DecimalLike | null): number {
    if (value === null) return 0;
    if (typeof value === 'number') return value;
    if (typeof value === 'string') return Number(value);
    if (typeof value.toNumber === 'function') return value.toNumber();
    return Number(value.toString());
  }
}

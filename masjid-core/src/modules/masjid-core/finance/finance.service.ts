import { Injectable } from '@nestjs/common';
import { money, toAmount } from '../../../common/money';
import { requireMasjidId } from '../../../common/tenant';
import { Prisma } from '../../../generated/prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';

type FinanceSummaryQuery = {
  fromDate?: string;
  toDate?: string;
  month?: number;
  year?: number;
};

type DateRange = { gte?: Date; lte?: Date };

@Injectable()
export class FinanceService {
  constructor(private readonly prisma: PrismaService) {}

  async getMyMasjidSummary(
    query: FinanceSummaryQuery,
    actor: AuthenticatedUser,
  ) {
    const masjidId = requireMasjidId(actor);
    const period = this.resolvePeriod(query);
    const totalCollectionWhere: Prisma.CollectionWhereInput = {
      masjidId,
      status: 'ACTIVE',
    };
    const totalExpenseWhere: Prisma.ExpenseWhereInput = {
      masjidId,
      status: 'ACTIVE',
    };
    const periodCollectionWhere: Prisma.CollectionWhereInput = {
      ...totalCollectionWhere,
      ...(period ? { collectedAt: period } : {}),
    };
    const periodExpenseWhere: Prisma.ExpenseWhereInput = {
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
      totalCollection: toAmount(totalCollection),
      totalExpense: toAmount(totalExpense),
      currentBalance: toAmount(totalCollection.minus(totalExpense)),
      thisMonthCollection: toAmount(thisMonthCollection),
      thisMonthExpense: toAmount(thisMonthExpense),
      thisMonthBalance: toAmount(thisMonthCollection.minus(thisMonthExpense)),
      period: period
        ? {
            fromDate: period.gte?.toISOString() ?? null,
            toDate: period.lte?.toISOString() ?? null,
          }
        : null,
    };
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

  private async sumCollection(where: Prisma.CollectionWhereInput) {
    const result = await this.prisma.collection.aggregate({
      where,
      _sum: { amount: true },
    });
    return money(result._sum.amount);
  }

  private async sumExpense(where: Prisma.ExpenseWhereInput) {
    const result = await this.prisma.expense.aggregate({
      where,
      _sum: { amount: true },
    });
    return money(result._sum.amount);
  }
}

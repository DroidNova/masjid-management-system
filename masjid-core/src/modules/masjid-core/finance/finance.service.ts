import { Injectable } from '@nestjs/common';
import { toAmount } from '../../../common/money';
import { requireMasjidId } from '../../../common/tenant';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import {
  DateRange,
  FinanceCalculator,
  totalsToResponse,
} from './finance-calculator';

type FinanceSummaryQuery = {
  fromDate?: string;
  toDate?: string;
  month?: number;
  year?: number;
};

@Injectable()
export class FinanceService {
  constructor(private readonly calculator: FinanceCalculator) {}

  /**
   * Money summary for the signed-in user's masjid.
   *
   * `totalCollection` is all money received (general collections + project
   * contributions + imam-salary payments); `breakdown` shows each part.
   * The "thisMonth*" fields cover the requested period (default: this month).
   */
  async getMyMasjidSummary(
    query: FinanceSummaryQuery,
    actor: AuthenticatedUser,
  ) {
    const masjidId = requireMasjidId(actor);
    const period = this.resolvePeriod(query);

    const { total, period: inPeriod } = await this.calculator.summary(
      masjidId,
      period,
    );

    return {
      totalCollection: toAmount(total.income),
      totalExpense: toAmount(total.expenses),
      currentBalance: toAmount(total.balance),
      thisMonthCollection: toAmount(inPeriod.income),
      thisMonthExpense: toAmount(inPeriod.expenses),
      thisMonthBalance: toAmount(inPeriod.balance),
      breakdown: {
        total: totalsToResponse(total),
        period: totalsToResponse(inPeriod),
      },
      period: {
        fromDate: period.gte?.toISOString() ?? null,
        toDate: period.lte?.toISOString() ?? null,
      },
    };
  }

  private resolvePeriod(query: FinanceSummaryQuery): DateRange {
    if (query.month !== undefined && query.year !== undefined) {
      return {
        gte: new Date(Date.UTC(query.year, query.month - 1, 1)),
        lte: new Date(Date.UTC(query.year, query.month, 0, 23, 59, 59, 999)),
      };
    }

    if (query.fromDate || query.toDate) {
      return {
        ...(query.fromDate ? { gte: new Date(query.fromDate) } : {}),
        ...(query.toDate ? { lte: new Date(query.toDate) } : {}),
      };
    }

    return this.calculator.currentMonth();
  }
}

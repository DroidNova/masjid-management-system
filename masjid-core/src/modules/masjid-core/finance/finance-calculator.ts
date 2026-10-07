import { Injectable } from '@nestjs/common';
import { Money, money, toAmount } from '../../../common/money';
import { PrismaService } from '../../../prisma/prisma.service';

export type DateRange = { gte?: Date; lte?: Date };

/** Money in and out of a masjid for a period (or all time). */
export type FinanceTotals = {
  /** Collections (Jumma, donation box, zakat, ...), including recorded collection contributions. */
  generalCollections: Money;
  /** Money received for projects (ProjectContribution). */
  projectContributions: Money;
  /** Money families paid towards the imam's salary (ImamSalaryPayment). */
  imamSalaryCollected: Money;
  /** Sum of the three above. */
  income: Money;
  /** Active expenses, including the salary paid out to the imam (type IMAM_SALARY). */
  expenses: Money;
  /** income - expenses: the cash the masjid should hold. */
  balance: Money;
};

/**
 * One place that answers "how much money came in and went out".
 *
 * Every source of money received is counted: general collections, project
 * contributions and imam-salary payments. Spending is recorded as expenses
 * (including the salary handed to the imam and project spending), so the
 * balance is the cash the committee should be holding.
 *
 * Cancelled collections and expenses are excluded. Contributions and salary
 * payments cannot be cancelled today.
 */
@Injectable()
export class FinanceCalculator {
  constructor(private readonly prisma: PrismaService) {}

  async totals(masjidId: string, period?: DateRange): Promise<FinanceTotals> {
    const [collections, projects, salary, expenses] = await Promise.all([
      this.prisma.collection.aggregate({
        where: {
          masjidId,
          status: 'ACTIVE',
          ...(period ? { collectedAt: period } : {}),
        },
        _sum: { amount: true },
      }),
      this.prisma.projectContribution.aggregate({
        where: { masjidId, ...(period ? { paidAt: period } : {}) },
        _sum: { amount: true },
      }),
      this.prisma.imamSalaryPayment.aggregate({
        where: { masjidId, ...(period ? { paidAt: period } : {}) },
        _sum: { amount: true },
      }),
      this.prisma.expense.aggregate({
        where: {
          masjidId,
          status: 'ACTIVE',
          ...(period ? { spentAt: period } : {}),
        },
        _sum: { amount: true },
      }),
    ]);

    const generalCollections = money(collections._sum.amount);
    const projectContributions = money(projects._sum.amount);
    const imamSalaryCollected = money(salary._sum.amount);
    const income = generalCollections
      .plus(projectContributions)
      .plus(imamSalaryCollected);
    const spent = money(expenses._sum.amount);

    return {
      generalCollections,
      projectContributions,
      imamSalaryCollected,
      income,
      expenses: spent,
      balance: income.minus(spent),
    };
  }

  /** The current calendar month in UTC. */
  currentMonth(): DateRange {
    const now = new Date();
    return {
      gte: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1)),
      lte: new Date(
        Date.UTC(
          now.getUTCFullYear(),
          now.getUTCMonth() + 1,
          0,
          23,
          59,
          59,
          999,
        ),
      ),
    };
  }
}

/** JSON shape of FinanceTotals for API responses. */
export function totalsToResponse(totals: FinanceTotals) {
  return {
    generalCollections: toAmount(totals.generalCollections),
    projectContributions: toAmount(totals.projectContributions),
    imamSalaryCollected: toAmount(totals.imamSalaryCollected),
    income: toAmount(totals.income),
    expenses: toAmount(totals.expenses),
    balance: toAmount(totals.balance),
  };
}

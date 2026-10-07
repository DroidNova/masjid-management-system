import { Injectable } from '@nestjs/common';
import { Money, MoneyInput, money, toAmount } from '../../../common/money';
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

  /** Totals for all time and for [period], from ONE SQL statement. */
  async summary(
    masjidId: string,
    period: DateRange,
  ): Promise<{ total: FinanceTotals; period: FinanceTotals }> {
    // Open-ended periods use far-away bounds so the FILTER stays simple.
    const from = period.gte ?? new Date(0);
    const to = period.lte ?? new Date('9999-12-31T23:59:59.999Z');

    const [row] = await this.prisma.$queryRaw<SumsRow[]>`
      SELECT c."all"  AS "collectionsAll",  c."period"  AS "collectionsPeriod",
             pc."all" AS "projectsAll",     pc."period" AS "projectsPeriod",
             sp."all" AS "salaryAll",       sp."period" AS "salaryPeriod",
             e."all"  AS "expensesAll",     e."period"  AS "expensesPeriod"
      FROM
        (SELECT COALESCE(SUM("amount"), 0) AS "all",
                COALESCE(SUM("amount") FILTER (WHERE "collectedAt" BETWEEN ${from} AND ${to}), 0) AS "period"
           FROM "Collection" WHERE "masjidId" = ${masjidId}::uuid AND "status" = 'ACTIVE') c,
        (SELECT COALESCE(SUM("amount"), 0) AS "all",
                COALESCE(SUM("amount") FILTER (WHERE "paidAt" BETWEEN ${from} AND ${to}), 0) AS "period"
           FROM "ProjectContribution" WHERE "masjidId" = ${masjidId}::uuid) pc,
        (SELECT COALESCE(SUM("amount"), 0) AS "all",
                COALESCE(SUM("amount") FILTER (WHERE "paidAt" BETWEEN ${from} AND ${to}), 0) AS "period"
           FROM "ImamSalaryPayment" WHERE "masjidId" = ${masjidId}::uuid) sp,
        (SELECT COALESCE(SUM("amount"), 0) AS "all",
                COALESCE(SUM("amount") FILTER (WHERE "spentAt" BETWEEN ${from} AND ${to}), 0) AS "period"
           FROM "Expense" WHERE "masjidId" = ${masjidId}::uuid AND "status" = 'ACTIVE') e
    `;

    return {
      total: build(
        row.collectionsAll,
        row.projectsAll,
        row.salaryAll,
        row.expensesAll,
      ),
      period: build(
        row.collectionsPeriod,
        row.projectsPeriod,
        row.salaryPeriod,
        row.expensesPeriod,
      ),
    };
  }

  /** Totals for one period (or all time). Prefer [summary] when you need both. */
  async totals(masjidId: string, period?: DateRange): Promise<FinanceTotals> {
    const result = await this.summary(masjidId, period ?? {});
    return period ? result.period : result.total;
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

type SumsRow = Record<
  | 'collectionsAll'
  | 'collectionsPeriod'
  | 'projectsAll'
  | 'projectsPeriod'
  | 'salaryAll'
  | 'salaryPeriod'
  | 'expensesAll'
  | 'expensesPeriod',
  MoneyInput
>;

function build(
  collections: MoneyInput,
  projects: MoneyInput,
  salary: MoneyInput,
  spentInput: MoneyInput,
): FinanceTotals {
  const generalCollections = money(collections);
  const projectContributions = money(projects);
  const imamSalaryCollected = money(salary);
  const income = generalCollections
    .plus(projectContributions)
    .plus(imamSalaryCollected);
  const expenses = money(spentInput);
  return {
    generalCollections,
    projectContributions,
    imamSalaryCollected,
    income,
    expenses,
    balance: income.minus(expenses),
  };
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

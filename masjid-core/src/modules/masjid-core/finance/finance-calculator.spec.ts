import { Prisma } from '../../../generated/prisma/client';
import { FinanceCalculator, totalsToResponse } from './finance-calculator';

const d = (value: string) => new Prisma.Decimal(value);

/** What the single SUM query returns (numeric columns arrive as Decimal). */
function calculatorReturning(row: Record<string, Prisma.Decimal>) {
  const prisma = { $queryRaw: jest.fn().mockResolvedValue([row]) };
  return { calculator: new FinanceCalculator(prisma as never), prisma };
}

const scenarioRow = {
  collectionsAll: d('2378.12'),
  collectionsPeriod: d('300.10'),
  projectsAll: d('3500.30'),
  projectsPeriod: d('0'),
  salaryAll: d('700.75'),
  salaryPeriod: d('200.25'),
  expensesAll: d('845.30'),
  expensesPeriod: d('99.99'),
};

describe('FinanceCalculator', () => {
  it('computes all-time and period totals from one query, exactly', async () => {
    const { calculator, prisma } = calculatorReturning(scenarioRow);

    const result = await calculator.summary('m1', calculator.currentMonth());

    expect(prisma.$queryRaw).toHaveBeenCalledTimes(1);
    // Numbers from the end-to-end scenario: before M3 only 2378.12 was counted.
    expect(totalsToResponse(result.total)).toEqual({
      generalCollections: 2378.12,
      projectContributions: 3500.3,
      imamSalaryCollected: 700.75,
      income: 6579.17,
      expenses: 845.3,
      balance: 5733.87,
    });
    expect(totalsToResponse(result.period)).toEqual({
      generalCollections: 300.1,
      projectContributions: 0,
      imamSalaryCollected: 200.25,
      income: 500.35,
      expenses: 99.99,
      balance: 400.36,
    });
  });

  it('totals() returns the period or all-time side of the same query', async () => {
    const { calculator, prisma } = calculatorReturning(scenarioRow);

    const all = totalsToResponse(await calculator.totals('m1'));
    const month = totalsToResponse(
      await calculator.totals('m1', calculator.currentMonth()),
    );

    expect(all.income).toBe(6579.17);
    expect(month.income).toBe(500.35);
    expect(prisma.$queryRaw).toHaveBeenCalledTimes(2);
  });

  it('can go negative when more was spent than received', async () => {
    const { calculator } = calculatorReturning({
      ...scenarioRow,
      collectionsAll: d('0'),
      projectsAll: d('0'),
      salaryAll: d('0'),
      expensesAll: d('10'),
    });
    const { total } = await calculator.summary('m1', {});
    expect(totalsToResponse(total).balance).toBe(-10);
  });
});

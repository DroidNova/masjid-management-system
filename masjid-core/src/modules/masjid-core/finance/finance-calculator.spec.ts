import { Prisma } from '../../../generated/prisma/client';
import { FinanceCalculator, totalsToResponse } from './finance-calculator';

const sum = (value: string | null) => ({
  _sum: { amount: value === null ? null : new Prisma.Decimal(value) },
});

function calculatorWith(values: {
  collections: string | null;
  projects: string | null;
  salary: string | null;
  expenses: string | null;
}) {
  const prisma = {
    collection: {
      aggregate: jest.fn().mockResolvedValue(sum(values.collections)),
    },
    projectContribution: {
      aggregate: jest.fn().mockResolvedValue(sum(values.projects)),
    },
    imamSalaryPayment: {
      aggregate: jest.fn().mockResolvedValue(sum(values.salary)),
    },
    expense: { aggregate: jest.fn().mockResolvedValue(sum(values.expenses)) },
  };
  return { calculator: new FinanceCalculator(prisma as never), prisma };
}

describe('FinanceCalculator', () => {
  it('counts every source of money received, exactly', async () => {
    // Numbers from the end-to-end scenario: before M3 only 2378.12 was counted.
    const { calculator } = calculatorWith({
      collections: '2378.12',
      projects: '3500.30',
      salary: '700.75',
      expenses: '845.30',
    });

    const totals = totalsToResponse(await calculator.totals('m1'));

    expect(totals).toEqual({
      generalCollections: 2378.12,
      projectContributions: 3500.3,
      imamSalaryCollected: 700.75,
      income: 6579.17,
      expenses: 845.3,
      balance: 5733.87,
    });
  });

  it('treats missing sums as zero', async () => {
    const { calculator } = calculatorWith({
      collections: null,
      projects: null,
      salary: null,
      expenses: '10',
    });
    const totals = totalsToResponse(await calculator.totals('m1'));
    expect(totals.income).toBe(0);
    expect(totals.balance).toBe(-10);
  });

  it('excludes cancelled entries and filters every source by period and masjid', async () => {
    const { calculator, prisma } = calculatorWith({
      collections: '1',
      projects: '1',
      salary: '1',
      expenses: '1',
    });
    const period = { gte: new Date('2026-09-01'), lte: new Date('2026-09-30') };

    await calculator.totals('m1', period);

    expect(prisma.collection.aggregate).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { masjidId: 'm1', status: 'ACTIVE', collectedAt: period },
      }),
    );
    expect(prisma.expense.aggregate).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { masjidId: 'm1', status: 'ACTIVE', spentAt: period },
      }),
    );
    expect(prisma.projectContribution.aggregate).toHaveBeenCalledWith(
      expect.objectContaining({ where: { masjidId: 'm1', paidAt: period } }),
    );
    expect(prisma.imamSalaryPayment.aggregate).toHaveBeenCalledWith(
      expect.objectContaining({ where: { masjidId: 'm1', paidAt: period } }),
    );
  });
});

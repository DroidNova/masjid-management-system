import { HttpStatus } from '@nestjs/common';
import { money, type MoneyInput } from '../../../common/money';
import { ImamSalariesService } from './imam-salaries.service';
import { PaymentModeDto } from './dto/imam-salary-ledger.dto';

type Row = Record<string, unknown>;

const MONEY_KEYS = new Set([
  'amountPerHead',
  'totalExpected',
  'totalCollected',
  'totalDue',
  'expectedAmount',
  'paidAmount',
  'dueAmount',
  'amount',
]);

/** Stores amounts as Decimal, like Prisma returns them. */
function normalize(data: Row): Row {
  const out: Row = {};
  for (const [key, value] of Object.entries(data))
    out[key] = MONEY_KEYS.has(key) ? money(value as MoneyInput) : value;
  return out;
}

/** Minimal in-memory fake of the Prisma calls the service makes. */
function createFakePrisma(heads: Row[]) {
  const months: Row[] = [];
  const assignments: Row[] = [];
  const payments: Row[] = [];
  let seq = 0;
  const nextId = (prefix: string) => `${prefix}-${++seq}`;

  const delegates = {
    user: { findMany: jest.fn(() => Promise.resolve(heads)) },
    imamSalaryMonth: {
      findUnique: jest.fn(() => Promise.resolve(null)),
      findFirst: jest.fn(({ where }: { where: Row }) =>
        Promise.resolve(
          months.find(
            (m) => m.id === where.id && m.masjidId === where.masjidId,
          ) ?? null,
        ),
      ),
      create: jest.fn(({ data }: { data: Row }) => {
        const row = normalize({
          id: nextId('month'),
          totalCollected: 0,
          paidCount: 0,
          partialCount: 0,
          status: 'UNPAID',
          ...data,
        });
        months.push(row);
        return Promise.resolve(row);
      }),
      update: jest.fn(({ where, data }: { where: Row; data: Row }) => {
        const row = months.find((m) => m.id === where.id)!;
        Object.assign(row, normalize(data));
        return Promise.resolve(row);
      }),
    },
    imamSalaryAssignment: {
      createMany: jest.fn(({ data }: { data: Row[] }) => {
        for (const item of data)
          assignments.push(
            normalize({
              id: nextId('assignment'),
              paidAmount: 0,
              status: 'UNPAID',
              ...item,
            }),
          );
        return Promise.resolve({ count: data.length });
      }),
      findMany: jest.fn(({ where }: { where: Row }) =>
        Promise.resolve(
          assignments.filter(
            (a) => a.imamSalaryMonthId === where.imamSalaryMonthId,
          ),
        ),
      ),
      findFirst: jest.fn(({ where }: { where: Row }) => {
        const row = assignments.find(
          (a) => a.id === where.id && a.masjidId === where.masjidId,
        );
        if (!row) return Promise.resolve(null);
        const month = months.find((m) => m.id === row.imamSalaryMonthId)!;
        return Promise.resolve({
          ...row,
          imamSalaryMonth: { month: month.month, year: month.year },
        });
      }),
      update: jest.fn(({ where, data }: { where: Row; data: Row }) => {
        const row = assignments.find((a) => a.id === where.id)!;
        Object.assign(row, normalize(data));
        return Promise.resolve(row);
      }),
      updateMany: jest.fn(
        ({ where, data }: { where: { id: { in: string[] } }; data: Row }) => {
          const rows = assignments.filter((a) =>
            where.id.in.includes(a.id as string),
          );
          for (const row of rows) Object.assign(row, normalize(data));
          return Promise.resolve({ count: rows.length });
        },
      ),
    },
    imamSalaryPayment: {
      create: jest.fn(({ data }: { data: Row }) => {
        const row = normalize({ id: nextId('payment'), ...data });
        payments.push(row);
        return Promise.resolve(row);
      }),
    },
  };
  const db = {
    ...delegates,
    $transaction: jest.fn(
      (fn: (tx: unknown) => Promise<unknown>): Promise<unknown> =>
        fn(delegates),
    ),
  };
  return { db, months, assignments, payments };
}

describe('ImamSalariesService money math', () => {
  const actor = {
    id: 'admin-1',
    fullName: 'Admin',
    masjidId: 'masjid-1',
  } as never;
  const heads = [
    { id: 'u1', fullName: 'Ahmed', phone: '+911' },
    { id: 'u2', fullName: 'Bilal', phone: null },
    { id: 'u3', fullName: 'Kareem', phone: '+913' },
  ];
  let fake: ReturnType<typeof createFakePrisma>;
  let service: ImamSalariesService;
  let audit: { record: jest.Mock };

  beforeEach(() => {
    fake = createFakePrisma(heads);
    audit = { record: jest.fn() };
    service = new ImamSalariesService(fake.db as never, audit as never);
  });

  const createMonth = (amountPerHead: number) =>
    service.createMonth({ month: 6, year: 2026, amountPerHead }, actor);
  const pay = (assignmentId: string, amount: number) =>
    service.addPayment(
      {
        assignmentId,
        amount,
        paymentMode: PaymentModeDto.CASH,
        paidAt: '2026-06-05T10:00:00.000Z',
      },
      actor,
    );
  const assignment = (memberId: string) =>
    fake.assignments.find((a) => a.memberId === memberId)!;
  const amounts = (row: Row) => ({
    expected: String(row.expectedAmount),
    paid: String(row.paidAmount),
    due: String(row.dueAmount),
    status: row.status,
  });

  it('creates a month with exact totals returned as numbers', async () => {
    const month = await createMonth(600);

    expect(month).toMatchObject({
      amountPerHead: 600,
      totalExpected: 1800,
      totalDue: 1800,
      totalCollected: 0,
      unpaidCount: 3,
    });
    expect(fake.assignments).toHaveLength(3);
    expect(assignment('u2').memberPhone).toBe('');
    // Head list is read through the transaction client.
    expect(fake.db.$transaction).toHaveBeenCalledTimes(1);
    expect(audit.record).toHaveBeenCalledWith(
      expect.objectContaining({
        entity: 'SALARY_MONTH',
        action: 'CREATE',
        masjidId: 'masjid-1',
      }),
      expect.anything(),
    );
  });

  it('leaves the right due after a partial payment', async () => {
    await createMonth(600);
    const payment = await pay(assignment('u1').id as string, 250.5);

    expect(payment.amount).toBe(250.5);
    expect(audit.record).toHaveBeenLastCalledWith(
      expect.objectContaining({
        entity: 'SALARY_PAYMENT',
        action: 'CREATE',
        summary: 'Payment 250.50 CASH from Ahmed for 6/2026',
      }),
      expect.anything(),
    );
    expect(amounts(assignment('u1'))).toEqual({
      expected: '600',
      paid: '250.5',
      due: '349.5',
      status: 'PARTIAL',
    });
  });

  it('rejects a payment larger than the due amount', async () => {
    await createMonth(600);
    const id = assignment('u1').id as string;
    await pay(id, 500);

    await expect(pay(id, 100.01)).rejects.toMatchObject({
      message: 'Payment amount cannot exceed current due amount',
    });
    expect(fake.payments).toHaveLength(1);
    // Paying exactly the remaining due is allowed.
    await pay(id, 100);
    expect(amounts(assignment('u1'))).toMatchObject({
      due: '0',
      status: 'PAID',
    });
  });

  it('returns 404 for an unknown assignment', async () => {
    await createMonth(600);
    await expect(pay('nope', 10)).rejects.toMatchObject({
      status: HttpStatus.NOT_FOUND,
    });
  });

  it('recomputes month totals and counts after payments', async () => {
    await createMonth(600);
    await pay(assignment('u1').id as string, 600);
    await pay(assignment('u2').id as string, 200.25);

    const month = await service.getMonth(fake.months[0].id as string, actor);
    expect(month).toMatchObject({
      totalExpected: 1800,
      totalCollected: 800.25,
      totalDue: 999.75,
      paidCount: 1,
      partialCount: 1,
      unpaidCount: 1,
      status: 'PARTIAL',
    });
  });

  it('adds 0.1 + 0.2 style amounts exactly', async () => {
    await createMonth(1000.75);
    const id = assignment('u1').id as string;
    await pay(id, 500.5);
    await pay(id, 200.25);
    await pay(assignment('u2').id as string, 0.1);
    await pay(assignment('u3').id as string, 0.2);

    expect(amounts(assignment('u1'))).toMatchObject({
      paid: '700.75',
      due: '300',
    });
    const month = await service.getMonth(fake.months[0].id as string, actor);
    // Float math would give 701.0500000000001 for the collected total.
    expect(month.totalCollected).toBe(701.05);
    expect(month.totalDue).toBe(2301.2);
    expect(month.totalExpected).toBe(3002.25);
  });

  it('recomputes expected, due and status when the amount per head rises', async () => {
    const created = await createMonth(600);
    await pay(assignment('u1').id as string, 600);
    await pay(assignment('u2').id as string, 300);

    const month = await service.updateAmount(
      created.id,
      { amountPerHead: 750.5, reason: 'Revised' },
      actor,
    );

    expect(amounts(assignment('u1'))).toEqual({
      expected: '750.5',
      paid: '600',
      due: '150.5',
      status: 'PARTIAL',
    });
    expect(amounts(assignment('u2'))).toEqual({
      expected: '750.5',
      paid: '300',
      due: '450.5',
      status: 'PARTIAL',
    });
    expect(amounts(assignment('u3'))).toEqual({
      expected: '750.5',
      paid: '0',
      due: '750.5',
      status: 'UNPAID',
    });
    expect(month).toMatchObject({
      amountPerHead: 750.5,
      totalExpected: 2251.5,
      totalCollected: 900,
      totalDue: 1351.5,
      paidCount: 0,
      partialCount: 2,
      unpaidCount: 1,
      note: 'Revised',
    });
    expect(audit.record).toHaveBeenLastCalledWith(
      expect.objectContaining({
        entity: 'SALARY_MONTH',
        action: 'UPDATE',
        summary:
          'Salary month 6/2026 amount per head 600.00 -> 750.50 (Revised)',
      }),
      expect.anything(),
    );
  });

  it('rejects lowering the amount per head', async () => {
    const created = await createMonth(600);
    await expect(
      service.updateAmount(created.id, { amountPerHead: 599.99 }, actor),
    ).rejects.toMatchObject({
      message: 'Monthly amount can only be increased',
    });
  });
});

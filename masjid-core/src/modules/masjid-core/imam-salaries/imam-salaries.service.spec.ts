import { HttpStatus } from '@nestjs/common';
import { Prisma } from '../../../generated/prisma/client';
import { money, type Money, type MoneyInput } from '../../../common/money';
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

/** Equality, plus `{ gte }` on amounts (all the service filters with). */
function matches(row: Row, where: Row): boolean {
  return Object.entries(where).every(([key, condition]) => {
    if (condition && typeof condition === 'object' && 'gte' in condition)
      return money(row[key] as MoneyInput).greaterThanOrEqualTo(
        money((condition as { gte: MoneyInput }).gte),
      );
    return row[key] === condition;
  });
}

/** Applies plain values and `{ increment }` / `{ decrement }` like Prisma. */
function apply(row: Row, data: Row): void {
  for (const [key, value] of Object.entries(data)) {
    if (value && typeof value === 'object' && 'increment' in value) {
      const by = (value as { increment: MoneyInput }).increment;
      row[key] = MONEY_KEYS.has(key)
        ? money(row[key] as MoneyInput).plus(money(by))
        : (row[key] as number) + (by as number);
    } else if (value && typeof value === 'object' && 'decrement' in value) {
      const by = (value as { decrement: MoneyInput }).decrement;
      row[key] = MONEY_KEYS.has(key)
        ? money(row[key] as MoneyInput).minus(money(by))
        : (row[key] as number) - (by as number);
    } else {
      row[key] = MONEY_KEYS.has(key) ? money(value as MoneyInput) : value;
    }
  }
}

/** A fresh object, like every Prisma result. */
const copy = (row: Row | undefined): Row | null => (row ? { ...row } : null);

/** Lets other queued promises run, like a database round trip would. */
const roundTrip = <T>(value: T): Promise<T> =>
  new Promise((resolve) => setImmediate(() => resolve(value)));

/**
 * Row locks like PostgreSQL: an UPDATE locks the rows it writes until its
 * transaction ends; another transaction updating the same row waits, then
 * re-checks its WHERE against the committed row (READ COMMITTED).
 */
function createLocks() {
  const held = new Map<string, { owner: number; released: Promise<void> }>();
  const release = new Map<number, (() => void)[]>();
  return {
    async acquire(rowId: string, txId: number): Promise<void> {
      if (txId === 0) return; // outside a transaction: autocommit
      for (;;) {
        const lock = held.get(rowId);
        if (!lock) break;
        if (lock.owner === txId) return;
        await lock.released;
      }
      let done!: () => void;
      const released = new Promise<void>((resolve) => (done = resolve));
      held.set(rowId, { owner: txId, released });
      release.set(txId, [
        ...(release.get(txId) ?? []),
        () => {
          held.delete(rowId);
          done();
        },
      ]);
    },
    releaseAll(txId: number): void {
      for (const free of release.get(txId) ?? []) free();
      release.delete(txId);
    },
  };
}

/** Minimal in-memory fake of the Prisma calls the service makes. */
function createFakePrisma(heads: Row[]) {
  const months: Row[] = [];
  const assignments: Row[] = [];
  const payments: Row[] = [];
  let seq = 0;
  let txSeq = 0;
  const nextId = (prefix: string) => `${prefix}-${++seq}`;
  const monthKeys = new Set<string>();
  const locks = createLocks();

  /** Locks the rows matching the id part of `where`, then filters fully. */
  const lockAndMatch = async (
    rows: Row[],
    where: Row,
    txId: number,
  ): Promise<Row[]> => {
    const candidates = rows.filter((r) => r.id === where.id);
    for (const row of candidates) await locks.acquire(row.id as string, txId);
    return candidates.filter((r) => matches(r, where));
  };

  const delegatesFor = (txId: number) => ({
    user: { findMany: jest.fn(() => roundTrip(heads)) },
    imamSalaryMonth: {
      findFirst: jest.fn(({ where }: { where: Row }) =>
        roundTrip(copy(months.find((m) => matches(m, where)))),
      ),
      create: jest.fn(({ data }: { data: Row }) => {
        const key = `${String(data.masjidId)}:${String(data.month)}:${String(data.year)}`;
        if (monthKeys.has(key))
          return Promise.reject(
            new Prisma.PrismaClientKnownRequestError('Unique constraint', {
              code: 'P2002',
              clientVersion: 'test',
            }),
          );
        monthKeys.add(key);
        const row = normalize({
          id: nextId('month'),
          totalCollected: 0,
          paidCount: 0,
          partialCount: 0,
          status: 'UNPAID',
          ...data,
        });
        months.push(row);
        return roundTrip({ ...row });
      }),
      update: jest.fn(async ({ where, data }: { where: Row; data: Row }) => {
        const [row] = await lockAndMatch(months, where, txId);
        apply(row, data);
        return roundTrip({ ...row });
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
        return roundTrip({ count: data.length });
      }),
      findFirst: jest.fn(({ where }: { where: Row }) =>
        roundTrip(copy(assignments.find((a) => matches(a, where)))),
      ),
      findUniqueOrThrow: jest.fn(({ where }: { where: Row }) => {
        const row = assignments.find((a) => matches(a, where))!;
        const month = months.find((m) => m.id === row.imamSalaryMonthId)!;
        return roundTrip({
          ...row,
          imamSalaryMonth: { month: month.month, year: month.year },
        });
      }),
      update: jest.fn(async ({ where, data }: { where: Row; data: Row }) => {
        const [row] = await lockAndMatch(assignments, where, txId);
        apply(row, data);
        return roundTrip({ ...row });
      }),
      updateMany: jest.fn(
        async ({ where, data }: { where: Row; data: Row }) => {
          const rows = await lockAndMatch(assignments, where, txId);
          for (const row of rows) apply(row, data);
          return roundTrip({ count: rows.length });
        },
      ),
      groupBy: jest.fn(({ where }: { where: Row }) => {
        const groups = new Map<string, Row[]>();
        for (const row of assignments.filter((a) => matches(a, where)))
          groups.set(row.status as string, [
            ...(groups.get(row.status as string) ?? []),
            row,
          ]);
        const sum = (rows: Row[], key: string) =>
          rows.reduce<Money>(
            (total, row) => total.plus(money(row[key] as MoneyInput)),
            money(0),
          );
        return roundTrip(
          [...groups.entries()].map(([status, rows]) => ({
            status,
            _count: { _all: rows.length },
            _sum: {
              expectedAmount: sum(rows, 'expectedAmount'),
              paidAmount: sum(rows, 'paidAmount'),
              dueAmount: sum(rows, 'dueAmount'),
            },
          })),
        );
      }),
    },
    imamSalaryPayment: {
      create: jest.fn(({ data }: { data: Row }) => {
        const row = normalize({ id: nextId('payment'), ...data });
        payments.push(row);
        return roundTrip({ ...row });
      }),
    },
    /**
     * The one raw statement (raise the amount per head). Values are, in
     * order: amount x3, imamSalaryMonthId, masjidId.
     */
    $executeRaw: jest.fn(
      (strings: TemplateStringsArray, ...values: unknown[]) => {
        expect(strings.join('?')).toContain('UPDATE "ImamSalaryAssignment"');
        const amount = money(values[0] as string);
        const [monthId, masjidId] = values.slice(3) as string[];
        const rows = assignments.filter(
          (a) => a.imamSalaryMonthId === monthId && a.masjidId === masjidId,
        );
        for (const row of rows) {
          const paid = money(row.paidAmount as MoneyInput);
          row.expectedAmount = amount;
          row.dueAmount = amount.minus(paid);
          row.status = paid.lessThanOrEqualTo(0)
            ? 'UNPAID'
            : paid.greaterThanOrEqualTo(amount)
              ? 'PAID'
              : 'PARTIAL';
        }
        return roundTrip(rows.length);
      },
    ),
  });
  const db = {
    ...delegatesFor(0),
    $transaction: jest.fn(
      async (fn: (tx: unknown) => Promise<unknown>): Promise<unknown> => {
        const txId = ++txSeq;
        try {
          return await fn(delegatesFor(txId));
        } finally {
          locks.releaseAll(txId);
        }
      },
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
  it('refuses a second month for the same month and year with 409', async () => {
    await createMonth(600);
    await expect(createMonth(700)).rejects.toMatchObject({
      status: HttpStatus.CONFLICT,
      response: expect.objectContaining({
        errorCode: 'IMAM_SALARY_ALREADY_EXISTS',
      }) as unknown,
    });
  });

  it('returns 404 for an assignment of another masjid', async () => {
    await createMonth(600);
    const other = { id: 'x', fullName: 'X', masjidId: 'masjid-2' } as never;
    await expect(
      service.addPayment(
        {
          assignmentId: assignment('u1').id as string,
          amount: 10,
          paymentMode: PaymentModeDto.CASH,
          paidAt: '2026-06-05T10:00:00.000Z',
        },
        other,
      ),
    ).rejects.toMatchObject({
      response: expect.objectContaining({
        errorCode: 'IMAM_SALARY_NOT_FOUND',
      }) as unknown,
    });
    expect(amounts(assignment('u1')).paid).toBe('0');
  });

  it('moves the month counts with each status change', async () => {
    const created = await createMonth(600);
    const id = assignment('u1').id as string;
    const month = () => service.getMonth(created.id, actor);

    await pay(id, 100);
    expect(await month()).toMatchObject({
      paidCount: 0,
      partialCount: 1,
      unpaidCount: 2,
      status: 'PARTIAL',
    });
    await pay(id, 200);
    expect(await month()).toMatchObject({
      paidCount: 0,
      partialCount: 1,
      unpaidCount: 2,
    });
    await pay(id, 300);
    expect(await month()).toMatchObject({
      paidCount: 1,
      partialCount: 0,
      unpaidCount: 2,
      totalCollected: 600,
      totalDue: 1200,
    });
    await pay(assignment('u2').id as string, 600);
    await pay(assignment('u3').id as string, 600);
    expect(await month()).toMatchObject({
      paidCount: 3,
      partialCount: 0,
      unpaidCount: 0,
      totalCollected: 1800,
      totalDue: 0,
      status: 'PAID',
    });
  });

  describe('concurrent payments (conditional update)', () => {
    it('lets only one of two racing payments through when both cannot fit', async () => {
      await createMonth(600);
      const id = assignment('u1').id as string;

      const results = await Promise.allSettled([pay(id, 400), pay(id, 400)]);

      expect(results.map((r) => r.status).sort()).toEqual([
        'fulfilled',
        'rejected',
      ]);
      const rejected = results.find((r) => r.status === 'rejected');
      expect(rejected).toMatchObject({
        reason: {
          message: 'Payment amount cannot exceed current due amount',
        },
      });
      expect(fake.payments).toHaveLength(1);
      expect(amounts(assignment('u1'))).toEqual({
        expected: '600',
        paid: '400',
        due: '200',
        status: 'PARTIAL',
      });
      expect(
        await service.getMonth(fake.months[0].id as string, actor),
      ).toMatchObject({
        totalCollected: 400,
        totalDue: 1400,
        paidCount: 0,
        partialCount: 1,
        unpaidCount: 2,
      });
    });

    it('keeps exact totals when many payments land at once', async () => {
      await createMonth(600);
      const ids = ['u1', 'u2', 'u3'].map((m) => assignment(m).id as string);

      // 3 x 6 payments of 100.1 = 600.6 per head: the 6th one cannot fit.
      const results = await Promise.allSettled(
        ids.flatMap((id) => Array.from({ length: 6 }, () => pay(id, 100.1))),
      );

      const accepted = results.filter((r) => r.status === 'fulfilled');
      expect(accepted).toHaveLength(15);
      for (const id of ids) {
        const row = fake.assignments.find((a) => a.id === id)!;
        expect(amounts(row)).toEqual({
          expected: '600',
          paid: '500.5',
          due: '99.5',
          status: 'PARTIAL',
        });
      }
      expect(
        await service.getMonth(fake.months[0].id as string, actor),
      ).toMatchObject({
        totalCollected: 1501.5,
        totalDue: 298.5,
        paidCount: 0,
        partialCount: 3,
        unpaidCount: 0,
        status: 'PARTIAL',
      });
    });

    it('never overpays when racing payments together fill the due exactly', async () => {
      await createMonth(600);
      const id = assignment('u1').id as string;

      const results = await Promise.allSettled([
        pay(id, 250),
        pay(id, 350),
        pay(id, 0.01),
      ]);

      expect(results.filter((r) => r.status === 'fulfilled')).toHaveLength(2);
      const row = amounts(assignment('u1'));
      expect(money(row.paid).lessThanOrEqualTo(600)).toBe(true);
      expect(money(row.due).isNegative()).toBe(false);
      expect(money(row.paid).plus(money(row.due)).toString()).toBe('600');
    });
  });
});

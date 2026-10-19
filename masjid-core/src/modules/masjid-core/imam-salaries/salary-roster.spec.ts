import { currentIndiaMonth, syncSalaryRoster } from './salary-roster';

describe('salary roster', () => {
  const tx = {
    user: { findUnique: jest.fn() },
    imamSalaryAssignment: {
      findMany: jest.fn(),
      deleteMany: jest.fn(),
      createMany: jest.fn(),
    },
    imamSalaryMonth: { findMany: jest.fn(), update: jest.fn() },
  };

  const head = {
    id: 'u1',
    fullName: 'Saleem',
    phone: '+919876543210',
    masjidId: 'm1',
    status: 'ACTIVE',
    isFamilyHead: true,
    userRoles: [{ role: { name: 'MEMBER' } }],
  };

  beforeEach(() => {
    jest.resetAllMocks();
    tx.imamSalaryAssignment.createMany.mockResolvedValue({ count: 1 });
  });

  it('uses India time for the current month', () => {
    // 31 Oct 2026, 20:00 UTC is already 1 Nov in India.
    expect(currentIndiaMonth(new Date('2026-10-31T20:00:00Z'))).toEqual({
      month: 11,
      year: 2026,
    });
  });

  it('adds a new family head to open months and recomputes their totals', async () => {
    tx.user.findUnique.mockResolvedValue(head);
    tx.imamSalaryAssignment.findMany
      .mockResolvedValueOnce([]) // nothing stale
      .mockResolvedValueOnce([
        // month rows used for recompute
        { expectedAmount: 50, paidAmount: 50, status: 'PAID' },
        { expectedAmount: 50, paidAmount: 0, status: 'UNPAID' },
      ]);
    tx.imamSalaryMonth.findMany.mockResolvedValue([
      { id: 'month-oct', amountPerHead: 50 },
    ]);

    const result = await syncSalaryRoster(tx as never, 'u1');

    expect(result).toEqual({ added: 1, removed: 0 });
    expect(tx.imamSalaryAssignment.createMany).toHaveBeenCalledWith(
      expect.objectContaining({
        data: [
          expect.objectContaining({
            memberId: 'u1',
            imamSalaryMonthId: 'month-oct',
            expectedAmount: 50,
            dueAmount: 50,
          }),
        ],
      }),
    );
    const update = tx.imamSalaryMonth.update.mock.calls[0][0];
    expect(update.where).toEqual({ id: 'month-oct' });
    expect(update.data.totalExpected.toNumber()).toBe(100);
    expect(update.data.totalDue.toNumber()).toBe(50);
    expect(update.data).toEqual(
      expect.objectContaining({
        paidCount: 1,
        unpaidCount: 1,
        partialCount: 0,
        status: 'PARTIAL',
      }),
    );
  });

  it('removes only unpaid, untouched open-month rows when someone stops being a head', async () => {
    tx.user.findUnique.mockResolvedValue({ ...head, isFamilyHead: false });
    tx.imamSalaryAssignment.findMany
      .mockResolvedValueOnce([{ id: 'a1', imamSalaryMonthId: 'month-oct' }])
      .mockResolvedValueOnce([]);

    const result = await syncSalaryRoster(tx as never, 'u1');

    expect(result).toEqual({ added: 0, removed: 1 });
    const staleQuery = tx.imamSalaryAssignment.findMany.mock.calls[0][0];
    expect(staleQuery.where).toEqual(
      expect.objectContaining({
        memberId: 'u1',
        paidAmount: 0,
        status: 'UNPAID',
      }),
    );
    expect(tx.imamSalaryAssignment.deleteMany).toHaveBeenCalledWith({
      where: { id: { in: ['a1'] } },
    });
    expect(tx.imamSalaryMonth.findMany).not.toHaveBeenCalled();
    expect(tx.imamSalaryMonth.update).toHaveBeenCalledTimes(1);
  });

  it('does nothing for an unknown user', async () => {
    tx.user.findUnique.mockResolvedValue(null);
    await expect(syncSalaryRoster(tx as never, 'nobody')).resolves.toEqual({
      added: 0,
      removed: 0,
    });
    expect(tx.imamSalaryAssignment.findMany).not.toHaveBeenCalled();
  });
});

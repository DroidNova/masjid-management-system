import { ContributionsService } from './contributions.service';

describe('ContributionsService', () => {
  const prisma = {
    imamSalaryAssignment: {
      findMany: jest.fn(),
      findFirst: jest.fn(),
      groupBy: jest.fn(),
      count: jest.fn(),
    },
    projectContribution: {
      findMany: jest.fn(),
      count: jest.fn(),
      aggregate: jest.fn(),
    },
    collectionContribution: {
      findMany: jest.fn(),
      count: jest.fn(),
      aggregate: jest.fn(),
    },
    imamSalaryPayment: {
      findMany: jest.fn(),
      count: jest.fn(),
    },
  };
  const service = new ContributionsService(prisma as never);
  const actor = {
    id: 'current-user',
    fullName: 'Saleem',
    phone: '+919876543210',
    isFamilyHead: true,
    masjidId: 'current-masjid',
  } as never;

  beforeEach(() => {
    jest.clearAllMocks();
    prisma.projectContribution.aggregate.mockResolvedValue({
      _sum: { amount: 0 },
    });
    prisma.collectionContribution.aggregate.mockResolvedValue({
      _sum: { amount: 0 },
    });
  });

  it('sums salary over all months and shows this month, without exposing masjidId', async () => {
    const row = (status: string, count: number, e: number, p: number) => ({
      status,
      _count: { _all: count },
      _sum: { expectedAmount: e, paidAmount: p, dueAmount: e - p },
    });
    // Ten months in total: an old unpaid month must still count as due.
    prisma.imamSalaryAssignment.groupBy.mockResolvedValue([
      row('PAID', 8, 400, 400),
      row('PARTIAL', 1, 50, 20),
      row('UNPAID', 1, 50, 0),
    ]);
    prisma.imamSalaryAssignment.findFirst.mockResolvedValue({
      expectedAmount: 50,
      paidAmount: 20,
      dueAmount: 30,
      status: 'PARTIAL',
    });

    const response = await service.getSummary(actor);

    expect(prisma.imamSalaryAssignment.groupBy).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { memberId: 'current-user', masjidId: 'current-masjid' },
      }),
    );
    const data = response.data!;
    expect(data.totalContributionAmount).toBe(420);
    expect(data.imamSalary).toEqual(
      expect.objectContaining({
        monthsShown: 10,
        totalExpected: 500,
        totalPaid: 420,
        totalDue: 80,
        paidMonths: 8,
        partialMonths: 1,
        unpaidMonths: 1,
      }),
    );
    expect(data.imamSalary.currentMonth).toEqual(
      expect.objectContaining({ dueAmount: 30, status: 'PARTIAL' }),
    );
    expect(data.user).not.toHaveProperty('masjidId');
  });

  it('has no current month when no salary month exists for it', async () => {
    prisma.imamSalaryAssignment.groupBy.mockResolvedValue([]);
    prisma.imamSalaryAssignment.findFirst.mockResolvedValue(null);

    const response = await service.getSummary(actor);

    expect(response.data!.imamSalary.currentMonth).toBeNull();
    expect(response.data!.imamSalary.totalDue).toBe(0);
  });

  it('always scopes payment history to the authenticated user and masjid', async () => {
    prisma.imamSalaryPayment.findMany.mockResolvedValue([]);
    prisma.imamSalaryPayment.count.mockResolvedValue(0);

    const response = await service.getImamSalaryPayments(
      6,
      2026,
      { page: 1, limit: 20 },
      actor,
    );

    expect(prisma.imamSalaryPayment.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          memberId: 'current-user',
          masjidId: 'current-masjid',
          paymentForMonth: 6,
          paymentForYear: 2026,
        },
      }),
    );
    expect(response.data).toEqual({
      items: [],
      meta: { total: 0, page: 1, limit: 20, totalPages: 0, hasNextPage: false },
    });
  });

  it('returns the clean masjid-assignment error before reading ledger data', async () => {
    prisma.projectContribution.aggregate.mockResolvedValue({
      _sum: { amount: 0 },
    });
    prisma.collectionContribution.aggregate.mockResolvedValue({
      _sum: { amount: 0 },
    });
    const withoutMasjid = {
      id: 'current-user',
      fullName: 'Saleem',
      phone: null,
      isFamilyHead: false,
      masjidId: null,
    } as never;

    await expect(service.getSummary(withoutMasjid)).rejects.toMatchObject({
      response: expect.objectContaining({
        errorCode: 'USER_MASJID_NOT_ASSIGNED',
      }) as unknown,
    });
    expect(prisma.imamSalaryAssignment.findMany).not.toHaveBeenCalled();
  });

  it('lists only the latest monthsBack salary months', async () => {
    prisma.imamSalaryAssignment.count.mockResolvedValue(10);
    prisma.imamSalaryAssignment.findMany.mockResolvedValue([]);

    const response = await service.getImamSalaryHistory(
      { page: 2, limit: 4, monthsBack: 6 },
      actor,
    );

    expect(prisma.imamSalaryAssignment.findMany).toHaveBeenCalledWith(
      expect.objectContaining({ skip: 4, take: 2 }),
    );
    expect(response.data?.meta).toEqual({
      total: 6,
      page: 2,
      limit: 4,
      totalPages: 2,
      hasNextPage: false,
    });
  });

  it('treats toDate as the whole day', async () => {
    prisma.projectContribution.findMany.mockResolvedValue([]);
    prisma.projectContribution.count.mockResolvedValue(0);

    await service.getMyProjectContributions(
      { fromDate: '2026-06-01', toDate: '2026-06-30' },
      actor,
    );

    expect(prisma.projectContribution.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          paidAt: {
            gte: new Date('2026-06-01T00:00:00.000Z'),
            lte: new Date('2026-06-30T23:59:59.999Z'),
          },
        }) as unknown,
      }),
    );
  });
});

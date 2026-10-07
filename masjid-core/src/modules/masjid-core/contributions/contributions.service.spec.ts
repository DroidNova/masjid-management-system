import { ContributionsService } from './contributions.service';

describe('ContributionsService', () => {
  const prisma = {
    imamSalaryAssignment: {
      findMany: jest.fn(),
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

  it('calculates the latest six-month summary without exposing masjidId', async () => {
    prisma.imamSalaryAssignment.findMany.mockResolvedValue([
      { expectedAmount: 50, paidAmount: 50, dueAmount: 0, status: 'PAID' },
      { expectedAmount: 50, paidAmount: 20, dueAmount: 30, status: 'PARTIAL' },
      { expectedAmount: 50, paidAmount: 0, dueAmount: 50, status: 'UNPAID' },
    ]);

    const response = await service.getSummary(actor);

    expect(prisma.imamSalaryAssignment.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { memberId: 'current-user', masjidId: 'current-masjid' },
        take: 6,
      }),
    );
    expect(response.data).toEqual({
      user: {
        id: 'current-user',
        fullName: 'Saleem',
        phone: '+919876543210',
        isFamilyHead: true,
      },
      projectContributionTotal: 0,
      collectionContributionTotal: 0,
      totalContributionAmount: 70,
      imamSalary: {
        monthsShown: 6,
        totalExpected: 150,
        totalPaid: 70,
        totalDue: 80,
        paidMonths: 1,
        partialMonths: 1,
        unpaidMonths: 1,
      },
    });
    expect(response.data?.user).not.toHaveProperty('masjidId');
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

import { ContributionsService } from './contributions.service';

describe('ContributionsService', () => {
  const prisma = {
    user: { findUnique: jest.fn() },
    imamSalaryAssignment: {
      findMany: jest.fn(),
      count: jest.fn(),
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
    masjidId: 'current-masjid',
  } as never;

  beforeEach(() => {
    jest.clearAllMocks();
    prisma.user.findUnique.mockResolvedValue({
      id: 'current-user',
      fullName: 'Saleem',
      phone: '+919876543210',
      isFamilyHead: true,
      masjidId: 'current-masjid',
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
    expect(response.data.user).not.toHaveProperty('masjidId');
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
      total: 0,
      page: 1,
      limit: 20,
      totalPages: 0,
      hasNextPage: false,
    });
  });

  it('returns the clean masjid-assignment error before reading ledger data', async () => {
    prisma.user.findUnique.mockResolvedValue({
      id: 'current-user',
      fullName: 'Saleem',
      phone: null,
      isFamilyHead: false,
      masjidId: null,
    });

    await expect(service.getSummary(actor)).rejects.toMatchObject({
      response: expect.objectContaining({
        errorCode: 'USER_MASJID_NOT_ASSIGNED',
      }),
    });
    expect(prisma.imamSalaryAssignment.findMany).not.toHaveBeenCalled();
  });
});

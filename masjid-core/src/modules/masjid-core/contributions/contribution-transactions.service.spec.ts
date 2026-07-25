import { ContributionTransactionsService } from './contribution-transactions.service';

describe('ContributionTransactionsService', () => {
  const tx = {
    project: { findFirst: jest.fn(), update: jest.fn() },
    user: { findFirst: jest.fn() },
    projectContribution: { create: jest.fn() },
    collectionContribution: { create: jest.fn() },
    collection: { create: jest.fn() },
  };
  const prisma = {
    $transaction: jest.fn((operation: (client: typeof tx) => unknown) =>
      operation(tx),
    ),
  };
  const service = new ContributionTransactionsService(prisma as never);
  const actor = {
    id: 'collector',
    fullName: 'Rafiq',
    masjidId: 'masjid-1',
  } as never;

  beforeEach(() => {
    jest.clearAllMocks();
    tx.project.findFirst.mockResolvedValue({ id: 'project-1' });
    tx.user.findFirst.mockResolvedValue({ id: 'member-1' });
  });

  it('creates a project transaction and increments the project total atomically', async () => {
    tx.projectContribution.create.mockResolvedValue({
      id: 'contribution-1',
      amount: 500,
    });
    await service.createProjectContribution(
      'project-1',
      {
        memberId: 'member-1',
        contributorName: 'Saleem',
        amount: 500,
        paymentMode: 'CASH' as never,
        paidAt: '2026-07-25',
      },
      actor,
    );
    expect(tx.projectContribution.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          masjidId: 'masjid-1',
          projectId: 'project-1',
          memberId: 'member-1',
        }),
      }),
    );
    expect(tx.project.update).toHaveBeenCalledWith({
      where: { id: 'project-1' },
      data: { collectedAmount: { increment: 500 } },
    });
  });

  it('creates both the collection transaction and finance collection entry', async () => {
    tx.collectionContribution.create.mockResolvedValue({
      id: 'contribution-2',
      amount: 100,
    });
    await service.createCollectionContribution(
      {
        contributorName: 'Saleem',
        collectionType: 'DONATION_BOX' as never,
        amount: 100,
        paymentMode: 'ONLINE' as never,
        paidAt: '2026-07-25',
      },
      actor,
    );
    expect(tx.collectionContribution.create).toHaveBeenCalled();
    expect(tx.collection.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        masjidId: 'masjid-1',
        type: 'DONATION_BOX',
        amount: 100,
      }),
    });
  });
});

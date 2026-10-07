import { ContributionTransactionsService } from './contribution-transactions.service';

describe('ContributionTransactionsService', () => {
  const tx = {
    project: { updateMany: jest.fn() },
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
  const audit = { record: jest.fn() };
  const service = new ContributionTransactionsService(
    prisma as never,
    audit as never,
  );
  const actor = {
    id: 'collector',
    fullName: 'Rafiq',
    masjidId: 'masjid-1',
  } as never;

  beforeEach(() => {
    jest.clearAllMocks();
    tx.project.updateMany.mockResolvedValue({ count: 1 });
    tx.collection.create.mockResolvedValue({ id: 'collection-1' });
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
        }) as unknown,
      }),
    );
    expect(tx.project.updateMany).toHaveBeenCalledWith({
      where: { id: 'project-1', masjidId: 'masjid-1' },
      data: { collectedAmount: { increment: 500 } },
    });
    expect(audit.record).toHaveBeenCalledWith(
      expect.objectContaining({
        entity: 'PROJECT_CONTRIBUTION',
        action: 'CREATE',
        masjidId: 'masjid-1',
      }),
      tx,
    );
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
    expect(tx.collection.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        masjidId: 'masjid-1',
        type: 'DONATION_BOX',
        amount: 100,
      }) as unknown,
      select: { id: true },
    });
    // The contribution points at the finance entry made for it.
    expect(tx.collectionContribution.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          collectionId: 'collection-1',
        }) as unknown,
      }),
    );
    expect(audit.record).toHaveBeenCalledWith(
      expect.objectContaining({
        entity: 'COLLECTION_CONTRIBUTION',
        action: 'CREATE',
      }),
      tx,
    );
  });

  it('returns 404 for a project of another masjid without writing anything', async () => {
    tx.project.updateMany.mockResolvedValue({ count: 0 });
    await expect(
      service.createProjectContribution(
        'other-project',
        {
          contributorName: 'Saleem',
          amount: 500,
          paymentMode: 'CASH' as never,
          paidAt: '2026-07-25',
        },
        actor,
      ),
    ).rejects.toMatchObject({
      response: expect.objectContaining({
        errorCode: 'PROJECT_NOT_FOUND',
      }) as unknown,
    });
    expect(tx.projectContribution.create).not.toHaveBeenCalled();
    expect(audit.record).not.toHaveBeenCalled();
  });
});

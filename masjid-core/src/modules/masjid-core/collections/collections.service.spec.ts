import { Prisma } from '../../../generated/prisma/client';
import { CollectionsService } from './collections.service';

describe('CollectionsService', () => {
  const row = (status: 'ACTIVE' | 'CANCELLED') => ({
    id: 'collection-1',
    masjidId: 'masjid-1',
    type: 'DONATION_BOX',
    amount: new Prisma.Decimal(100),
    title: null,
    description: null,
    collectedAt: new Date('2026-06-01T00:00:00.000Z'),
    status,
    createdById: 'admin-1',
    createdAt: new Date(),
    updatedAt: new Date(),
  });
  const tx = {
    collection: { findFirst: jest.fn(), update: jest.fn() },
    collectionContribution: { findUnique: jest.fn() },
  };
  const prisma = {
    collection: { findFirst: jest.fn(), findMany: jest.fn(), count: jest.fn() },
    $transaction: jest.fn((fn: (client: typeof tx) => unknown) => fn(tx)),
  };
  const audit = { record: jest.fn() };
  const notifications = { paymentNotice: jest.fn() };
  const service = new CollectionsService(
    prisma as never,
    audit as never,
    notifications as never,
  );
  const actor = { id: 'admin-1', fullName: 'Admin', masjidId: 'masjid-1' };

  beforeEach(() => jest.clearAllMocks());

  it('reads the before snapshot inside the transaction, scoped to the masjid', async () => {
    const before = row('ACTIVE');
    tx.collection.findFirst.mockResolvedValue(before);
    tx.collection.update.mockResolvedValue({
      ...before,
      amount: new Prisma.Decimal(150),
    });

    const result = await service.update(
      'collection-1',
      { amount: 150 },
      actor as never,
    );

    expect(tx.collection.findFirst).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: 'collection-1', masjidId: 'masjid-1' },
      }),
    );
    expect(result.amount).toBe(150);
    expect(audit.record).toHaveBeenCalledWith(
      expect.objectContaining({ action: 'UPDATE', before }),
      tx,
    );
  });

  it('returns 404 for an id of another masjid', async () => {
    tx.collection.findFirst.mockResolvedValue(null);
    await expect(
      service.update('collection-1', { amount: 1 }, actor as never),
    ).rejects.toMatchObject({
      response: expect.objectContaining({
        errorCode: 'COLLECTION_NOT_FOUND',
      }) as unknown,
    });
    expect(tx.collection.update).not.toHaveBeenCalled();
  });

  it('rejects an empty update before touching the database', async () => {
    await expect(
      service.update('collection-1', {}, actor as never),
    ).rejects.toMatchObject({ status: 400 });
    expect(prisma.$transaction).not.toHaveBeenCalled();
  });

  it('cancels an active entry with an audit row', async () => {
    tx.collection.findFirst.mockResolvedValue(row('ACTIVE'));
    tx.collection.update.mockResolvedValue(row('CANCELLED'));

    const result = await service.cancel('collection-1', actor as never);

    expect(result.status).toBe('CANCELLED');
    expect(audit.record).toHaveBeenCalledWith(
      expect.objectContaining({ action: 'CANCEL' }),
      tx,
    );
  });

  it("tells the member when their donation's entry is cancelled", async () => {
    tx.collection.findFirst.mockResolvedValue(row('ACTIVE'));
    tx.collection.update.mockResolvedValue(row('CANCELLED'));
    tx.collectionContribution.findUnique.mockResolvedValue({
      id: 'cc-1',
      memberId: 'member-1',
    });

    await service.cancel('collection-1', actor as never);

    expect(tx.collectionContribution.findUnique).toHaveBeenCalledWith(
      expect.objectContaining({ where: { collectionId: 'collection-1' } }),
    );
    expect(notifications.paymentNotice).toHaveBeenCalledWith(
      expect.objectContaining({
        memberId: 'member-1',
        kind: 'PAYMENT_CANCELLED',
        entity: 'COLLECTION_CONTRIBUTION',
        entityId: 'cc-1',
        amount: new Prisma.Decimal(100),
        paymentFor: { purpose: 'DONATION', collectionType: 'DONATION_BOX' },
      }),
      tx,
    );
  });

  it('tells the member the new amount when their entry is edited', async () => {
    const before = row('ACTIVE');
    tx.collection.findFirst.mockResolvedValue(before);
    tx.collection.update.mockResolvedValue({
      ...before,
      amount: new Prisma.Decimal(150),
    });
    tx.collectionContribution.findUnique.mockResolvedValue({
      id: 'cc-1',
      memberId: 'member-1',
    });

    await service.update('collection-1', { amount: 150 }, actor as never);

    expect(notifications.paymentNotice).toHaveBeenCalledWith(
      expect.objectContaining({
        kind: 'PAYMENT_CHANGED',
        amount: new Prisma.Decimal(100),
        newAmount: new Prisma.Decimal(150),
      }),
      tx,
    );
  });

  it('sends no notice for an entry that is not a member gift', async () => {
    tx.collection.findFirst.mockResolvedValue(row('ACTIVE'));
    tx.collection.update.mockResolvedValue(row('CANCELLED'));
    tx.collectionContribution.findUnique.mockResolvedValue(null);

    await service.cancel('collection-1', actor as never);

    expect(notifications.paymentNotice).not.toHaveBeenCalled();
  });

  it('returns an already cancelled entry unchanged, without a new audit row', async () => {
    tx.collection.findFirst.mockResolvedValue(row('CANCELLED'));

    const result = await service.cancel('collection-1', actor as never);

    expect(result.status).toBe('CANCELLED');
    expect(tx.collection.update).not.toHaveBeenCalled();
    expect(audit.record).not.toHaveBeenCalled();
  });

  it('treats toDate as the whole day', async () => {
    prisma.collection.findMany.mockResolvedValue([]);
    prisma.collection.count.mockResolvedValue(0);

    await service.findMyMasjidCollections(
      { toDate: '2026-06-30' },
      actor as never,
    );

    expect(prisma.collection.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          masjidId: 'masjid-1',
          collectedAt: { lte: new Date('2026-06-30T23:59:59.999Z') },
        },
      }),
    );
  });
});

import { Prisma } from '../../generated/prisma/client';
import { diff, RecordHistoryService } from './record-history.service';

describe('RecordHistoryService', () => {
  const prisma = {
    project: { findFirst: jest.fn() },
    projectContribution: { findFirst: jest.fn() },
    collectionContribution: { findFirst: jest.fn() },
    imamSalaryPayment: { findFirst: jest.fn() },
    imamSalaryMonth: { findFirst: jest.fn() },
    collection: { findFirst: jest.fn() },
    expense: { findFirst: jest.fn() },
    auditLog: { findMany: jest.fn() },
  };
  const service = new RecordHistoryService(prisma as never);
  const member = {
    id: 'member-1',
    fullName: 'Rahim',
    masjidId: 'masjid-1',
    roles: ['MEMBER'],
  };
  const committee = {
    ...member,
    id: 'committee-1',
    roles: ['COMMITTEE_MEMBER'],
  };
  const createdAt = new Date('2026-10-01T10:00:00Z');

  beforeEach(() => {
    jest.clearAllMocks();
    prisma.auditLog.findMany.mockResolvedValue([]);
  });

  it('lets a member open their own payment, with who collected it', async () => {
    prisma.projectContribution.findFirst.mockResolvedValue({
      createdAt,
      collectedByName: 'Karim',
      memberId: 'member-1',
    });
    prisma.auditLog.findMany.mockResolvedValue([
      {
        id: 'log-1',
        action: 'CREATE',
        actorName: 'Yusuf',
        entity: 'PROJECT_CONTRIBUTION',
        before: null,
        after: {},
        createdAt,
      },
    ]);

    const result = await service.find(
      'PROJECT_CONTRIBUTION',
      'pc-1',
      member as never,
    );

    expect(result).toMatchObject({
      collectedByName: 'Karim',
      events: [{ action: 'CREATE', actorName: 'Yusuf', changes: [] }],
    });
    expect(prisma.projectContribution.findFirst).toHaveBeenCalledWith(
      expect.objectContaining({ where: { id: 'pc-1', masjidId: 'masjid-1' } }),
    );
    expect(prisma.auditLog.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          masjidId: 'masjid-1',
          OR: [{ entity: 'PROJECT_CONTRIBUTION', entityId: 'pc-1' }],
        },
      }),
    );
  });

  it("stops a member from opening someone else's payment", async () => {
    prisma.imamSalaryPayment.findFirst.mockResolvedValue({
      createdAt,
      collectedByName: 'Karim',
      memberId: 'member-2',
    });

    await expect(
      service.find('SALARY_PAYMENT', 'sp-1', member as never),
    ).rejects.toMatchObject({ status: 403 });
    expect(prisma.auditLog.findMany).not.toHaveBeenCalled();
  });

  it('stops a member from opening an expense', async () => {
    prisma.expense.findFirst.mockResolvedValue({ createdAt });

    await expect(
      service.find('EXPENSE', 'e-1', member as never),
    ).rejects.toMatchObject({ status: 403 });
  });

  it('lets everyone open a project, and the committee any record', async () => {
    prisma.project.findFirst.mockResolvedValue({ createdAt });
    prisma.expense.findFirst.mockResolvedValue({ createdAt });

    await expect(
      service.find('PROJECT', 'p-1', member as never),
    ).resolves.toMatchObject({ entity: 'PROJECT', collectedByName: null });
    await expect(
      service.find('EXPENSE', 'e-1', committee as never),
    ).resolves.toMatchObject({ entity: 'EXPENSE' });
  });

  it('returns 404 for a record of another masjid', async () => {
    prisma.project.findFirst.mockResolvedValue(null);

    await expect(
      service.find('PROJECT', 'p-1', committee as never),
    ).rejects.toMatchObject({ status: 404 });
  });

  it("includes the cancel of a donation's finance entry, not its duplicate create", async () => {
    prisma.collectionContribution.findFirst.mockResolvedValue({
      createdAt,
      collectedByName: 'Karim',
      memberId: 'member-1',
      collectionId: 'c-1',
    });
    prisma.auditLog.findMany.mockResolvedValue([
      {
        id: 'log-1',
        action: 'CREATE',
        actorName: 'Karim',
        entity: 'COLLECTION_CONTRIBUTION',
        before: null,
        after: {},
        createdAt,
      },
      {
        id: 'log-2',
        action: 'CREATE',
        actorName: 'Karim',
        entity: 'COLLECTION',
        before: null,
        after: {},
        createdAt,
      },
      {
        id: 'log-3',
        action: 'CANCEL',
        actorName: 'Yusuf',
        entity: 'COLLECTION',
        before: {},
        after: {},
        createdAt,
      },
    ]);

    const result = await service.find(
      'COLLECTION_CONTRIBUTION',
      'cc-1',
      member as never,
    );

    expect(result.events.map((event) => event.id)).toEqual(['log-1', 'log-3']);
    expect(prisma.auditLog.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          masjidId: 'masjid-1',
          OR: [
            { entity: 'COLLECTION_CONTRIBUTION', entityId: 'cc-1' },
            { entity: 'COLLECTION', entityId: 'c-1' },
          ],
        },
      }),
    );
  });
});

describe('diff', () => {
  it('lists only tracked fields that really changed', () => {
    const before = JSON.parse(
      JSON.stringify({
        title: 'Wuzu area',
        targetAmount: new Prisma.Decimal('5000'),
        collectedAmount: new Prisma.Decimal('100'),
        endDate: null,
      }),
    ) as unknown;
    const after = {
      title: 'Wuzu area',
      targetAmount: '7000.00',
      collectedAmount: '900',
      endDate: '2026-12-31T00:00:00.000Z',
    };

    expect(diff('PROJECT', before, after)).toEqual([
      { field: 'targetAmount', kind: 'money', from: 5000, to: 7000 },
      {
        field: 'endDate',
        kind: 'date',
        from: null,
        to: '2026-12-31T00:00:00.000Z',
      },
    ]);
  });

  it('treats a string and a number amount as the same value', () => {
    expect(
      diff('SALARY_MONTH', { amountPerHead: '200.00' }, { amountPerHead: 200 }),
    ).toEqual([]);
  });

  it('returns nothing for entities without tracked fields or missing snapshots', () => {
    expect(diff('PROJECT_CONTRIBUTION', {}, { amount: 1 })).toEqual([]);
    expect(diff('PROJECT', null, { title: 'x' })).toEqual([]);
  });
});

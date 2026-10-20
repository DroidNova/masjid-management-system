import { Prisma } from '../../../generated/prisma/client';
import { NotificationsService } from './notifications.service';

describe('NotificationsService', () => {
  const prisma = {
    notification: {
      create: jest.fn(),
      findMany: jest.fn(),
      count: jest.fn(),
      updateMany: jest.fn(),
    },
    $transaction: jest.fn((operations: Promise<unknown>[]) =>
      Promise.all(operations),
    ),
  };
  const service = new NotificationsService(prisma as never);
  const committee = { id: 'committee-1', fullName: 'Karim' };
  const member = { id: 'member-1', masjidId: 'masjid-1' } as never;
  const notice = {
    masjidId: 'masjid-1',
    memberId: 'member-1',
    actor: committee,
    kind: 'PAYMENT_RECORDED' as const,
    entity: 'SALARY_PAYMENT' as const,
    entityId: 'sp-1',
    amount: new Prisma.Decimal('500.00'),
    paymentFor: { purpose: 'SALARY' as const, month: 10, year: 2026 },
  };

  beforeEach(() => jest.clearAllMocks());

  it('writes the notice for the member with plain amounts', async () => {
    const tx = { notification: { create: jest.fn() } };

    await service.paymentNotice(notice, tx as never);

    expect(tx.notification.create).toHaveBeenCalledWith({
      data: {
        masjidId: 'masjid-1',
        userId: 'member-1',
        kind: 'PAYMENT_RECORDED',
        entity: 'SALARY_PAYMENT',
        entityId: 'sp-1',
        actorName: 'Karim',
        data: { amount: 500, purpose: 'SALARY', month: 10, year: 2026 },
      },
    });
  });

  it('includes the new amount of an edit', async () => {
    await service.paymentNotice({
      ...notice,
      kind: 'PAYMENT_CHANGED',
      newAmount: '700',
    });

    expect(prisma.notification.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          data: expect.objectContaining({ amount: 500, newAmount: 700 }),
        }) as unknown,
      }),
    );
  });

  it('sends nothing without a member, or when they did it themselves', async () => {
    await service.paymentNotice({ ...notice, memberId: null });
    await service.paymentNotice({
      ...notice,
      actor: { id: 'member-1', fullName: 'Rafiq' },
    });

    expect(prisma.notification.create).not.toHaveBeenCalled();
  });

  it("lists and counts only the person's own notices in their masjid", async () => {
    prisma.notification.findMany.mockResolvedValue([]);
    prisma.notification.count.mockResolvedValue(0);

    await service.listMine({}, member);
    await service.unreadCount(member);

    const mine = { userId: 'member-1', masjidId: 'masjid-1' };
    expect(prisma.notification.findMany).toHaveBeenCalledWith(
      expect.objectContaining({ where: mine, orderBy: { createdAt: 'desc' } }),
    );
    expect(prisma.notification.count).toHaveBeenLastCalledWith({
      where: { ...mine, readAt: null },
    });
  });

  it('marks only unread notices of the person as read', async () => {
    prisma.notification.updateMany.mockResolvedValue({ count: 2 });

    await expect(service.markAllRead(member)).resolves.toEqual({ marked: 2 });
    expect(prisma.notification.updateMany).toHaveBeenCalledWith({
      where: { userId: 'member-1', masjidId: 'masjid-1', readAt: null },
      data: { readAt: expect.any(Date) as unknown },
    });
  });
});

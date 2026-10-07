import { Prisma } from '../../../generated/prisma/client';
import { AnnouncementsService } from './announcements.service';

describe('AnnouncementsService', () => {
  const prisma = {
    announcement: { findFirst: jest.fn(), update: jest.fn() },
  };
  const service = new AnnouncementsService(prisma as never);
  const actor = { id: 'admin-1', masjidId: 'masjid-1' } as never;
  const notFound = () =>
    new Prisma.PrismaClientKnownRequestError('No record', {
      code: 'P2025',
      clientVersion: 'test',
    });
  const expectNotFound = (promise: Promise<unknown>) =>
    expect(promise).rejects.toMatchObject({
      status: 404,
      response: expect.objectContaining({
        errorCode: 'ANNOUNCEMENT_NOT_FOUND',
      }) as unknown,
    });

  beforeEach(() => jest.clearAllMocks());

  it('reads one announcement with one scoped query', async () => {
    prisma.announcement.findFirst.mockResolvedValue({ id: 'a-1' });

    await expect(service.findOne('a-1', actor)).resolves.toEqual({
      id: 'a-1',
    });
    expect(prisma.announcement.findFirst).toHaveBeenCalledTimes(1);
    expect(prisma.announcement.findFirst).toHaveBeenCalledWith(
      expect.objectContaining({ where: { id: 'a-1', masjidId: 'masjid-1' } }),
    );
  });

  it('returns ANNOUNCEMENT_NOT_FOUND for a missing or other-masjid id', async () => {
    prisma.announcement.findFirst.mockResolvedValue(null);
    await expectNotFound(service.findOne('a-1', actor));

    prisma.announcement.update.mockRejectedValue(notFound());
    await expectNotFound(service.update('a-1', { title: 'New' }, actor));
    await expectNotFound(service.deactivate('a-1', actor));
  });

  it('updates with one scoped UPDATE', async () => {
    prisma.announcement.update.mockResolvedValue({ id: 'a-1', title: 'New' });

    await service.update('a-1', { title: 'New' }, actor);

    expect(prisma.announcement.update).toHaveBeenCalledTimes(1);
    expect(prisma.announcement.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: 'a-1', masjidId: 'masjid-1' },
        data: { title: 'New' },
      }),
    );
  });

  it('rejects an empty PATCH body before any database call', async () => {
    await expect(service.update('a-1', {}, actor)).rejects.toMatchObject({
      status: 400,
    });
    expect(prisma.announcement.update).not.toHaveBeenCalled();
  });

  it('lets other database errors through', async () => {
    const failure = new Error('database down');
    prisma.announcement.update.mockRejectedValue(failure);
    await expect(service.deactivate('a-1', actor)).rejects.toBe(failure);
  });
});

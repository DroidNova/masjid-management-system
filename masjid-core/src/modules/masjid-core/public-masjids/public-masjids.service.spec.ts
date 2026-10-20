import {
  normalizeMasjidCode,
  randomMasjidCode,
} from '../../../common/masjid-code';
import { PublicMasjidsService } from './public-masjids.service';

describe('PublicMasjidsService', () => {
  const prisma = {
    masjid: { findMany: jest.fn(), findFirst: jest.fn() },
    announcement: { findMany: jest.fn(), count: jest.fn() },
    $transaction: jest.fn((operations: Promise<unknown>[]) =>
      Promise.all(operations),
    ),
  };
  const service = new PublicMasjidsService(prisma as never);

  beforeEach(() => jest.clearAllMocks());

  /** The `select` of the first call, as a plain object. */
  const selectOf = (mock: jest.Mock) =>
    (mock.mock.calls[0] as [{ select: Record<string, unknown> }])[0].select;

  it('shows only the place, times and public news of an approved masjid', async () => {
    prisma.masjid.findFirst.mockResolvedValue({
      publicCode: 'K7M2QX',
      name: 'Jama Masjid',
      announcements: [],
      namazTime: null,
    });

    const page = await service.page('k7m-2qx');

    expect(page).toEqual({
      publicCode: 'K7M2QX',
      name: 'Jama Masjid',
      namazTime: null,
      latestAnnouncements: [],
    });
    const call = (
      prisma.masjid.findFirst.mock.calls[0] as [Record<string, unknown>]
    )[0];
    expect(call.where).toEqual({ publicCode: 'K7M2QX', status: 'APPROVED' });

    // The exact fields: adding one here must be a deliberate decision.
    const select = selectOf(prisma.masjid.findFirst);
    expect(Object.keys(select).sort()).toEqual([
      'address',
      'announcements',
      'district',
      'locality',
      'namazTime',
      'name',
      'publicCode',
      'state',
    ]);
    expect(select.announcements).toMatchObject({
      where: { isPublic: true, isActive: true },
      select: { id: true, title: true, message: true, createdAt: true },
    });
    expect(
      Object.keys(
        (select.namazTime as { select: Record<string, unknown> }).select,
      ),
    ).not.toContain('note');
  });

  it('answers 404 for an unknown code, and for a malformed one without a query', async () => {
    prisma.masjid.findFirst.mockResolvedValue(null);

    await expect(service.page('K7M2QX')).rejects.toMatchObject({
      status: 404,
    });
    prisma.masjid.findFirst.mockClear();
    await expect(service.page('not-a-code!')).rejects.toMatchObject({
      status: 404,
    });
    expect(prisma.masjid.findFirst).not.toHaveBeenCalled();
  });

  it('lists only public, active announcements', async () => {
    prisma.masjid.findFirst.mockResolvedValue({ id: 'masjid-1' });
    prisma.announcement.findMany.mockResolvedValue([]);
    prisma.announcement.count.mockResolvedValue(0);

    await service.announcements('K7M2QX', {});

    expect(prisma.announcement.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { masjidId: 'masjid-1', isPublic: true, isActive: true },
      }),
    );
    expect(Object.keys(selectOf(prisma.announcement.findMany)).sort()).toEqual([
      'createdAt',
      'id',
      'message',
      'title',
    ]);
  });

  it('searches approved masjids only, and needs two letters', async () => {
    prisma.masjid.findMany.mockResolvedValue([]);

    await expect(service.search(' a ')).resolves.toEqual({ items: [] });
    expect(prisma.masjid.findMany).not.toHaveBeenCalled();

    await service.search('Barota');
    expect(prisma.masjid.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({ status: 'APPROVED' }) as unknown,
        take: 20,
      }),
    );
    expect(Object.keys(selectOf(prisma.masjid.findMany)).sort()).toEqual([
      'address',
      'district',
      'locality',
      'name',
      'publicCode',
      'state',
    ]);
  });
});

describe('masjid codes', () => {
  it('are 6 characters without look-alikes', () => {
    for (let i = 0; i < 200; i++) {
      expect(randomMasjidCode()).toMatch(/^[A-HJKMNP-Z2-9]{6}$/);
    }
  });

  it('accept what people type and reject look-alikes', () => {
    expect(normalizeMasjidCode(' k7m-2qx ')).toBe('K7M2QX');
    expect(normalizeMasjidCode('K7M 2QX')).toBe('K7M2QX');
    expect(normalizeMasjidCode('K7M2Q0')).toBeNull();
    expect(normalizeMasjidCode('K7M2Q')).toBeNull();
  });
});

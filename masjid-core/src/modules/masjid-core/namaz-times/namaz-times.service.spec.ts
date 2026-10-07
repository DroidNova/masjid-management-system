import { permissionsForRoles } from '../../../access/permissions';
import { NamazTimesService } from './namaz-times.service';

const MASJID_A = '00000000-0000-4000-8000-00000000000a';
const MASJID_B = '00000000-0000-4000-8000-00000000000b';

function actor(role: string, masjidId: string | null = MASJID_A) {
  return {
    id: 'user-1',
    masjidId,
    roles: [role],
    permissions: permissionsForRoles([role]),
  } as never;
}

describe('NamazTimesService', () => {
  const prisma = {
    masjid: { findUnique: jest.fn() },
    namazTime: { findUnique: jest.fn(), upsert: jest.fn() },
  };
  const service = new NamazTimesService(prisma as never);

  beforeEach(() => jest.clearAllMocks());

  it('reads my masjid times with one query, masjid from the token', async () => {
    prisma.namazTime.findUnique.mockResolvedValue(null);

    const result = await service.findMyMasjid(actor('MEMBER'));

    expect(result).toMatchObject({ masjidId: MASJID_A, fajr: null });
    expect(prisma.namazTime.findUnique).toHaveBeenCalledWith(
      expect.objectContaining({ where: { masjidId: MASJID_A } }),
    );
    expect(prisma.masjid.findUnique).not.toHaveBeenCalled();
  });

  it('saves my masjid times with one upsert', async () => {
    prisma.namazTime.upsert.mockResolvedValue({ masjidId: MASJID_A });

    await service.upsertMyMasjid({ fajr: ' 05:00 ' }, actor('IMAM'));

    expect(prisma.namazTime.upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { masjidId: MASJID_A },
        create: { masjidId: MASJID_A, fajr: '05:00' },
        update: { fajr: '05:00' },
      }),
    );
    expect(prisma.masjid.findUnique).not.toHaveBeenCalled();
  });

  it('refuses another masjid before any query', async () => {
    await expect(
      service.findByMasjidId(MASJID_B, actor('MEMBER')),
    ).rejects.toMatchObject({
      response: expect.objectContaining({
        errorCode: 'MASJID_ACCESS_FORBIDDEN',
      }) as unknown,
    });
    expect(prisma.masjid.findUnique).not.toHaveBeenCalled();
    expect(prisma.namazTime.findUnique).not.toHaveBeenCalled();
  });

  it('lets a super admin read any existing masjid, and 404s a missing one', async () => {
    prisma.masjid.findUnique.mockResolvedValueOnce({ id: MASJID_B });
    prisma.namazTime.findUnique.mockResolvedValue(null);
    await expect(
      service.findByMasjidId(MASJID_B, actor('SUPER_ADMIN', null)),
    ).resolves.toMatchObject({ masjidId: MASJID_B });

    prisma.masjid.findUnique.mockResolvedValueOnce(null);
    await expect(
      service.findByMasjidId(MASJID_B, actor('SUPER_ADMIN', null)),
    ).rejects.toMatchObject({
      response: expect.objectContaining({
        errorCode: 'MASJID_NOT_FOUND',
      }) as unknown,
    });
  });
});

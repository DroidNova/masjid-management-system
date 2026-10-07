import * as bcrypt from 'bcrypt';
import { AppConfig } from '../../../config/app-config';
import { Prisma } from '../../../generated/prisma/client';
import { permissionsForRoles } from '../../../access/permissions';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import {
  CreateMasjidUserDto,
  CreateMasjidUserRoleDto,
} from './dto/create-masjid-user.dto';
import { MasjidsService } from './masjids.service';

jest.mock('bcrypt', () => ({
  hash: jest.fn(() => Promise.resolve('hashed')),
}));

const MASJID_A = '00000000-0000-4000-8000-00000000000a';
const MASJID_B = '00000000-0000-4000-8000-00000000000b';

const config = AppConfig.fromEnv({
  NODE_ENV: 'test',
  DATABASE_URL: 'postgresql://test:test@localhost:5432/test',
  JWT_ACCESS_SECRET: 'access-secret-for-tests-0123456789',
  JWT_REFRESH_SECRET: 'refresh-secret-for-tests-0123456789',
});

function actor(role: string, masjidId: string | null = MASJID_A) {
  return {
    id: `${role.toLowerCase()}-1`,
    masjidId,
    roles: [role],
    permissions: permissionsForRoles([role]),
  } as AuthenticatedUser;
}

const userRow = {
  id: 'existing-1',
  fullName: 'Rafiq',
  email: null,
  phone: '+919000000001',
  status: 'ACTIVE',
  masjidId: MASJID_A,
  fatherName: null,
  age: null,
  gender: null,
  isFamilyHead: true,
  familyMemberCount: 4,
  createdAt: new Date(),
  updatedAt: new Date(),
  userRoles: [{ role: { name: 'MEMBER' } }],
};

function createService() {
  const tx = {
    user: {
      create: jest.fn().mockResolvedValue({ ...userRow, id: 'new-1' }),
      update: jest.fn().mockResolvedValue(userRow),
      findFirst: jest.fn().mockResolvedValue(userRow),
    },
    masjid: {
      findUnique: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
    },
  };
  const prisma = {
    masjid: {
      findUnique: jest
        .fn()
        .mockResolvedValue({ id: MASJID_A, status: 'APPROVED' }),
      updateMany: jest.fn(),
    },
    user: {
      findFirst: jest.fn(),
      findUnique: jest.fn(),
      findMany: jest.fn(),
      update: jest.fn(),
    },
    $transaction: jest.fn((arg: unknown) =>
      typeof arg === 'function'
        ? (arg as (t: typeof tx) => unknown)(tx)
        : Promise.all(arg as Promise<unknown>[]),
    ),
  };
  const audit = { record: jest.fn() };
  return {
    service: new MasjidsService(prisma as never, config, audit as never),
    prisma,
    tx,
    audit,
  };
}

const newMember: CreateMasjidUserDto = {
  fullName: 'Rafiq',
  phone: '9000000001',
  fatherName: 'Karim',
  age: 40,
  gender: 'MALE',
  role: CreateMasjidUserRoleDto.MEMBER,
  isFamilyHead: true,
  familyMemberCount: 4,
} as CreateMasjidUserDto;

async function expectCode(promise: Promise<unknown>, errorCode: string) {
  await expect(promise).rejects.toMatchObject({
    response: expect.objectContaining({ errorCode }),
  });
}

describe('MasjidsService: one masjid per phone number', () => {
  it('refuses a person who already belongs to another masjid', async () => {
    const { service, prisma, tx } = createService();
    prisma.user.findFirst.mockResolvedValue({
      id: 'existing-1',
      masjidId: MASJID_B,
      userRoles: [{ role: { name: 'MEMBER' } }],
    });

    await expectCode(
      service.createMyMasjidUser(actor('COMMITTEE_MEMBER'), newMember),
      'USER_IN_ANOTHER_MASJID',
    );
    expect(tx.user.update).not.toHaveBeenCalled();
    expect(tx.user.create).not.toHaveBeenCalled();
  });

  it('refuses a person who is already in this masjid', async () => {
    const { service, prisma } = createService();
    prisma.user.findFirst.mockResolvedValue({
      id: 'existing-1',
      masjidId: MASJID_A,
      userRoles: [{ role: { name: 'MEMBER' } }],
    });

    await expectCode(
      service.createMyMasjidUser(actor('COMMITTEE_MEMBER'), newMember),
      'MASJID_USER_ALREADY_LINKED',
    );
  });

  it('adds a person who left their previous masjid, keeping their account', async () => {
    const { service, prisma, tx, audit } = createService();
    prisma.user.findFirst.mockResolvedValue({
      id: 'existing-1',
      masjidId: null,
      userRoles: [{ role: { name: 'MEMBER' } }],
    });

    const result = await service.createMyMasjidUser(
      actor('COMMITTEE_MEMBER'),
      newMember,
    );

    expect(result.id).toBe('existing-1');
    expect(tx.user.create).not.toHaveBeenCalled();
    expect(tx.user.update).toHaveBeenCalledWith(
      expect.objectContaining({
        // Only matches while they still have no masjid.
        where: { id: 'existing-1', masjidId: null },
        data: expect.objectContaining({
          masjidId: MASJID_A,
          userRoles: {
            deleteMany: {},
            create: { role: { connect: { name: 'MEMBER' } } },
          },
        }) as unknown,
      }),
    );
    // A linked member keeps their password: no hashing.
    expect(bcrypt.hash).not.toHaveBeenCalled();
    expect(audit.record).toHaveBeenCalledWith(
      expect.objectContaining({
        entity: 'MEMBER',
        action: 'JOIN',
        entityId: 'existing-1',
        masjidId: MASJID_A,
      }),
      tx,
    );
  });

  it('never links a super admin phone number to a masjid', async () => {
    const { service, prisma } = createService();
    prisma.user.findFirst.mockResolvedValue({
      id: 'sa',
      masjidId: null,
      userRoles: [{ role: { name: 'SUPER_ADMIN' } }],
    });

    await expectCode(
      service.createMyMasjidUser(actor('COMMITTEE_MEMBER'), newMember),
      'PHONE_ALREADY_EXISTS',
    );
  });
});

describe('MasjidsService: leave masjid', () => {
  it('removes the masjid, resets roles to MEMBER and clears the imam slot', async () => {
    const { service, tx, audit } = createService();
    const imam = actor('IMAM');

    await expect(service.leaveMyMasjid(imam)).resolves.toEqual({ left: true });

    expect(tx.user.update).toHaveBeenCalledWith({
      where: { id: imam.id },
      data: {
        masjidId: null,
        userRoles: {
          deleteMany: {},
          create: { role: { connect: { name: 'MEMBER' } } },
        },
      },
      select: { id: true },
    });
    expect(tx.masjid.updateMany).toHaveBeenCalledWith({
      where: { id: MASJID_A, imamUserId: imam.id },
      data: { imamUserId: null },
    });
    expect(audit.record).toHaveBeenCalledWith(
      expect.objectContaining({
        entity: 'MEMBER',
        action: 'LEAVE',
        entityId: imam.id,
        masjidId: MASJID_A,
      }),
      tx,
    );
  });

  it('refuses when the user has no masjid', async () => {
    const { service } = createService();
    await expectCode(
      service.leaveMyMasjid(actor('MEMBER', null)),
      'USER_MASJID_NOT_ASSIGNED',
    );
  });
});

describe('MasjidsService: member list privacy', () => {
  function withMembers() {
    const created = createService();
    const row = (id: string, phone: string) => ({
      id,
      fullName: id,
      email: `${id}@example.com`,
      phone,
      fatherName: null,
      age: null,
      gender: null,
      isFamilyHead: false,
      familyMemberCount: null,
      status: 'ACTIVE',
      masjidId: MASJID_A,
      createdAt: new Date(),
      updatedAt: new Date(),
      userRoles: [{ role: { name: 'MEMBER' } }],
    });
    created.prisma.user.findMany.mockResolvedValue([
      row('member-1', '+919000000001'),
      row('other', '+919000000002'),
    ]);
    return created;
  }

  it('hides other members phone and email from a member, but not their own', async () => {
    const { service } = withMembers();
    const list = await service.findMyMasjidUsers(actor('MEMBER'));

    const own = list.find((m) => m.id === 'member-1')!;
    const other = list.find((m) => m.id === 'other')!;
    expect(own.phone).toBe('+919000000001');
    expect(other.phone).toBeNull();
    expect(other.email).toBeNull();
    expect(other.fullName).toBe('other');
  });

  it.each([['IMAM'], ['COMMITTEE_MEMBER']])(
    'shows phone numbers to %s',
    async (role) => {
      const { service } = withMembers();
      const list = await service.findMyMasjidUsers(actor(role));
      expect(list.every((m) => m.phone)).toBe(true);
    },
  );
});

describe('MasjidsService: create user', () => {
  beforeEach(() => jest.clearAllMocks());

  it('creates the user, role link and response row in one call', async () => {
    const { service, prisma, tx } = createService();
    prisma.user.findFirst.mockResolvedValue(null);

    const result = await service.createMyMasjidUser(
      actor('COMMITTEE_MEMBER'),
      newMember,
    );

    expect(result.id).toBe('new-1');
    expect(tx.user.create).toHaveBeenCalledTimes(1);
    expect(tx.user.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          masjidId: MASJID_A,
          userRoles: { create: { role: { connect: { name: 'MEMBER' } } } },
        }) as unknown,
      }),
    );
  });

  it('lets a super admin choose the masjid in the body', async () => {
    const { service, prisma, tx } = createService();
    prisma.user.findFirst.mockResolvedValue(null);
    prisma.masjid.findUnique.mockResolvedValue({
      id: MASJID_B,
      status: 'APPROVED',
    });

    await service.createMyMasjidUser(actor('SUPER_ADMIN', MASJID_A), {
      ...newMember,
      masjidId: MASJID_B,
    } as CreateMasjidUserDto);

    expect(prisma.masjid.findUnique).toHaveBeenCalledWith(
      expect.objectContaining({ where: { id: MASJID_B } }),
    );
    expect(tx.user.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ masjidId: MASJID_B }) as unknown,
      }),
    );
  });

  it('refuses a duplicate email of a new user', async () => {
    const { service, prisma, tx } = createService();
    prisma.user.findFirst.mockResolvedValue(null);
    prisma.user.findUnique.mockResolvedValue({ id: 'someone' });

    await expectCode(
      service.createMyMasjidUser(actor('COMMITTEE_MEMBER'), {
        ...newMember,
        email: 'taken@example.com',
      } as CreateMasjidUserDto),
      'EMAIL_ALREADY_EXISTS',
    );
    expect(tx.user.create).not.toHaveBeenCalled();
  });
});

describe('MasjidsService: welcome message', () => {
  it('returns MASJID_NOT_FOUND only when the masjid is gone', async () => {
    const { service, prisma } = createService();
    (prisma.$transaction as jest.Mock).mockRejectedValueOnce(
      new Prisma.PrismaClientKnownRequestError('Not found', {
        code: 'P2025',
        clientVersion: 'test',
      }),
    );
    await expectCode(
      service.updateWelcomeMessage({ welcomeMsg: 'Hi' }, actor('IMAM')),
      'MASJID_NOT_FOUND',
    );
  });

  it('lets other errors through unchanged', async () => {
    const { service, prisma } = createService();
    const failure = new Error('database down');
    (prisma.$transaction as jest.Mock).mockRejectedValueOnce(failure);
    await expect(
      service.updateWelcomeMessage({ welcomeMsg: 'Hi' }, actor('IMAM')),
    ).rejects.toBe(failure);
  });
});

import { AppConfig } from '../../../config/app-config';
import { permissionsForRoles } from '../../../access/permissions';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import {
  CreateMasjidUserDto,
  CreateMasjidUserRoleDto,
} from './dto/create-masjid-user.dto';
import { MasjidsService } from './masjids.service';

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

function createService() {
  const tx = {
    user: {
      create: jest.fn(),
      update: jest.fn(),
      findUnique: jest.fn().mockResolvedValue({
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
      }),
    },
    userRole: { deleteMany: jest.fn(), create: jest.fn() },
    masjid: { update: jest.fn() },
  };
  const prisma = {
    masjid: {
      findUnique: jest
        .fn()
        .mockResolvedValue({ id: MASJID_A, status: 'APPROVED' }),
      updateMany: jest.fn(),
    },
    user: { findFirst: jest.fn(), findMany: jest.fn(), update: jest.fn() },
    role: {
      findUnique: jest
        .fn()
        .mockImplementation(({ where }: { where: { name: string } }) => ({
          id: `role-${where.name}`,
          name: where.name,
        })),
    },
    userRole: { deleteMany: jest.fn(), create: jest.fn() },
    $transaction: jest.fn((arg: unknown) =>
      typeof arg === 'function'
        ? (arg as (t: typeof tx) => unknown)(tx)
        : Promise.all(arg as Promise<unknown>[]),
    ),
  };
  return { service: new MasjidsService(prisma as never, config), prisma, tx };
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
    const { service, prisma, tx } = createService();
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
        where: { id: 'existing-1' },
        data: expect.objectContaining({ masjidId: MASJID_A }),
      }),
    );
    expect(tx.userRole.create).toHaveBeenCalledWith({
      data: { userId: 'existing-1', roleId: 'role-MEMBER' },
    });
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
    const { service, prisma } = createService();
    const imam = actor('IMAM');

    await expect(service.leaveMyMasjid(imam)).resolves.toEqual({ left: true });

    expect(prisma.user.update).toHaveBeenCalledWith({
      where: { id: imam.id },
      data: { masjidId: null },
    });
    expect(prisma.userRole.deleteMany).toHaveBeenCalledWith({
      where: { userId: imam.id },
    });
    expect(prisma.userRole.create).toHaveBeenCalledWith({
      data: { userId: imam.id, roleId: 'role-MEMBER' },
    });
    expect(prisma.masjid.updateMany).toHaveBeenCalledWith({
      where: { id: MASJID_A, imamUserId: imam.id },
      data: { imamUserId: null },
    });
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

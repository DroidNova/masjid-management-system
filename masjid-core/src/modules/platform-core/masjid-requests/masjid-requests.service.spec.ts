import { AppConfig } from '../../../config/app-config';
import { AuthenticatedUser } from '../auth/types/jwt-payload.type';
import { MasjidRequestStatusActionDto } from './dto/update-masjid-request-status.dto';
import { MasjidRequestsService } from './masjid-requests.service';

/* ------------------------------------------------------------------ */
/* In-memory stand-in for the Prisma calls used by approval/rejection. */
/* ------------------------------------------------------------------ */

type Row = Record<string, any>;
type Where = Record<string, any>;

function matches(row: Row, where: Where = {}): boolean {
  return Object.entries(where).every(([key, condition]) => {
    if (key === 'OR')
      return (condition as Where[]).some((w) => matches(row, w));
    if (condition && typeof condition === 'object' && 'in' in condition) {
      return (condition.in as unknown[]).includes(row[key]);
    }
    if (condition && typeof condition === 'object' && 'not' in condition) {
      return row[key] !== condition.not;
    }
    return row[key] === condition;
  });
}

function createFakePrisma() {
  const requests: Row[] = [];
  const users: Row[] = [];
  const masjids: Row[] = [];
  const userRoles: Row[] = [];
  const calls = { userFindMany: 0, userCreateMany: 0 };

  const prisma: Row = {
    masjidRegistrationRequest: {
      create: async ({ data }: { data: Row }) => {
        const row: Row = { id: `req-${requests.length + 1}`, ...data };
        requests.push(row);
        return { ...row };
      },
      findUnique: async ({ where }: { where: Where }) => {
        const row = requests.find((r) => r.id === where.id);
        return row ? { ...row } : null;
      },
      updateMany: async ({ where, data }: { where: Where; data: Row }) => {
        const hits = requests.filter((r) => matches(r, where));
        hits.forEach((r) => Object.assign(r, data));
        return { count: hits.length };
      },
      update: async ({ where, data }: { where: Where; data: Row }) => {
        const row = requests.find((r) => r.id === where.id)!;
        Object.assign(row, data);
        return { ...row };
      },
    },
    user: {
      findMany: async ({ where }: { where: Where }) => {
        calls.userFindMany++;
        return users.filter((u) => matches(u, where)).map((u) => ({ ...u }));
      },
      createMany: async ({ data }: { data: Row[] }) => {
        calls.userCreateMany++;
        for (const row of data) {
          if (row.phone && users.some((u) => u.phone === row.phone)) {
            throw new Error('Unique constraint failed on phone');
          }
          users.push({ masjidId: null, ...row });
        }
        return { count: data.length };
      },
      updateMany: async ({ where, data }: { where: Where; data: Row }) => {
        const hits = users.filter((u) => matches(u, where));
        hits.forEach((u) => Object.assign(u, data));
        return { count: hits.length };
      },
    },
    masjid: {
      create: async ({ data }: { data: Row }) => {
        const row: Row = { id: `masjid-${masjids.length + 1}`, ...data };
        masjids.push(row);
        return { id: row.id, name: row.name, status: row.status };
      },
    },
    userRole: {
      createMany: async ({ data }: { data: Row[] }) => {
        for (const row of data) {
          if (
            !userRoles.some(
              (r) => r.userId === row.userId && r.roleId === row.roleId,
            )
          ) {
            userRoles.push(row);
          }
        }
        return { count: data.length };
      },
    },
  };
  prisma.$transaction = async (fn: (tx: unknown) => Promise<unknown>) =>
    fn(prisma);

  return { prisma, requests, users, masjids, userRoles, calls };
}

const IMAM_PHONE = '+919800000001';
const CM1_PHONE = '+919800000002';
const CM2_PHONE = '+919800000003';

function pendingRequest(overrides: Row = {}): Row {
  return {
    id: 'req-1',
    status: 'PENDING',
    masjidName: 'Jama Masjid',
    locality: 'Old Town',
    district: 'Bhopal',
    country: 'India',
    state: 'MP',
    address: 'Main road',
    contactNo: null,
    description: null,
    welcomeMsg: null,
    requesterName: 'Requester',
    requesterPhone: '+919800000009',
    requesterEmail: null,
    imamName: 'Imam Sahab',
    imamPhone: IMAM_PHONE,
    imamEmail: 'imam@example.com',
    imamAddress: 'Near masjid',
    imamFatherName: 'Father',
    imamAge: 45,
    imamGender: 'MALE',
    committeeMembers: [
      { name: 'Member One', phone: CM1_PHONE },
      { name: 'Member Two', phone: CM2_PHONE },
    ],
    rejectionReason: null,
    reviewedAt: null,
    reviewedById: null,
    createdMasjidId: null,
    ...overrides,
  };
}

function setup() {
  const fake = createFakePrisma();
  const config = AppConfig.fromEnv({
    NODE_ENV: 'test',
    DATABASE_URL: 'postgresql://test:test@localhost:5432/test',
    JWT_ACCESS_SECRET: 'access-secret-for-tests-0123456789',
    JWT_REFRESH_SECRET: 'refresh-secret-for-tests-0123456789',
  });
  const roles = {
    validateRoleNames: jest.fn(async (names: string[]) =>
      names.map((name) => ({ id: `role-${name}`, name })),
    ),
  };
  const audit = { record: jest.fn() };
  const service = new MasjidRequestsService(
    fake.prisma as never,
    config,
    audit as never,
    roles as never,
  );
  return { ...fake, service, audit };
}

const admin = { id: 'admin-1', fullName: 'Admin' } as AuthenticatedUser;
const approve = { status: MasjidRequestStatusActionDto.APPROVED };
const reject = {
  status: MasjidRequestStatusActionDto.REJECTED,
  reason: 'Duplicate',
};

async function expectCode(promise: Promise<unknown>, errorCode: string) {
  await expect(promise).rejects.toMatchObject({
    response: expect.objectContaining({ errorCode }),
  });
}

describe('MasjidRequestsService approval', () => {
  it('creates the masjid, users, links and roles with a fixed number of queries', async () => {
    const { service, requests, users, masjids, userRoles, calls } = setup();
    requests.push(pendingRequest());
    // Committee member one already has an account (stored without +91).
    users.push({
      id: 'existing-cm',
      fullName: 'Member One',
      phone: '9800000002',
      email: null,
      masjidId: null,
    });

    const result = await service.updateStatus('req-1', approve, admin);

    expect(result).toMatchObject({
      status: 'APPROVED',
      createdMasjidId: 'masjid-1',
      reviewedById: 'admin-1',
    });
    expect(masjids).toHaveLength(1);
    expect(calls).toEqual({ userFindMany: 1, userCreateMany: 1 });

    const imam = users.find((u) => u.phone === IMAM_PHONE)!;
    const cm2 = users.find((u) => u.phone === CM2_PHONE)!;
    expect(imam.email).toBe('imam@example.com');
    expect(masjids[0].imamUserId).toBe(imam.id);
    expect(users.map((u) => u.masjidId)).toEqual([
      'masjid-1',
      'masjid-1',
      'masjid-1',
    ]);
    expect(userRoles).toEqual(
      expect.arrayContaining([
        { userId: imam.id, roleId: 'role-IMAM' },
        { userId: 'existing-cm', roleId: 'role-COMMITTEE_MEMBER' },
        { userId: cm2.id, roleId: 'role-COMMITTEE_MEMBER' },
      ]),
    );
    expect(userRoles).toHaveLength(3);
    // Dev mode: every new user shares one hash of the dev password.
    expect(imam.passwordHash).toBe(cm2.passwordHash);
  });

  it('lets only one of two simultaneous approvals through', async () => {
    const { service, requests, masjids } = setup();
    requests.push(pendingRequest());

    const results = await Promise.allSettled([
      service.updateStatus('req-1', approve, admin),
      service.updateStatus('req-1', approve, admin),
    ]);

    expect(results.map((r) => r.status).sort()).toEqual([
      'fulfilled',
      'rejected',
    ]);
    const failure = results.find(
      (r): r is PromiseRejectedResult => r.status === 'rejected',
    )!;
    expect(failure.reason).toMatchObject({
      response: expect.objectContaining({
        errorCode: 'MASJID_REQUEST_ALREADY_APPROVED',
      }),
    });
    expect(masjids).toHaveLength(1);
  });

  it('answers a second approval with ALREADY_APPROVED', async () => {
    const { service, requests } = setup();
    requests.push(pendingRequest());

    await service.updateStatus('req-1', approve, admin);
    await expectCode(
      service.updateStatus('req-1', approve, admin),
      'MASJID_REQUEST_ALREADY_APPROVED',
    );
    await expectCode(
      service.updateStatus('req-1', reject, admin),
      'MASJID_REQUEST_ALREADY_APPROVED',
    );
  });

  it('decides a parallel approve and reject exactly once', async () => {
    const { service, requests, masjids } = setup();
    requests.push(pendingRequest());

    const results = await Promise.allSettled([
      service.updateStatus('req-1', approve, admin),
      service.updateStatus('req-1', reject, admin),
    ]);

    // The reject skips password hashing, so it wins the race here.
    expect(results.map((r) => r.status)).toEqual(['rejected', 'fulfilled']);
    expect(results[0]).toMatchObject({
      reason: {
        response: expect.objectContaining({
          errorCode: 'MASJID_REQUEST_ALREADY_REJECTED',
        }),
      },
    });
    expect(requests[0].status).toBe('REJECTED');
    expect(masjids).toHaveLength(0);
  });

  it('never binds an account found only by the imam email', async () => {
    const { service, requests, users, masjids } = setup();
    requests.push(pendingRequest());
    users.push({
      id: 'someone-else',
      fullName: 'Someone Else',
      phone: '+919811111111',
      email: 'imam@example.com',
      masjidId: null,
    });

    await expectCode(
      service.updateStatus('req-1', approve, admin),
      'EMAIL_ALREADY_EXISTS',
    );
    expect(users).toHaveLength(1);
    expect(users[0].masjidId).toBeNull();
    expect(masjids).toHaveLength(0);
    expect(requests[0].status).toBe('PENDING');
  });

  it('links an existing imam found by phone even if the email differs', async () => {
    const { service, requests, users, masjids } = setup();
    requests.push(pendingRequest());
    users.push({
      id: 'imam-existing',
      fullName: 'Imam Sahab',
      phone: IMAM_PHONE,
      email: 'other@example.com',
      masjidId: null,
    });

    await service.updateStatus('req-1', approve, admin);
    expect(masjids[0].imamUserId).toBe('imam-existing');
    expect(users[0].email).toBe('other@example.com');
  });

  it('refuses a committee member who belongs to another masjid', async () => {
    const { service, requests, users, masjids } = setup();
    requests.push(pendingRequest());
    users.push({
      id: 'busy',
      fullName: 'Member Two',
      phone: CM2_PHONE,
      email: null,
      masjidId: 'other-masjid',
    });

    await expect(
      service.updateStatus('req-1', approve, admin),
    ).rejects.toMatchObject({
      response: expect.objectContaining({
        errorCode: 'USER_IN_ANOTHER_MASJID',
        message: expect.stringContaining(`Committee member ${CM2_PHONE}`),
      }),
    });
    expect(masjids).toHaveLength(0);
  });

  it('returns 404 for an unknown request', async () => {
    const { service } = setup();
    await expectCode(
      service.updateStatus('missing', approve, admin),
      'MASJID_REQUEST_NOT_FOUND',
    );
    await expectCode(service.findOne('missing'), 'MASJID_REQUEST_NOT_FOUND');
  });

  it('rejects a pending request with the reason', async () => {
    const { service, requests, audit } = setup();
    requests.push(pendingRequest());

    const result = await service.updateStatus('req-1', reject, admin);
    expect(result).toMatchObject({
      status: 'REJECTED',
      rejectionReason: 'Duplicate',
      reviewedById: 'admin-1',
    });
    expect(audit.record).toHaveBeenCalledTimes(1);
    await expectCode(
      service.updateStatus('req-1', reject, admin),
      'MASJID_REQUEST_ALREADY_REJECTED',
    );
  });
});

describe('MasjidRequestsService submission', () => {
  const submission = {
    requesterName: 'Requester',
    requesterPhone: '+919800000009',
    masjidName: 'Jama Masjid',
    country: 'India',
    locality: 'Old Town',
    district: 'Bhopal',
    state: 'MP',
    address: 'Main road',
    imamName: 'Imam Sahab',
    imamPhone: IMAM_PHONE,
    imamAddress: 'Near masjid',
    imamFatherName: 'Father',
    imamAge: 45,
    imamGender: 'MALE',
    committeeMembers: [
      { name: 'Member One', phone: CM1_PHONE },
      { name: 'Member Two', phone: CM2_PHONE },
    ],
  } as never;

  it('refuses a phone that already belongs to a masjid, naming the person from the request', async () => {
    const { service, requests, users } = setup();
    users.push({
      id: 'busy',
      fullName: 'Name In Other Masjid',
      phone: CM2_PHONE,
      masjidId: 'other-masjid',
    });

    await expect(service.create(submission)).rejects.toMatchObject({
      response: expect.objectContaining({
        errorCode: 'USER_IN_ANOTHER_MASJID',
        message: expect.stringContaining(`Member Two (${CM2_PHONE})`),
      }),
    });
    expect(requests).toHaveLength(0);
  });

  it('accepts a phone whose account has no masjid', async () => {
    const { service, requests, users } = setup();
    users.push({ id: 'free', phone: IMAM_PHONE, masjidId: null });

    await service.create(submission);
    expect(requests).toHaveLength(1);
  });
});

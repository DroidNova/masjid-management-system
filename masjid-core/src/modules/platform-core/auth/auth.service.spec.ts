import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { AppConfig } from '../../../config/app-config';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthService, hashToken } from './auth.service';
import { OtpService } from './services/otp.service';
import { AuthenticatedUser } from './types/jwt-payload.type';

/* ------------------------------------------------------------------ */
/* Minimal in-memory stand-in for the Prisma calls the auth code uses. */
/* ------------------------------------------------------------------ */

type UserRow = {
  id: string;
  fullName: string;
  email: string | null;
  phone: string | null;
  status: string;
  masjidId: string | null;
  isEmailVerified: boolean;
  isPhoneVerified: boolean;
  createdAt: Date;
  updatedAt: Date;
  passwordHash: string;
  roles: string[];
};

type SessionRow = {
  id: string;
  userId: string;
  refreshTokenHash: string;
  userAgent: string | null;
  ipAddress: string | null;
  expiresAt: Date;
};

type OtpRow = {
  id: string;
  phone: string;
  purpose: string;
  codeHash: string;
  passwordVerified: boolean;
  attempts: number;
  expiresAt: Date;
  consumedAt: Date | null;
};

type Where = Record<string, any>;

function matches(row: Record<string, any>, where: Where = {}): boolean {
  return Object.entries(where).every(([key, condition]) => {
    if (key === 'OR') {
      return (condition as Where[]).some((w) => matches(row, w));
    }
    const value = row[key];
    if (
      condition &&
      typeof condition === 'object' &&
      !(condition instanceof Date)
    ) {
      if ('in' in condition) return condition.in.includes(value);
      if ('not' in condition) return value !== condition.not;
      if ('lt' in condition) return value !== null && value < condition.lt;
      if ('gt' in condition) return value !== null && value > condition.gt;
    }
    return value === condition;
  });
}

function createFakePrisma() {
  const users: UserRow[] = [];
  const sessions: SessionRow[] = [];
  const otps: OtpRow[] = [];

  const withAccess = (user: UserRow | undefined) =>
    user && {
      ...user,
      userRoles: user.roles.map((name) => ({
        role: { name, rolePermissions: [] },
      })),
    };

  const deleteWhere = <T extends Record<string, any>>(
    rows: T[],
    where: Where,
  ) => {
    let count = 0;
    for (let i = rows.length - 1; i >= 0; i--) {
      if (matches(rows[i], where)) {
        rows.splice(i, 1);
        count++;
      }
    }
    return { count };
  };

  const updateWhere = <T extends Record<string, any>>(
    rows: T[],
    where: Where,
    data: Partial<T>,
  ) => {
    const hits = rows.filter((row) => matches(row, where));
    hits.forEach((row) => Object.assign(row, data));
    return { count: hits.length };
  };

  const prisma = {
    user: {
      findFirst: async ({ where }: { where: Where }) =>
        withAccess(users.find((u) => matches(u, where))) ?? null,
      findUnique: async ({ where }: { where: Where }) =>
        withAccess(users.find((u) => u.id === where.id)) ?? null,
      update: async ({
        where,
        data,
      }: {
        where: Where;
        data: Partial<UserRow>;
      }) => {
        updateWhere(users, where, data);
        return users.find((u) => u.id === where.id);
      },
    },
    session: {
      create: async ({ data }: { data: SessionRow }) => {
        sessions.push({ ...data });
        return data;
      },
      findFirst: async ({ where }: { where: Where }) =>
        sessions.find((s) => matches(s, where)) ?? null,
      updateMany: async ({
        where,
        data,
      }: {
        where: Where;
        data: Partial<SessionRow>;
      }) => updateWhere(sessions, where, data),
      deleteMany: async ({ where }: { where: Where }) =>
        deleteWhere(sessions, where),
    },
    otpChallenge: {
      create: async ({
        data,
      }: {
        data: Omit<OtpRow, 'attempts' | 'consumedAt'>;
      }) => {
        const row = { attempts: 0, consumedAt: null, ...data };
        otps.push(row);
        return row;
      },
      findUnique: async ({ where }: { where: Where }) =>
        otps.find((o) => o.id === where.id) ?? null,
      update: async ({
        where,
        data,
      }: {
        where: Where;
        data: Partial<OtpRow>;
      }) => {
        updateWhere(otps, where, data);
        return otps.find((o) => o.id === where.id);
      },
      updateMany: async ({
        where,
        data,
      }: {
        where: Where;
        data: Partial<OtpRow>;
      }) => updateWhere(otps, where, data),
      deleteMany: async ({ where }: { where: Where }) =>
        deleteWhere(otps, where),
    },
    $transaction: async (operations: Promise<unknown>[]) =>
      Promise.all(operations),
  };

  return { prisma, users, sessions, otps };
}

/* ------------------------------------------------------------------ */

const PASSWORD = '123456';
const MEMBER_PHONE = '+919876500001';
const IMAM_PHONE = '+919876500002';

function testConfig(overrides: Record<string, string> = {}) {
  return AppConfig.fromEnv({
    NODE_ENV: 'test',
    DATABASE_URL: 'postgresql://test:test@localhost:5432/test',
    JWT_ACCESS_SECRET: 'access-secret-for-tests-0123456789',
    JWT_REFRESH_SECRET: 'refresh-secret-for-tests-0123456789',
    ...overrides,
  });
}

async function setup(overrides: Record<string, string> = {}) {
  const fake = createFakePrisma();
  const config = testConfig(overrides);
  const prisma = fake.prisma as unknown as PrismaService;
  const otpService = new OtpService(prisma, config);
  const service = new AuthService(
    prisma,
    new JwtService({}),
    otpService,
    config,
  );

  const passwordHash = await bcrypt.hash(PASSWORD, 4);
  const now = new Date();
  const baseUser = {
    email: null,
    status: 'ACTIVE',
    masjidId: 'masjid-1',
    isEmailVerified: false,
    isPhoneVerified: false,
    createdAt: now,
    updatedAt: now,
    passwordHash,
  };
  fake.users.push(
    {
      ...baseUser,
      id: 'member-1',
      fullName: 'Member',
      phone: MEMBER_PHONE,
      roles: ['MEMBER'],
    },
    {
      ...baseUser,
      id: 'imam-1',
      fullName: 'Imam',
      phone: IMAM_PHONE,
      roles: ['IMAM'],
    },
  );

  return { ...fake, config, otpService, service };
}

async function loginMember(service: AuthService) {
  const start = await service.startLogin({ phone: MEMBER_PHONE });
  return service.verifyOtp({
    phone: MEMBER_PHONE,
    challengeId: start.challengeId!,
    otp: '1111',
  });
}

async function loginImam(service: AuthService) {
  const pw = await service.verifyPassword({
    phone: IMAM_PHONE,
    password: PASSWORD,
  });
  return service.verifyOtp({
    phone: IMAM_PHONE,
    challengeId: pw.challengeId,
    otp: '1111',
  });
}

function actorFor(userId: string, sessionId: string): AuthenticatedUser {
  return { id: userId, sessionId } as AuthenticatedUser;
}

async function sessionIdOf(
  service: AuthService,
  refreshToken: string,
  sessions: SessionRow[],
) {
  const hash = hashToken(refreshToken);
  return sessions.find((s) => s.refreshTokenHash === hash)!.id;
}

async function expectCode(promise: Promise<unknown>, errorCode: string) {
  await expect(promise).rejects.toMatchObject({
    response: expect.objectContaining({ errorCode }),
  });
}

describe('AuthService', () => {
  describe('member OTP login (dev mode)', () => {
    it('asks for a 4-digit OTP and logs in with 1111', async () => {
      const { service, users, sessions } = await setup();

      const start = await service.startLogin({ phone: MEMBER_PHONE });
      expect(start).toMatchObject({ nextStep: 'OTP_REQUIRED', otpLength: 4 });

      const result = await service.verifyOtp({
        phone: MEMBER_PHONE,
        challengeId: start.challengeId!,
        otp: '1111',
      });

      expect(result.tokens.accessToken).toBeTruthy();
      expect(result.user.roles).toEqual(['MEMBER']);
      expect(users[0].isPhoneVerified).toBe(true);
      expect(sessions).toHaveLength(1);
      // Only a SHA-256 hash of the refresh token is stored.
      expect(sessions[0].refreshTokenHash).toBe(
        hashToken(result.tokens.refreshToken),
      );
    });

    it('rejects a wrong OTP and expires the challenge after 5 attempts', async () => {
      const { service } = await setup();
      const start = await service.startLogin({ phone: MEMBER_PHONE });
      const attempt = (otp: string) =>
        service.verifyOtp({
          phone: MEMBER_PHONE,
          challengeId: start.challengeId!,
          otp,
        });

      for (let i = 0; i < 4; i++) {
        await expectCode(attempt('9999'), 'OTP_INVALID');
      }
      await expectCode(attempt('9999'), 'OTP_EXPIRED');
      // Even the right code no longer works.
      await expectCode(attempt('1111'), 'OTP_EXPIRED');
    });

    it('does not accept the same challenge twice', async () => {
      const { service } = await setup();
      const start = await service.startLogin({ phone: MEMBER_PHONE });
      const dto = {
        phone: MEMBER_PHONE,
        challengeId: start.challengeId!,
        otp: '1111',
      };

      await service.verifyOtp(dto);
      await expectCode(service.verifyOtp(dto), 'OTP_CHALLENGE_INVALID');
    });

    it('invalidates the previous challenge when a new OTP is requested', async () => {
      const { service, otps } = await setup();
      const first = await service.startLogin({ phone: MEMBER_PHONE });
      await service.startLogin({ phone: MEMBER_PHONE });

      expect(otps).toHaveLength(1);
      await expectCode(
        service.verifyOtp({
          phone: MEMBER_PHONE,
          challengeId: first.challengeId!,
          otp: '1111',
        }),
        'OTP_CHALLENGE_INVALID',
      );
    });

    it('rejects an expired challenge', async () => {
      const { service, otps } = await setup();
      const start = await service.startLogin({ phone: MEMBER_PHONE });
      otps[0].expiresAt = new Date(Date.now() - 1000);

      await expectCode(
        service.verifyOtp({
          phone: MEMBER_PHONE,
          challengeId: start.challengeId!,
          otp: '1111',
        }),
        'OTP_EXPIRED',
      );
    });

    it('does not allow members to log in with a password', async () => {
      const { service } = await setup();
      await expectCode(
        service.verifyPassword({ phone: MEMBER_PHONE, password: PASSWORD }),
        'PASSWORD_LOGIN_NOT_ALLOWED_FOR_MEMBER',
      );
    });
  });

  describe('imam / committee login (password, then OTP)', () => {
    it('requires the password step first', async () => {
      const { service } = await setup();
      const start = await service.startLogin({ phone: IMAM_PHONE });
      expect(start).toMatchObject({ nextStep: 'PASSWORD_REQUIRED' });
      expect(start.challengeId).toBeUndefined();
    });

    it('rejects a wrong password', async () => {
      const { service } = await setup();
      await expectCode(
        service.verifyPassword({ phone: IMAM_PHONE, password: 'wrong' }),
        'INVALID_CREDENTIALS',
      );
    });

    it('logs in with the dev password 123456 and OTP 1111', async () => {
      const { service } = await setup();
      const result = await loginImam(service);
      expect(result.user.roles).toEqual(['IMAM']);
    });

    it('rejects an OTP challenge that skipped the password step', async () => {
      const { service, otpService } = await setup();
      const challenge = await otpService.create(IMAM_PHONE, {
        passwordVerified: false,
      });

      await expectCode(
        service.verifyOtp({
          phone: IMAM_PHONE,
          challengeId: challenge.challengeId,
          otp: '1111',
        }),
        'OTP_CHALLENGE_INVALID',
      );
    });
  });

  describe('non-dev mode', () => {
    it('uses a random 6-digit code, so 1111 is rejected', async () => {
      const { service } = await setup({
        AUTH_DEV_MODE: 'false',
        AUTH_OTP_LENGTH: '6',
      });
      const start = await service.startLogin({ phone: MEMBER_PHONE });
      expect(start.otpLength).toBe(6);

      await expectCode(
        service.verifyOtp({
          phone: MEMBER_PHONE,
          challengeId: start.challengeId!,
          otp: '1111',
        }),
        'OTP_INVALID',
      );
    });
  });

  describe('refresh token rotation', () => {
    it('issues a new refresh token and keeps the same session', async () => {
      const { service, sessions } = await setup();
      const login = await loginMember(service);

      const refreshed = await service.refreshToken({
        refreshToken: login.tokens.refreshToken,
      });

      expect(refreshed.tokens.refreshToken).not.toBe(login.tokens.refreshToken);
      expect(sessions).toHaveLength(1);
      expect(sessions[0].refreshTokenHash).toBe(
        hashToken(refreshed.tokens.refreshToken),
      );
    });

    it('revokes the session when an old refresh token is reused', async () => {
      const { service, sessions } = await setup();
      const login = await loginMember(service);
      const refreshed = await service.refreshToken({
        refreshToken: login.tokens.refreshToken,
      });

      await expectCode(
        service.refreshToken({ refreshToken: login.tokens.refreshToken }),
        'SESSION_REVOKED',
      );
      expect(sessions).toHaveLength(0);
      // The attacker's copy and the real one are both dead now.
      await expectCode(
        service.refreshToken({ refreshToken: refreshed.tokens.refreshToken }),
        'SESSION_EXPIRED',
      );
    });

    it('rejects an access token used as a refresh token', async () => {
      const { service } = await setup();
      const login = await loginMember(service);
      await expectCode(
        service.refreshToken({ refreshToken: login.tokens.accessToken }),
        'UNAUTHORIZED',
      );
    });

    it('rejects refresh after logout', async () => {
      const { service, sessions } = await setup();
      const login = await loginMember(service);

      await service.logout({ refreshToken: login.tokens.refreshToken });

      expect(sessions).toHaveLength(0);
      await expectCode(
        service.refreshToken({ refreshToken: login.tokens.refreshToken }),
        'SESSION_EXPIRED',
      );
    });
  });

  describe('logout-all', () => {
    it('removes every session of the user only', async () => {
      const { service, sessions } = await setup();
      const phone = await loginMember(service);
      await loginMember(service);
      await loginImam(service);
      const sid = await sessionIdOf(
        service,
        phone.tokens.refreshToken,
        sessions,
      );

      const result = await service.logoutAll(actorFor('member-1', sid));

      expect(result).toEqual({ revokedSessions: 2 });
      expect(sessions.map((s) => s.userId)).toEqual(['imam-1']);
    });
  });

  describe('password change', () => {
    it('updates the password and signs out other sessions only', async () => {
      const { service, sessions, users } = await setup();
      const current = await loginImam(service);
      await loginImam(service);
      const sid = await sessionIdOf(
        service,
        current.tokens.refreshToken,
        sessions,
      );

      const result = await service.changePassword(actorFor('imam-1', sid), {
        currentPassword: PASSWORD,
        newPassword: 'new-secret-1',
      });

      expect(result).toEqual({
        passwordChanged: true,
        otherSessionsSignedOut: 1,
      });
      expect(sessions.map((s) => s.id)).toEqual([sid]);
      const imam = users.find((u) => u.id === 'imam-1')!;
      expect(await bcrypt.compare('new-secret-1', imam.passwordHash)).toBe(
        true,
      );
    });

    it('rejects a wrong current password', async () => {
      const { service, sessions } = await setup();
      const login = await loginImam(service);
      const sid = await sessionIdOf(
        service,
        login.tokens.refreshToken,
        sessions,
      );

      await expectCode(
        service.changePassword(actorFor('imam-1', sid), {
          currentPassword: 'wrong',
          newPassword: 'new-secret-1',
        }),
        'INVALID_CREDENTIALS',
      );
    });

    it('rejects reusing the same password', async () => {
      const { service, sessions } = await setup();
      const login = await loginImam(service);
      const sid = await sessionIdOf(
        service,
        login.tokens.refreshToken,
        sessions,
      );

      await expectCode(
        service.changePassword(actorFor('imam-1', sid), {
          currentPassword: PASSWORD,
          newPassword: PASSWORD,
        }),
        'PASSWORD_UNCHANGED',
      );
    });

    it('is not available to members', async () => {
      const { service, sessions } = await setup();
      const login = await loginMember(service);
      const sid = await sessionIdOf(
        service,
        login.tokens.refreshToken,
        sessions,
      );

      await expectCode(
        service.changePassword(actorFor('member-1', sid), {
          currentPassword: PASSWORD,
          newPassword: 'new-secret-1',
        }),
        'PASSWORD_CHANGE_NOT_ALLOWED',
      );
    });
  });

  describe('cleanup', () => {
    it('deletes expired sessions and stale OTP challenges', async () => {
      const { service, otpService, sessions, otps } = await setup();
      await loginMember(service);
      await service.startLogin({ phone: MEMBER_PHONE });
      sessions[0].expiresAt = new Date(Date.now() - 1000);
      otps[0].expiresAt = new Date(Date.now() - 2 * 60 * 60 * 1000);

      expect(await service.deleteExpiredSessions()).toBe(1);
      expect(await otpService.deleteStale()).toBe(1);
    });
  });
});

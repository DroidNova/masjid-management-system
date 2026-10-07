import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { createHash, randomUUID } from 'node:crypto';
import { PrismaService } from '../../../prisma/prisma.service';
import { AppConfig } from '../../../config/app-config';
import { Prisma } from '../../../generated/prisma/client';
import { AuthResponseDto } from './dto/auth-response.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { LoginPasswordDto } from './dto/login-password.dto';
import { LoginStartDto } from './dto/login-start.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { AuthenticatedUser, JwtPayload } from './types/jwt-payload.type';
import { ApiException } from '../../../common/exceptions/api.exception';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { successResponse } from '../../../common/helpers/api-response.helper';
import { OtpService } from './services/otp.service';
import { permissionsForRoles } from '../../../access/permissions';
import {
  getPhoneSearchVariants,
  normalizePhone,
} from '../../../common/utils/phone.util';

export const BCRYPT_ROUNDS = 10;

/** Roles that must enter a password before the OTP step. */
const PRIVILEGED_ROLES = new Set([
  'SUPER_ADMIN',
  'MASJID_ADMIN',
  'IMAM',
  'COMMITTEE_MEMBER',
]);

/**
 * bcrypt hash (cost 10) of a random throwaway string. Compared against when
 * the phone is unknown, so the response time does not reveal whether an
 * account exists.
 */
const DUMMY_PASSWORD_HASH =
  '$2b$10$H9d6nvzQgiZbH33t3jhx7ueg.o/YPRJbQwk3qMJap2i2NCKcwCNFW';

/**
 * Columns of the signed-in user returned to the app, plus role names.
 * Permissions are derived from the roles in code (src/access/permissions.ts).
 * Never includes the password hash.
 */
export const USER_ACCESS_SELECT = {
  id: true,
  fullName: true,
  email: true,
  phone: true,
  status: true,
  masjidId: true,
  isEmailVerified: true,
  isPhoneVerified: true,
  isFamilyHead: true,
  createdAt: true,
  updatedAt: true,
  userRoles: { select: { role: { select: { name: true } } } },
} as const satisfies Prisma.UserSelect;

type SafeUser = Omit<AuthenticatedUser, 'sessionId'>;

type UserWithAccess = Prisma.UserGetPayload<{
  select: typeof USER_ACCESS_SELECT;
}>;

type RoleRows = { userRoles: Array<{ role: { name: string } }> };

export function toSafeUser(user: UserWithAccess): SafeUser {
  const roles = user.userRoles.map((userRole) => userRole.role.name);

  return {
    id: user.id,
    fullName: user.fullName,
    email: user.email,
    phone: user.phone,
    status: user.status,
    masjidId: user.masjidId,
    isEmailVerified: user.isEmailVerified,
    isPhoneVerified: user.isPhoneVerified,
    isFamilyHead: user.isFamilyHead,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
    roles,
    permissions: permissionsForRoles(roles),
  };
}

/** Refresh tokens are long random JWTs, so a fast hash is enough to store them. */
export function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly otpService: OtpService,
    private readonly config: AppConfig,
  ) {}

  async startLogin(loginStartDto: LoginStartDto) {
    const phone = normalizePhone(loginStartDto.phone);
    const user = await this.findUserByPhone(phone, {
      id: true,
      status: true,
      userRoles: USER_ACCESS_SELECT.userRoles,
    });
    if (!user) throw this.invalidCredentials();
    this.assertUserActive(user);

    if (this.hasPrivilegedRole(user)) {
      this.logger.debug({ message: 'Password step required', userId: user.id });
      return {
        nextStep: 'PASSWORD_REQUIRED',
        phone,
        message: 'Password required',
      };
    }

    const challenge = await this.otpService.create(phone);
    this.logger.debug({
      message: 'OTP challenge created',
      userId: user.id,
      challengeId: challenge.challengeId,
    });

    return {
      nextStep: 'OTP_REQUIRED',
      challengeId: challenge.challengeId,
      otpLength: challenge.otpLength,
      phone,
      message: 'OTP sent successfully',
    };
  }

  /**
   * Password step for privileged roles. The bcrypt comparison always runs
   * (against a dummy hash for unknown phones) so timing does not reveal
   * whether the phone exists, and the account status is only reported after
   * a correct password.
   */
  async verifyPassword(loginPasswordDto: LoginPasswordDto) {
    const phone = normalizePhone(loginPasswordDto.phone);
    const password =
      typeof loginPasswordDto.password === 'string'
        ? loginPasswordDto.password
        : '';

    if (!phone || !password) throw this.invalidCredentials();

    const user = await this.findUserByPhone(phone, {
      id: true,
      status: true,
      passwordHash: true,
      userRoles: USER_ACCESS_SELECT.userRoles,
    });
    const passwordMatches = await bcrypt.compare(
      password,
      user?.passwordHash ?? DUMMY_PASSWORD_HASH,
    );

    if (!user) throw this.invalidCredentials();

    // Not a secret: /login/start already tells the app members use OTP only.
    if (!this.hasPrivilegedRole(user)) {
      throw new ApiException(
        'Members are not allowed to login using password',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.PASSWORD_LOGIN_NOT_ALLOWED_FOR_MEMBER,
      );
    }

    if (!passwordMatches) throw this.invalidCredentials();
    this.assertUserActive(user);

    const challenge = await this.otpService.create(phone, {
      passwordVerified: true,
    });
    this.logger.debug({
      message: 'Password verified, OTP challenge created',
      userId: user.id,
      challengeId: challenge.challengeId,
    });

    return {
      nextStep: 'OTP_REQUIRED',
      challengeId: challenge.challengeId,
      otpLength: challenge.otpLength,
      phone,
      message: 'OTP sent successfully',
    };
  }

  async verifyOtp(
    verifyOtpDto: VerifyOtpDto,
    userAgent?: string,
    ipAddress?: string,
  ): Promise<AuthResponseDto> {
    const phone = normalizePhone(verifyOtpDto.phone);
    const challenge = await this.otpService.verify(
      verifyOtpDto.challengeId.trim(),
      phone,
      verifyOtpDto.otp.trim(),
    );

    const user = await this.findUserByPhone(phone, USER_ACCESS_SELECT);
    if (!user) throw this.invalidCredentials();
    this.assertUserActive(user);

    if (this.hasPrivilegedRole(user) && !challenge.passwordVerified) {
      throw new ApiException(
        'Password verification is required before OTP verification',
        HttpStatus.UNAUTHORIZED,
        ERROR_CODES.OTP_CHALLENGE_INVALID,
      );
    }

    const sessionId = randomUUID();
    const tokens = await this.signTokens(user.id, sessionId);
    const createSession = this.prisma.session.create({
      data: {
        id: sessionId,
        userId: user.id,
        refreshTokenHash: hashToken(tokens.refreshToken),
        userAgent: userAgent?.slice(0, 500) || null,
        ipAddress: ipAddress || null,
        expiresAt: this.refreshExpiryDate(),
      },
      select: { id: true },
    });

    if (user.isPhoneVerified) {
      await createSession;
    } else {
      await this.prisma.$transaction([
        createSession,
        this.prisma.user.update({
          where: { id: user.id },
          data: { isPhoneVerified: true },
          select: { id: true },
        }),
      ]);
      user.isPhoneVerified = true;
    }

    this.logger.log({ message: 'User authenticated', userId: user.id });
    return { user: toSafeUser(user), tokens };
  }

  /**
   * Rotates the refresh token. Presenting an old (already rotated) refresh
   * token means it was copied, so the whole session is revoked.
   */
  async refreshToken(
    refreshTokenDto: RefreshTokenDto,
  ): Promise<AuthResponseDto> {
    const presented = refreshTokenDto.refreshToken;
    const payload = await this.verifyRefreshToken(presented);

    const session = await this.prisma.session.findFirst({
      where: { id: payload.sid, userId: payload.sub },
      select: {
        id: true,
        userId: true,
        refreshTokenHash: true,
        expiresAt: true,
        user: { select: USER_ACCESS_SELECT },
      },
    });

    if (!session || session.expiresAt.getTime() <= Date.now()) {
      throw new ApiException(
        'Your session has expired. Please login again.',
        HttpStatus.UNAUTHORIZED,
        ERROR_CODES.SESSION_EXPIRED,
      );
    }

    const presentedHash = hashToken(presented);
    if (session.refreshTokenHash !== presentedHash) {
      await this.revokeForReuse(session.id, session.userId);
    }

    const { user } = session;
    if (user.status !== 'ACTIVE') {
      // A deactivated account cannot keep refreshing; end the session now.
      await this.prisma.session.deleteMany({ where: { id: session.id } });
      throw this.userInactive();
    }

    const tokens = await this.signTokens(user.id, session.id);
    // Conditional on the old hash so two concurrent refreshes cannot both win.
    const rotated = await this.prisma.session.updateMany({
      where: { id: session.id, refreshTokenHash: presentedHash },
      data: {
        refreshTokenHash: hashToken(tokens.refreshToken),
        expiresAt: this.refreshExpiryDate(),
      },
    });
    if (rotated.count !== 1) {
      await this.revokeForReuse(session.id, session.userId);
    }

    return { user: toSafeUser(user), tokens };
  }

  /** Always succeeds with data null; an invalid token has nothing to end. */
  async logout(refreshTokenDto: RefreshTokenDto) {
    const payload = await this.verifyRefreshToken(
      refreshTokenDto.refreshToken,
      true,
    );

    if (payload) {
      await this.prisma.session.deleteMany({
        where: { id: payload.sid, userId: payload.sub },
      });
    }

    return successResponse('Logged out successfully');
  }

  /** Ends every session of the user, including the current one. */
  async logoutAll(actor: AuthenticatedUser) {
    const result = await this.prisma.session.deleteMany({
      where: { userId: actor.id },
    });
    this.logger.log({
      message: 'All sessions revoked',
      userId: actor.id,
      count: result.count,
    });
    return { revokedSessions: result.count };
  }

  /**
   * Changes the password of an imam, committee member or admin. Members log in
   * with OTP only and have no password. Other sessions are signed out.
   */
  async changePassword(actor: AuthenticatedUser, dto: ChangePasswordDto) {
    if (!actor.roles.some((role) => PRIVILEGED_ROLES.has(role))) {
      throw new ApiException(
        'Members log in with OTP and do not have a password',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.PASSWORD_CHANGE_NOT_ALLOWED,
      );
    }

    if (dto.currentPassword === dto.newPassword) {
      throw new ApiException(
        'New password must be different from the current password',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.PASSWORD_UNCHANGED,
      );
    }

    const user = await this.prisma.user.findUnique({
      where: { id: actor.id },
      select: { passwordHash: true },
    });
    if (!user) {
      throw new ApiException(
        'User not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.USER_NOT_FOUND,
      );
    }

    if (!(await bcrypt.compare(dto.currentPassword, user.passwordHash))) {
      throw new ApiException(
        'Current password is incorrect',
        HttpStatus.UNAUTHORIZED,
        ERROR_CODES.INVALID_CREDENTIALS,
      );
    }

    const passwordHash = await bcrypt.hash(dto.newPassword, BCRYPT_ROUNDS);
    const [, revoked] = await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: actor.id },
        data: { passwordHash },
        select: { id: true },
      }),
      this.prisma.session.deleteMany({
        where: { userId: actor.id, id: { not: actor.sessionId } },
      }),
    ]);

    this.logger.log({
      message: 'Password changed',
      userId: actor.id,
      revokedSessions: revoked.count,
    });
    return {
      passwordChanged: true,
      otherSessionsSignedOut: revoked.count,
    };
  }

  /** Deletes sessions whose refresh token has expired. */
  async deleteExpiredSessions(): Promise<number> {
    const result = await this.prisma.session.deleteMany({
      where: { expiresAt: { lt: new Date() } },
    });
    return result.count;
  }

  private async signTokens(
    userId: string,
    sessionId: string,
  ): Promise<AuthResponseDto['tokens']> {
    const { jwt } = this.config;
    const access: JwtPayload = { sub: userId, sid: sessionId, typ: 'access' };
    const refresh: JwtPayload = {
      sub: userId,
      sid: sessionId,
      typ: 'refresh',
      jti: randomUUID(),
    };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(access, {
        secret: jwt.accessSecret,
        expiresIn: jwt.accessExpiresIn,
      }),
      this.jwtService.signAsync(refresh, {
        secret: jwt.refreshSecret,
        expiresIn: jwt.refreshExpiresIn,
      }),
    ]);

    return {
      accessToken,
      refreshToken,
      accessTokenExpiresIn: jwt.accessExpiresInSeconds,
    };
  }

  private async revokeForReuse(
    sessionId: string,
    userId: string,
  ): Promise<never> {
    await this.prisma.session.deleteMany({ where: { id: sessionId } });
    this.logger.warn({
      message: 'Refresh token reuse detected; session revoked',
      userId,
      sessionId,
    });
    throw new ApiException(
      'This session was signed out for security. Please login again.',
      HttpStatus.UNAUTHORIZED,
      ERROR_CODES.SESSION_REVOKED,
    );
  }

  private refreshExpiryDate(): Date {
    return new Date(
      Date.now() + this.config.jwt.refreshExpiresInSeconds * 1000,
    );
  }

  private async verifyRefreshToken(token: string): Promise<JwtPayload>;
  private async verifyRefreshToken(
    token: string,
    silent: true,
  ): Promise<JwtPayload | null>;
  private async verifyRefreshToken(
    token: string,
    silent = false,
  ): Promise<JwtPayload | null> {
    try {
      const payload = await this.jwtService.verifyAsync<JwtPayload>(token, {
        secret: this.config.jwt.refreshSecret,
      });
      if (payload.typ !== 'refresh' || !payload.sid || !payload.sub) {
        throw new Error('Not a refresh token');
      }
      return payload;
    } catch {
      if (silent) return null;
      throw new ApiException(
        'Invalid refresh token',
        HttpStatus.UNAUTHORIZED,
        ERROR_CODES.UNAUTHORIZED,
      );
    }
  }

  private findUserByPhone<S extends Prisma.UserSelect>(
    phone: string,
    select: S,
  ) {
    return this.prisma.user.findFirst({
      where: { phone: { in: getPhoneSearchVariants(phone) } },
      select,
    });
  }

  private invalidCredentials(): ApiException {
    return new ApiException(
      'Invalid phone or password',
      HttpStatus.UNAUTHORIZED,
      ERROR_CODES.INVALID_CREDENTIALS,
    );
  }

  private userInactive(): ApiException {
    return new ApiException(
      'This account is not active. Please contact your masjid.',
      HttpStatus.FORBIDDEN,
      ERROR_CODES.USER_INACTIVE,
    );
  }

  private assertUserActive(user: { status: string }): void {
    if (user.status !== 'ACTIVE') throw this.userInactive();
  }

  private hasPrivilegedRole(user: RoleRows): boolean {
    return user.userRoles.some((userRole) =>
      PRIVILEGED_ROLES.has(userRole.role.name),
    );
  }
}

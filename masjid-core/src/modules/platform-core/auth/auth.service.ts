import { ForbiddenException, Injectable, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { createHash, randomUUID } from 'node:crypto';
import { PrismaService } from '../../../prisma/prisma.service';
import { AppConfig } from '../../../config/app-config';
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

/** Prisma include that loads a user's roles and their permissions. */
export const USER_ACCESS_INCLUDE = {
  userRoles: {
    include: {
      role: {
        include: { rolePermissions: { include: { permission: true } } },
      },
    },
  },
} as const;

type SafeUser = Omit<AuthenticatedUser, 'sessionId'>;

type UserWithAccess = {
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
  userRoles: Array<{
    role: {
      name: string;
      rolePermissions: Array<{ permission: { name: string } }>;
    };
  }>;
};

export function toSafeUser(
  user: Omit<UserWithAccess, 'passwordHash'>,
): SafeUser {
  const permissions = Array.from(
    new Set(
      user.userRoles.flatMap((userRole) =>
        userRole.role.rolePermissions.map((rp) => rp.permission.name),
      ),
    ),
  );

  return {
    id: user.id,
    fullName: user.fullName,
    email: user.email,
    phone: user.phone,
    status: user.status,
    masjidId: user.masjidId,
    isEmailVerified: user.isEmailVerified,
    isPhoneVerified: user.isPhoneVerified,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
    roles: user.userRoles.map((userRole) => userRole.role.name),
    permissions,
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
    const user = await this.getUserByPhoneOrThrow(phone);
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

  async verifyPassword(loginPasswordDto: LoginPasswordDto) {
    const invalidCredentials = new ApiException(
      'Invalid phone or password',
      401,
      ERROR_CODES.INVALID_CREDENTIALS,
    );
    const phone = normalizePhone(loginPasswordDto.phone);
    const password =
      typeof loginPasswordDto.password === 'string'
        ? loginPasswordDto.password
        : '';

    if (!phone || !password) throw invalidCredentials;

    const user = await this.getUserByPhoneOrThrow(phone);
    this.assertUserActive(user);

    if (!this.hasPrivilegedRole(user)) {
      throw new ApiException(
        'Members are not allowed to login using password',
        403,
        ERROR_CODES.PASSWORD_LOGIN_NOT_ALLOWED_FOR_MEMBER,
      );
    }

    if (!(await bcrypt.compare(password, user.passwordHash))) {
      throw invalidCredentials;
    }

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

    const user = await this.getUserByPhoneOrThrow(phone);
    this.assertUserActive(user);

    if (this.hasPrivilegedRole(user) && !challenge.passwordVerified) {
      throw new ApiException(
        'Password verification is required before OTP verification',
        401,
        ERROR_CODES.OTP_CHALLENGE_INVALID,
      );
    }

    if (!user.isPhoneVerified) {
      await this.prisma.user.update({
        where: { id: user.id },
        data: { isPhoneVerified: true },
      });
      user.isPhoneVerified = true;
    }

    this.logger.log({ message: 'User authenticated', userId: user.id });
    return this.createSession(user, userAgent, ipAddress);
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
    });

    if (!session || session.expiresAt.getTime() <= Date.now()) {
      throw new ApiException(
        'Your session has expired. Please login again.',
        401,
        ERROR_CODES.SESSION_EXPIRED,
      );
    }

    const presentedHash = hashToken(presented);
    if (session.refreshTokenHash !== presentedHash) {
      await this.revokeForReuse(session.id, session.userId);
    }

    const user = await this.getUserByIdOrThrow(payload.sub);
    if (user.status !== 'ACTIVE') {
      throw new ForbiddenException('User is not active');
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
    const user = await this.getUserByIdOrThrow(actor.id);

    if (!this.hasPrivilegedRole(user)) {
      throw new ApiException(
        'Members log in with OTP and do not have a password',
        403,
        ERROR_CODES.PASSWORD_CHANGE_NOT_ALLOWED,
      );
    }

    if (!(await bcrypt.compare(dto.currentPassword, user.passwordHash))) {
      throw new ApiException(
        'Current password is incorrect',
        401,
        ERROR_CODES.INVALID_CREDENTIALS,
      );
    }

    if (dto.currentPassword === dto.newPassword) {
      throw new ApiException(
        'New password must be different from the current password',
        400,
        ERROR_CODES.PASSWORD_UNCHANGED,
      );
    }

    const passwordHash = await bcrypt.hash(dto.newPassword, BCRYPT_ROUNDS);
    const [, revoked] = await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: user.id },
        data: { passwordHash },
      }),
      this.prisma.session.deleteMany({
        where: { userId: user.id, id: { not: actor.sessionId } },
      }),
    ]);

    this.logger.log({
      message: 'Password changed',
      userId: user.id,
      revokedSessions: revoked.count,
    });
    return {
      passwordChanged: true,
      otherSessionsSignedOut: revoked.count,
    };
  }

  async getCurrentUser(userId: string): Promise<SafeUser> {
    const user = await this.getUserByIdOrThrow(userId);
    this.assertUserActive(user);
    return toSafeUser(user);
  }

  /** Deletes sessions whose refresh token has expired. */
  async deleteExpiredSessions(): Promise<number> {
    const result = await this.prisma.session.deleteMany({
      where: { expiresAt: { lt: new Date() } },
    });
    return result.count;
  }

  private async createSession(
    user: UserWithAccess,
    userAgent?: string,
    ipAddress?: string,
  ): Promise<AuthResponseDto> {
    const sessionId = randomUUID();
    const tokens = await this.signTokens(user.id, sessionId);

    await this.prisma.session.create({
      data: {
        id: sessionId,
        userId: user.id,
        refreshTokenHash: hashToken(tokens.refreshToken),
        userAgent: userAgent?.slice(0, 500) || null,
        ipAddress: ipAddress || null,
        expiresAt: this.refreshExpiryDate(),
      },
    });

    return { user: toSafeUser(user), tokens };
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
      401,
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
        401,
        ERROR_CODES.UNAUTHORIZED,
      );
    }
  }

  private async getUserByPhoneOrThrow(phone: string): Promise<UserWithAccess> {
    const user = await this.prisma.user.findFirst({
      where: { phone: { in: getPhoneSearchVariants(phone) } },
      include: USER_ACCESS_INCLUDE,
    });

    if (!user) {
      throw new ApiException(
        'Invalid phone or password',
        401,
        ERROR_CODES.INVALID_CREDENTIALS,
      );
    }

    return user;
  }

  private async getUserByIdOrThrow(userId: string): Promise<UserWithAccess> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: USER_ACCESS_INCLUDE,
    });

    if (!user) {
      throw new ApiException('User not found', 404, ERROR_CODES.NOT_FOUND);
    }

    return user;
  }

  private assertUserActive(user: UserWithAccess): void {
    if (user.status !== 'ACTIVE') {
      throw new ForbiddenException('User is not active');
    }
  }

  private hasPrivilegedRole(user: UserWithAccess): boolean {
    return user.userRoles.some((userRole) =>
      PRIVILEGED_ROLES.has(userRole.role.name),
    );
  }
}

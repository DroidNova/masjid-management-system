import { ForbiddenException, Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthResponseDto } from './dto/auth-response.dto';
import { LoginPasswordDto } from './dto/login-password.dto';
import { LoginStartDto } from './dto/login-start.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { JwtPayload } from './types/jwt-payload.type';
import { ApiException } from '../../../common/exceptions/api.exception';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { successResponse } from '../../../common/helpers/api-response.helper';
import { OtpChallengeService } from './services/otp-challenge.service';
import { getPhoneSearchVariants, normalizePhone } from '../../../common/utils/phone.util';

type SafeUser = {
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
  roles: string[];
  permissions: string[];
};

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

type TokenDuration = `${number}${'s' | 'm' | 'h' | 'd'}`;

@Injectable()
export class AuthService {
  private readonly jwtAccessSecret = process.env.JWT_ACCESS_SECRET ?? '';
  private readonly jwtRefreshSecret = process.env.JWT_REFRESH_SECRET ?? '';
  private readonly jwtAccessExpiresIn: TokenDuration = this.parseTokenDuration(
    process.env.JWT_ACCESS_EXPIRES_IN,
    '15m',
  );
  private readonly jwtRefreshExpiresIn: TokenDuration = this.parseTokenDuration(
    process.env.JWT_REFRESH_EXPIRES_IN,
    '30d',
  );

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly otpChallengeService: OtpChallengeService,
  ) {
    if (!this.jwtAccessSecret || !this.jwtRefreshSecret) {
      throw new Error('JWT_ACCESS_SECRET and JWT_REFRESH_SECRET are required');
    }
  }

  async startLogin(loginStartDto: LoginStartDto) {
    const phone = this.normalizePhone(loginStartDto.phone);
    const user = await this.getUserByPhoneOrThrow(phone);
    this.assertUserActive(user);

    if (this.hasPrivilegedRole(user)) {
      return {
        nextStep: 'PASSWORD_REQUIRED',
        phone,
        message: 'Password required',
      };
    }

    const challenge = this.otpChallengeService.create(phone, false);
    await this.sendOtp(phone);

    return {
      nextStep: 'OTP_REQUIRED',
      challengeId: challenge.challengeId,
      phone,
      message: 'OTP sent successfully',
    };
  }

  async verifyPassword(loginPasswordDto: LoginPasswordDto) {
    const invalidCredentialsMessage = 'Invalid phone or password';
    const phone = this.normalizePhone(loginPasswordDto.phone);
    const password =
      typeof loginPasswordDto.password === 'string'
        ? loginPasswordDto.password
        : '';

    if (!phone || !password) {
      throw new ApiException(
        invalidCredentialsMessage,
        401,
        ERROR_CODES.INVALID_CREDENTIALS,
      );
    }

    const user = await this.getUserByPhoneOrThrow(phone);
    this.assertUserActive(user);

    if (!this.hasPrivilegedRole(user)) {
      throw new ApiException(
        'Members are not allowed to login using password',
        403,
        ERROR_CODES.PASSWORD_LOGIN_NOT_ALLOWED_FOR_MEMBER,
      );
    }

    const isPasswordValid = await this.compareData(password, user.passwordHash);

    if (!isPasswordValid) {
      throw new ApiException(
        invalidCredentialsMessage,
        401,
        ERROR_CODES.INVALID_CREDENTIALS,
      );
    }

    const challenge = this.otpChallengeService.create(phone, true);
    await this.sendOtp(phone);

    return {
      nextStep: 'OTP_REQUIRED',
      challengeId: challenge.challengeId,
      phone,
      message: 'OTP sent successfully',
    };
  }

  async verifyOtp(
    verifyOtpDto: VerifyOtpDto,
    userAgent?: string,
  ): Promise<AuthResponseDto> {
    const phone = this.normalizePhone(verifyOtpDto.phone);
    const challengeId = verifyOtpDto.challengeId.trim();
    const otp = verifyOtpDto.otp.trim();

    const challenge = this.otpChallengeService.get(challengeId);

    if (!challenge || challenge.used || challenge.phone !== phone) {
      throw new ApiException(
        'Invalid OTP challenge',
        401,
        ERROR_CODES.OTP_CHALLENGE_INVALID,
      );
    }

    if (otp !== this.getMockOtp()) {
      const attempts = this.otpChallengeService.incrementAttempts(challengeId);
      throw new ApiException(
        this.otpChallengeService.isMaxAttemptsReached(attempts)
          ? 'OTP challenge expired'
          : 'Invalid OTP',
        401,
        this.otpChallengeService.isMaxAttemptsReached(attempts)
          ? ERROR_CODES.OTP_EXPIRED
          : ERROR_CODES.OTP_INVALID,
      );
    }

    const user = await this.getUserByPhoneOrThrow(phone);
    this.assertUserActive(user);

    if (this.hasPrivilegedRole(user) && !challenge.passwordVerified) {
      throw new ApiException(
        'Password verification is required before OTP verification',
        401,
        ERROR_CODES.OTP_CHALLENGE_INVALID,
      );
    }

    this.otpChallengeService.remove(challengeId);

    return this.createAuthenticatedSession(user, userAgent);
  }

  async refreshToken(
    refreshTokenDto: RefreshTokenDto,
  ): Promise<AuthResponseDto> {
    const decoded = await this.verifyRefreshToken(refreshTokenDto.refreshToken);
    const user = await this.getUserByIdOrThrow(decoded.sub);

    if (user.status !== 'ACTIVE') {
      throw new ForbiddenException('User is not active');
    }

    const sessions = await this.prisma.session.findMany({
      where: {
        userId: user.id,
        expiresAt: {
          gt: new Date(),
        },
      },
      orderBy: {
        updatedAt: 'desc',
      },
    });

    if (!sessions.length) {
      throw new ApiException(
        'Invalid refresh token',
        401,
        ERROR_CODES.UNAUTHORIZED,
      );
    }

    let matchedSessionId: string | null = null;

    for (const session of sessions) {
      const isMatch = await this.compareData(
        refreshTokenDto.refreshToken,
        session.refreshTokenHash,
      );

      if (isMatch) {
        matchedSessionId = session.id;
        break;
      }
    }

    if (!matchedSessionId) {
      throw new ApiException(
        'Invalid refresh token',
        401,
        ERROR_CODES.UNAUTHORIZED,
      );
    }

    const tokens = await this.generateTokens(user.id);
    const newRefreshTokenHash = await this.hashData(tokens.refreshToken);

    await this.prisma.session.update({
      where: { id: matchedSessionId },
      data: {
        refreshTokenHash: newRefreshTokenHash,
        expiresAt: this.buildFutureDateFromDuration(this.jwtRefreshExpiresIn),
      },
    });

    return {
      user: this.toSafeUser(user),
      tokens,
    };
  }

  async logout(refreshTokenDto: RefreshTokenDto) {
    const decoded = await this.verifyRefreshToken(
      refreshTokenDto.refreshToken,
      true,
    );

    if (!decoded) {
      return successResponse('Logged out successfully');
    }

    const sessions = await this.prisma.session.findMany({
      where: { userId: decoded.sub },
      select: {
        id: true,
        refreshTokenHash: true,
      },
    });

    const matchingSession = await this.findMatchingSessionId(
      sessions,
      refreshTokenDto.refreshToken,
    );

    if (matchingSession) {
      await this.prisma.session.delete({ where: { id: matchingSession } });
    }

    return successResponse('Logged out successfully');
  }

  async getCurrentUser(userId: string): Promise<SafeUser> {
    const user = await this.getUserByIdOrThrow(userId);

    if (user.status !== 'ACTIVE') {
      throw new ForbiddenException('User is not active');
    }

    return this.toSafeUser(user);
  }

  async generateTokens(userId: string): Promise<AuthResponseDto['tokens']> {
    const payload: JwtPayload = { sub: userId };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: this.jwtAccessSecret,
        expiresIn: this.jwtAccessExpiresIn,
      }),
      this.jwtService.signAsync(payload, {
        secret: this.jwtRefreshSecret,
        expiresIn: this.jwtRefreshExpiresIn,
      }),
    ]);

    return {
      accessToken,
      refreshToken,
      accessTokenExpiresIn: this.durationToSeconds(this.jwtAccessExpiresIn),
    };
  }

  async hashData(value: string): Promise<string> {
    return bcrypt.hash(value, 10);
  }

  async compareData(value: string, hash: string): Promise<boolean> {
    return bcrypt.compare(value, hash);
  }

  private async createAuthenticatedSession(
    user: UserWithAccess,
    userAgent?: string,
    deviceName?: string,
  ): Promise<AuthResponseDto> {
    const initialRefreshTokenHash = await this.hashData(
      `${user.id}:${Date.now()}`,
    );
    const session = await this.prisma.session.create({
      data: {
        userId: user.id,
        refreshTokenHash: initialRefreshTokenHash,
        deviceName: deviceName?.trim() || null,
        userAgent: userAgent || null,
        expiresAt: this.buildFutureDateFromDuration(this.jwtRefreshExpiresIn),
      },
    });

    const tokens = await this.generateTokens(user.id);
    const refreshTokenHash = await this.hashData(tokens.refreshToken);

    await this.prisma.session.update({
      where: { id: session.id },
      data: {
        refreshTokenHash,
        expiresAt: this.buildFutureDateFromDuration(this.jwtRefreshExpiresIn),
      },
    });

    return {
      user: this.toSafeUser(user),
      tokens,
    };
  }

  private async getUserByPhoneOrThrow(phone: string): Promise<UserWithAccess> {
    const phoneVariants = getPhoneSearchVariants(phone);
    const user = await this.prisma.user.findFirst({
      where: { phone: { in: phoneVariants } },
      include: {
        userRoles: {
          include: {
            role: {
              include: {
                rolePermissions: {
                  include: {
                    permission: true,
                  },
                },
              },
            },
          },
        },
      },
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

  private assertUserActive(user: UserWithAccess): void {
    if (user.status !== 'ACTIVE') {
      throw new ForbiddenException('User is not active');
    }
  }

  private hasPrivilegedRole(user: UserWithAccess): boolean {
    const privilegedRoles = new Set([
      'SUPER_ADMIN',
      'MASJID_ADMIN',
      'IMAM',
      'COMMITTEE_MEMBER',
    ]);

    return user.userRoles.some((userRole) =>
      privilegedRoles.has(userRole.role.name),
    );
  }

  private normalizePhone(phone: string): string {
    return normalizePhone(phone);
  }

  private getMockOtp(): string {
    return '111111';
  }

  private async sendOtp(_phone: string): Promise<void> {
    // TODO: Replace mock OTP 111111 with real SMS OTP provider before production.
    // TODO: Add rate limiting for OTP sends before production.
    return Promise.resolve();
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
      return await this.jwtService.verifyAsync<JwtPayload>(token, {
        secret: this.jwtRefreshSecret,
      });
    } catch {
      if (silent) {
        return null;
      }
      throw new ApiException(
        'Invalid refresh token',
        401,
        ERROR_CODES.UNAUTHORIZED,
      );
    }
  }

  private async getUserByIdOrThrow(userId: string): Promise<UserWithAccess> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        userRoles: {
          include: {
            role: {
              include: {
                rolePermissions: {
                  include: {
                    permission: true,
                  },
                },
              },
            },
          },
        },
      },
    });

    if (!user) {
      throw new ApiException('User not found', 404, ERROR_CODES.NOT_FOUND);
    }

    return user;
  }

  private toSafeUser(user: UserWithAccess): SafeUser {
    const permissions = Array.from(
      new Set(
        user.userRoles.flatMap((userRole) =>
          userRole.role.rolePermissions.map(
            (rolePermission) => rolePermission.permission.name,
          ),
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

  private durationToSeconds(value: TokenDuration): number {
    const match = /^([0-9]+)(s|m|h|d)$/i.exec(value);

    if (!match) {
      return 900;
    }

    const amount = Number(match[1]);
    const unit = match[2].toLowerCase();

    if (unit === 's') return amount;
    if (unit === 'm') return amount * 60;
    if (unit === 'h') return amount * 3600;
    return amount * 86400;
  }

  private buildFutureDateFromDuration(duration: TokenDuration): Date {
    const seconds = this.durationToSeconds(duration);
    return new Date(Date.now() + seconds * 1000);
  }

  private parseTokenDuration(
    value: string | undefined,
    fallback: TokenDuration,
  ): TokenDuration {
    if (!value) {
      return fallback;
    }

    const normalized = value.trim();
    if (/^[0-9]+(s|m|h|d)$/i.test(normalized)) {
      return normalized as TokenDuration;
    }

    return fallback;
  }

  private async findMatchingSessionId(
    sessions: Array<{ id: string; refreshTokenHash: string }>,
    refreshToken: string,
  ): Promise<string | null> {
    for (const session of sessions) {
      const matched = await this.compareData(
        refreshToken,
        session.refreshTokenHash,
      );
      if (matched) {
        return session.id;
      }
    }

    return null;
  }
}

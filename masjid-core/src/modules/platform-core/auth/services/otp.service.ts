import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import {
  createHash,
  randomInt,
  randomUUID,
  timingSafeEqual,
} from 'node:crypto';
import { PrismaService } from '../../../../prisma/prisma.service';
import { AppConfig } from '../../../../config/app-config';
import { ApiException } from '../../../../common/exceptions/api.exception';
import {
  ERROR_CODES,
  type ErrorCode,
} from '../../../../common/constants/error-codes.constant';
import { OtpPurpose } from '../../../../generated/prisma/enums';

export type CreatedOtpChallenge = {
  challengeId: string;
  otpLength: number;
  expiresAt: Date;
};

export type VerifiedOtpChallenge = {
  challengeId: string;
  phone: string;
  passwordVerified: boolean;
};

const HOUR_MS = 60 * 60 * 1000;

/**
 * Creates and verifies one-time passwords stored in the OtpChallenge table.
 *
 * Dev mode (AUTH_DEV_MODE): the code is always AUTH_DEV_OTP and nothing is sent.
 * Otherwise a random code is generated. Real SMS delivery arrives in milestone
 * M6; until then the code is written to the server log outside production
 * (production refuses to start without a provider, see AppConfig).
 */
@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: AppConfig,
  ) {}

  async create(
    phone: string,
    options: { purpose?: OtpPurpose; passwordVerified?: boolean } = {},
  ): Promise<CreatedOtpChallenge> {
    const purpose = options.purpose ?? OtpPurpose.LOGIN;
    const { otpLength, otpTtlSeconds } = this.config.auth;
    const challengeId = randomUUID();
    const code = this.generateCode();
    const expiresAt = new Date(Date.now() + otpTtlSeconds * 1000);

    // Only the newest challenge per phone and purpose is valid. One
    // transaction, so a failed insert never leaves the phone without one.
    await this.prisma.$transaction([
      this.prisma.otpChallenge.deleteMany({
        where: { phone, purpose, consumedAt: null },
      }),
      this.prisma.otpChallenge.create({
        data: {
          id: challengeId,
          phone,
          purpose,
          codeHash: this.hashCode(challengeId, code),
          passwordVerified: options.passwordVerified ?? false,
          expiresAt,
        },
        select: { id: true },
      }),
    ]);

    this.deliver(challengeId, code);
    return { challengeId, otpLength, expiresAt };
  }

  /**
   * Checks the code and consumes the challenge. Throws OTP_CHALLENGE_INVALID,
   * OTP_EXPIRED or OTP_INVALID.
   *
   * Every try (right or wrong) first takes one attempt with a conditional
   * update, so parallel requests can never guess more than otpMaxAttempts
   * times. Reaching the maximum expires the challenge.
   */
  async verify(
    challengeId: string,
    phone: string,
    code: string,
    purpose: OtpPurpose = OtpPurpose.LOGIN,
  ): Promise<VerifiedOtpChallenge> {
    const challenge = await this.prisma.otpChallenge.findUnique({
      where: { id: challengeId },
      select: {
        phone: true,
        purpose: true,
        codeHash: true,
        passwordVerified: true,
        consumedAt: true,
      },
    });

    if (
      !challenge ||
      challenge.consumedAt ||
      challenge.phone !== phone ||
      challenge.purpose !== purpose
    ) {
      throw this.error(
        'Invalid OTP challenge',
        ERROR_CODES.OTP_CHALLENGE_INVALID,
      );
    }

    const maxAttempts = this.config.auth.otpMaxAttempts;
    const taken = await this.prisma.otpChallenge.updateManyAndReturn({
      where: {
        id: challengeId,
        consumedAt: null,
        attempts: { lt: maxAttempts },
        expiresAt: { gt: new Date() },
      },
      data: { attempts: { increment: 1 } },
      select: { attempts: true },
    });
    if (taken.length !== 1) {
      throw this.error(
        'OTP has expired. Please request a new one.',
        ERROR_CODES.OTP_EXPIRED,
      );
    }

    if (!this.matches(challengeId, code, challenge.codeHash)) {
      if (taken[0].attempts >= maxAttempts) {
        throw this.error(
          'Too many wrong attempts. Please request a new OTP.',
          ERROR_CODES.OTP_EXPIRED,
        );
      }
      throw this.error('Invalid OTP', ERROR_CODES.OTP_INVALID);
    }

    // Conditional update so two parallel requests cannot both consume it.
    const consumed = await this.prisma.otpChallenge.updateMany({
      where: { id: challengeId, consumedAt: null },
      data: { consumedAt: new Date() },
    });
    if (consumed.count !== 1) {
      throw this.error(
        'Invalid OTP challenge',
        ERROR_CODES.OTP_CHALLENGE_INVALID,
      );
    }

    return {
      challengeId,
      phone: challenge.phone,
      passwordVerified: challenge.passwordVerified,
    };
  }

  /**
   * Removes challenges that expired more than an hour ago. A consumed
   * challenge expires shortly after it was used, so it is covered as well.
   */
  async deleteStale(): Promise<number> {
    const result = await this.prisma.otpChallenge.deleteMany({
      where: { expiresAt: { lt: new Date(Date.now() - HOUR_MS) } },
    });
    return result.count;
  }

  private generateCode(): string {
    const { devMode, devOtp, otpLength } = this.config.auth;
    if (devMode) return devOtp;
    return randomInt(0, 10 ** otpLength)
      .toString()
      .padStart(otpLength, '0');
  }

  private deliver(challengeId: string, code: string): void {
    if (this.config.auth.devMode) return;
    // Placeholder until the SMS provider lands in M6. Production cannot reach
    // this line because AppConfig refuses to start without dev mode there.
    this.logger.warn({
      message: 'SMS provider not configured; OTP written to log',
      challengeId,
      otp: code,
    });
  }

  private hashCode(challengeId: string, code: string): string {
    return createHash('sha256').update(`${challengeId}:${code}`).digest('hex');
  }

  private matches(
    challengeId: string,
    code: string,
    storedHash: string,
  ): boolean {
    const actual = Buffer.from(this.hashCode(challengeId, code), 'hex');
    const expected = Buffer.from(storedHash, 'hex');
    return (
      actual.length === expected.length && timingSafeEqual(actual, expected)
    );
  }

  private error(message: string, errorCode: ErrorCode): ApiException {
    return new ApiException(message, HttpStatus.UNAUTHORIZED, errorCode);
  }
}

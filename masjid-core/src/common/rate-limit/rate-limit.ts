import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { AppConfig } from '../../config/app-config';

const MINUTE = 60_000;

/**
 * Per-IP request limits. Counters live in process memory, which is fine for
 * the single API container we run on the VPS. Use with @Throttle(...) on a
 * handler to tighten the default for that route.
 */
export const RATE_LIMITS = {
  /** Applies to every route unless overridden. */
  default: { limit: 120, ttl: MINUTE },
  /** login/start, login/password, login/verify-otp. */
  login: { default: { limit: 10, ttl: MINUTE } },
  /** Token refresh happens on app start and every access-token expiry. */
  refresh: { default: { limit: 30, ttl: MINUTE } },
  /** Changing a password requires the current one; slow down guessing. */
  passwordChange: { default: { limit: 5, ttl: 15 * MINUTE } },
  /** Public, unauthenticated masjid registration form. */
  publicSubmit: { default: { limit: 5, ttl: 10 * MINUTE } },
  /** Public application tracking by phone number. */
  publicLookup: { default: { limit: 10, ttl: MINUTE } },
} as const;

@Module({
  imports: [
    ThrottlerModule.forRootAsync({
      inject: [AppConfig],
      useFactory: (config: AppConfig) => ({
        throttlers: [{ name: 'default', ...RATE_LIMITS.default }],
        skipIf: () => !config.rateLimitEnabled,
        errorMessage: 'Too many requests. Please wait a moment and try again.',
      }),
    }),
  ],
  providers: [{ provide: APP_GUARD, useClass: ThrottlerGuard }],
})
export class RateLimitModule {}

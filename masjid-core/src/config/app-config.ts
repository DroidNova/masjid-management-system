import { z } from 'zod';

/**
 * Single source of truth for runtime configuration.
 *
 * Every environment variable the API reads is declared and validated here.
 * The app refuses to start when something is missing or unsafe, and the rest
 * of the code reads typed values from the injected AppConfig instead of
 * touching process.env.
 */

const optionalBoolean = z
  .enum(['true', 'false', '1', '0'])
  .optional()
  .transform((value) =>
    value === undefined ? undefined : value === 'true' || value === '1',
  );

const duration = z
  .string()
  .trim()
  .regex(/^\d+[smhd]$/i, 'must look like 30s, 15m, 12h or 30d');

const envSchema = z
  .object({
    NODE_ENV: z
      .enum(['development', 'test', 'staging', 'production'])
      .default('development'),
    PORT: z.coerce.number().int().min(1).max(65535).default(3000),
    LOG_LEVEL: z
      .enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent'])
      .optional(),
    PRISMA_LOG_QUERIES: optionalBoolean,
    TRUST_PROXY: optionalBoolean,
    CORS_ALLOWED_ORIGINS: z.string().optional(),
    SWAGGER_ENABLED: optionalBoolean,
    RATE_LIMIT_ENABLED: optionalBoolean,

    DATABASE_URL: z
      .string()
      .regex(/^postgres(ql)?:\/\//, 'must be a postgresql:// connection URL'),

    JWT_ACCESS_SECRET: z.string().min(16, 'must be at least 16 characters'),
    JWT_REFRESH_SECRET: z.string().min(16, 'must be at least 16 characters'),
    JWT_ACCESS_EXPIRES_IN: duration.default('15m'),
    JWT_REFRESH_EXPIRES_IN: duration.default('30d'),

    // Development auth. While the product is in development every OTP is
    // AUTH_DEV_OTP and new privileged users get AUTH_DEV_PASSWORD.
    AUTH_DEV_MODE: optionalBoolean,
    AUTH_DEV_OTP: z
      .string()
      .regex(/^\d{4,8}$/, 'must be 4 to 8 digits')
      .default('1111'),
    AUTH_DEV_PASSWORD: z
      .string()
      .min(8, 'must be at least 8 characters')
      .default('12345678'),
    AUTH_OTP_LENGTH: z.coerce.number().int().min(4).max(8).default(6),
    AUTH_OTP_TTL_SECONDS: z.coerce.number().int().min(60).default(300),
    AUTH_OTP_MAX_ATTEMPTS: z.coerce.number().int().min(1).max(20).default(5),
  })
  .superRefine((env, ctx) => {
    const isProduction = env.NODE_ENV === 'production';
    const isDeployed = isProduction || env.NODE_ENV === 'staging';

    if (env.JWT_ACCESS_SECRET === env.JWT_REFRESH_SECRET) {
      ctx.addIssue({
        code: 'custom',
        path: ['JWT_REFRESH_SECRET'],
        message: 'must be different from JWT_ACCESS_SECRET',
      });
    }

    if (isDeployed) {
      for (const key of ['JWT_ACCESS_SECRET', 'JWT_REFRESH_SECRET'] as const) {
        if (env[key].length < 32) {
          ctx.addIssue({
            code: 'custom',
            path: [key],
            message: `must be at least 32 characters when NODE_ENV=${env.NODE_ENV}`,
          });
        }
      }

      if (!parseOrigins(env.CORS_ALLOWED_ORIGINS).length) {
        ctx.addIssue({
          code: 'custom',
          path: ['CORS_ALLOWED_ORIGINS'],
          message: `is required when NODE_ENV=${env.NODE_ENV}`,
        });
      }
    }

    if (isProduction) {
      if (env.AUTH_DEV_MODE === true) {
        ctx.addIssue({
          code: 'custom',
          path: ['AUTH_DEV_MODE'],
          message:
            'must be false in production (fixed OTP and default passwords are for development only)',
        });
      } else {
        // Real OTP delivery (SMS provider) arrives in milestone M6 of
        // docs/IMPROVEMENT_PLAN.md. Until then nobody could log in, so refuse
        // to start instead of failing silently at login time.
        ctx.addIssue({
          code: 'custom',
          path: ['NODE_ENV'],
          message:
            'production needs a real SMS OTP provider, which is not implemented yet (milestone M6). Use NODE_ENV=staging with AUTH_DEV_MODE=true until then',
        });
      }
    }
  });

type ParsedEnv = z.infer<typeof envSchema>;
export type NodeEnv = ParsedEnv['NODE_ENV'];
export type TokenDuration = `${number}${'s' | 'm' | 'h' | 'd'}`;

function parseOrigins(value: string | undefined): string[] {
  return (value ?? '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
}

export function durationToSeconds(value: string): number {
  const match = /^(\d+)([smhd])$/i.exec(value.trim());
  if (!match) {
    throw new Error(`Invalid duration: ${value}`);
  }
  const amount = Number(match[1]);
  const unit = match[2].toLowerCase();
  const multiplier =
    unit === 's' ? 1 : unit === 'm' ? 60 : unit === 'h' ? 3600 : 86400;
  return amount * multiplier;
}

export class AppConfig {
  readonly nodeEnv: NodeEnv;
  readonly isProduction: boolean;
  readonly isTest: boolean;
  readonly port: number;
  readonly logLevel: string;
  readonly prismaLogQueries: boolean;
  readonly trustProxy: boolean;
  readonly swaggerEnabled: boolean;
  readonly rateLimitEnabled: boolean;
  /** Empty list means "allow any origin" and is only possible outside staging/production. */
  readonly corsAllowedOrigins: string[];
  readonly databaseUrl: string;

  readonly jwt: {
    readonly accessSecret: string;
    readonly refreshSecret: string;
    readonly accessExpiresIn: TokenDuration;
    readonly refreshExpiresIn: TokenDuration;
    readonly accessExpiresInSeconds: number;
    readonly refreshExpiresInSeconds: number;
  };

  readonly auth: {
    /** Fixed OTP and fixed initial password. Never true in production. */
    readonly devMode: boolean;
    readonly devOtp: string;
    readonly devPassword: string;
    /** Digits the client must collect. Equals devOtp.length in dev mode. */
    readonly otpLength: number;
    readonly otpTtlSeconds: number;
    readonly otpMaxAttempts: number;
  };

  constructor(env: ParsedEnv) {
    this.nodeEnv = env.NODE_ENV;
    this.isProduction = env.NODE_ENV === 'production';
    this.isTest = env.NODE_ENV === 'test';
    this.port = env.PORT;
    this.logLevel = env.LOG_LEVEL ?? (this.isProduction ? 'info' : 'debug');
    this.prismaLogQueries =
      !this.isProduction && (env.PRISMA_LOG_QUERIES ?? false);
    this.trustProxy = env.TRUST_PROXY ?? false;
    this.swaggerEnabled = env.SWAGGER_ENABLED ?? !this.isProduction;
    this.rateLimitEnabled = env.RATE_LIMIT_ENABLED ?? true;
    this.corsAllowedOrigins = parseOrigins(env.CORS_ALLOWED_ORIGINS);
    this.databaseUrl = env.DATABASE_URL;

    this.jwt = {
      accessSecret: env.JWT_ACCESS_SECRET,
      refreshSecret: env.JWT_REFRESH_SECRET,
      accessExpiresIn: env.JWT_ACCESS_EXPIRES_IN as TokenDuration,
      refreshExpiresIn: env.JWT_REFRESH_EXPIRES_IN as TokenDuration,
      accessExpiresInSeconds: durationToSeconds(env.JWT_ACCESS_EXPIRES_IN),
      refreshExpiresInSeconds: durationToSeconds(env.JWT_REFRESH_EXPIRES_IN),
    };

    const devMode = env.AUTH_DEV_MODE ?? !this.isProduction;
    this.auth = {
      devMode,
      devOtp: env.AUTH_DEV_OTP,
      devPassword: env.AUTH_DEV_PASSWORD,
      otpLength: devMode ? env.AUTH_DEV_OTP.length : env.AUTH_OTP_LENGTH,
      otpTtlSeconds: env.AUTH_OTP_TTL_SECONDS,
      otpMaxAttempts: env.AUTH_OTP_MAX_ATTEMPTS,
    };
  }

  /** Validates the environment. Throws one readable error listing every problem. */
  static fromEnv(
    raw: Record<string, string | undefined> = process.env,
  ): AppConfig {
    // Treat empty strings like missing values so `KEY=` in a .env file falls back to defaults.
    const cleaned = Object.fromEntries(
      Object.entries(raw).filter(([, value]) => value !== ''),
    );
    const result = envSchema.safeParse(cleaned);
    if (!result.success) {
      const lines = result.error.issues.map(
        (issue) => `  - ${issue.path.join('.') || '(root)'}: ${issue.message}`,
      );
      throw new Error(
        `Invalid environment configuration:\n${lines.join('\n')}\nSee masjid-core/.env.example.`,
      );
    }
    return new AppConfig(result.data);
  }

  private static cached: AppConfig | undefined;

  /** Process-wide instance used by the Nest module and bootstrap. */
  static load(): AppConfig {
    AppConfig.cached ??= AppConfig.fromEnv();
    return AppConfig.cached;
  }
}

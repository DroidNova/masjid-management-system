import { AppConfig } from './app-config';

const base = {
  DATABASE_URL: 'postgresql://user:pass@localhost:5432/db',
  JWT_ACCESS_SECRET: 'a'.repeat(32),
  JWT_REFRESH_SECRET: 'b'.repeat(32),
};

describe('AppConfig', () => {
  it('uses development defaults: dev auth with OTP 1111 and password 12345678', () => {
    const config = AppConfig.fromEnv({ ...base });

    expect(config.nodeEnv).toBe('development');
    expect(config.auth.devMode).toBe(true);
    expect(config.auth.devOtp).toBe('1111');
    expect(config.auth.devPassword).toBe('12345678');
    expect(config.auth.otpLength).toBe(4);
    expect(config.swaggerEnabled).toBe(true);
    expect(config.rateLimitEnabled).toBe(true);
    expect(config.jwt.accessExpiresInSeconds).toBe(900);
    expect(config.jwt.refreshExpiresInSeconds).toBe(30 * 86400);
  });

  it('uses AUTH_OTP_LENGTH when dev mode is off', () => {
    const config = AppConfig.fromEnv({
      ...base,
      AUTH_DEV_MODE: 'false',
      AUTH_OTP_LENGTH: '6',
    });
    expect(config.auth.devMode).toBe(false);
    expect(config.auth.otpLength).toBe(6);
  });

  it('treats empty values as unset', () => {
    const config = AppConfig.fromEnv({ ...base, AUTH_DEV_OTP: '', PORT: '' });
    expect(config.auth.devOtp).toBe('1111');
    expect(config.port).toBe(3000);
  });

  it('rejects missing required values with a readable message', () => {
    expect(() => AppConfig.fromEnv({})).toThrow(/DATABASE_URL/);
    expect(() => AppConfig.fromEnv({})).toThrow(/JWT_ACCESS_SECRET/);
  });

  it('rejects identical access and refresh secrets', () => {
    expect(() =>
      AppConfig.fromEnv({
        ...base,
        JWT_REFRESH_SECRET: base.JWT_ACCESS_SECRET,
      }),
    ).toThrow(/must be different/);
  });

  it('rejects a malformed OTP or duration', () => {
    expect(() => AppConfig.fromEnv({ ...base, AUTH_DEV_OTP: '12a4' })).toThrow(
      /AUTH_DEV_OTP/,
    );
    expect(() =>
      AppConfig.fromEnv({ ...base, JWT_ACCESS_EXPIRES_IN: '15 minutes' }),
    ).toThrow(/JWT_ACCESS_EXPIRES_IN/);
  });

  describe('staging', () => {
    const staging = {
      ...base,
      NODE_ENV: 'staging',
      CORS_ALLOWED_ORIGINS: 'https://app.example.com',
    };

    it('allows dev auth so testers can log in before SMS exists', () => {
      const config = AppConfig.fromEnv(staging);
      expect(config.auth.devMode).toBe(true);
      expect(config.corsAllowedOrigins).toEqual(['https://app.example.com']);
    });

    it('requires 32-character secrets', () => {
      expect(() =>
        AppConfig.fromEnv({ ...staging, JWT_ACCESS_SECRET: 'x'.repeat(20) }),
      ).toThrow(/at least 32 characters/);
    });

    it('requires CORS origins', () => {
      expect(() =>
        AppConfig.fromEnv({ ...staging, CORS_ALLOWED_ORIGINS: undefined }),
      ).toThrow(/CORS_ALLOWED_ORIGINS/);
    });
  });

  describe('production', () => {
    const production = {
      ...base,
      NODE_ENV: 'production',
      CORS_ALLOWED_ORIGINS: 'https://app.example.com',
    };

    it('refuses dev auth', () => {
      expect(() =>
        AppConfig.fromEnv({ ...production, AUTH_DEV_MODE: 'true' }),
      ).toThrow(/AUTH_DEV_MODE: must be false in production/);
    });

    it('refuses to start until real SMS OTP exists (M6)', () => {
      expect(() => AppConfig.fromEnv(production)).toThrow(/milestone M6/);
    });
  });
});

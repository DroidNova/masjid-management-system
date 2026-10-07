import { Global, INestApplication, Module } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppConfig } from '../../config/app-config';
import { AuthController } from '../../modules/platform-core/auth/auth.controller';
import { AuthService } from '../../modules/platform-core/auth/auth.service';
import { RATE_LIMITS, RateLimitModule } from './rate-limit';

function configModule(rateLimitEnabled: boolean) {
  const config = AppConfig.fromEnv({
    NODE_ENV: 'test',
    DATABASE_URL: 'postgresql://test:test@localhost:5432/test',
    JWT_ACCESS_SECRET: 'access-secret-for-tests-0123456789',
    JWT_REFRESH_SECRET: 'refresh-secret-for-tests-0123456789',
    RATE_LIMIT_ENABLED: String(rateLimitEnabled),
  });

  @Global()
  @Module({
    providers: [{ provide: AppConfig, useValue: config }],
    exports: [AppConfig],
  })
  class TestConfigModule {}
  return TestConfigModule;
}

async function createApp(
  rateLimitEnabled = true,
): Promise<INestApplication<App>> {
  const moduleRef = await Test.createTestingModule({
    imports: [configModule(rateLimitEnabled), RateLimitModule],
    controllers: [AuthController],
    providers: [
      {
        provide: AuthService,
        useValue: {
          startLogin: jest.fn().mockResolvedValue({ nextStep: 'OTP_REQUIRED' }),
        },
      },
    ],
  }).compile();

  const app = moduleRef.createNestApplication<INestApplication<App>>();
  await app.init();
  return app;
}

describe('Rate limiting', () => {
  const loginLimit = RATE_LIMITS.login.default.limit;
  let app: INestApplication<App>;

  afterEach(async () => {
    await app?.close();
  });

  it(`blocks the login endpoint after ${loginLimit} requests per minute`, async () => {
    app = await createApp();
    const server = app.getHttpServer();

    for (let i = 0; i < loginLimit; i++) {
      await request(server)
        .post('/auth/login/start')
        .send({ phone: '9876500001' })
        .expect(200);
    }
    await request(server)
      .post('/auth/login/start')
      .send({ phone: '9876500001' })
      .expect(429);
  });

  it('can be switched off with RATE_LIMIT_ENABLED=false', async () => {
    app = await createApp(false);
    const server = app.getHttpServer();

    for (let i = 0; i < loginLimit + 2; i++) {
      await request(server)
        .post('/auth/login/start')
        .send({ phone: '9876500001' })
        .expect(200);
    }
  });
});

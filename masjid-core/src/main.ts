// Load .env before anything reads the environment.
import 'dotenv/config';
import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from 'helmet';
import { Logger } from 'nestjs-pino';
import { AppModule } from './app.module';
import { AppConfig } from './config/app-config';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { ApiException } from './common/exceptions/api.exception';
import { ERROR_CODES } from './common/constants/error-codes.constant';
import { SuccessResponseInterceptor } from './common/interceptors/success-response.interceptor';

async function bootstrap() {
  // Validate configuration before Nest starts so a bad .env fails with one
  // readable message instead of a stack trace from deep inside a module.
  let config: AppConfig;
  try {
    config = AppConfig.load();
  } catch (error) {
    console.error((error as Error).message);
    process.exit(1);
  }

  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    bufferLogs: true,
  });
  const logger = app.get(Logger);
  app.useLogger(logger);

  if (config.trustProxy) {
    // Behind Caddy/nginx: use X-Forwarded-For so rate limits see the real client IP.
    app.set('trust proxy', 1);
  }

  app.use(
    helmet({
      // Swagger UI needs inline scripts and styles; the JSON API does not use CSP.
      contentSecurityPolicy: config.swaggerEnabled ? false : undefined,
    }),
  );

  app.setGlobalPrefix('api/v1');

  app.enableCors({
    // Empty list is only possible outside staging/production (enforced in AppConfig).
    origin: config.corsAllowedOrigins.length ? config.corsAllowedOrigins : true,
    // The app authenticates with a bearer header, never with cookies.
    credentials: false,
    methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'x-request-id'],
    exposedHeaders: ['x-request-id'],
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
      exceptionFactory: (validationErrors) => {
        const errors = Object.fromEntries(
          validationErrors.map((error) => [
            error.property,
            Object.values(error.constraints ?? {}),
          ]),
        );

        return new ApiException(
          'Validation failed',
          400,
          ERROR_CODES.VALIDATION_ERROR,
          errors,
        );
      },
    }),
  );

  app.useGlobalFilters(app.get(HttpExceptionFilter));
  app.useGlobalInterceptors(new SuccessResponseInterceptor());

  if (config.swaggerEnabled) {
    const swaggerConfig = new DocumentBuilder()
      .setTitle('Masjid Core API')
      .setDescription('Backend for the masjid management system')
      .setVersion('1.0')
      .addBearerAuth(
        {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Input JWT access token',
        },
        'bearer',
      )
      .build();

    const document = SwaggerModule.createDocument(app, swaggerConfig);
    SwaggerModule.setup('api', app, document);
  }

  app.enableShutdownHooks();
  await app.listen(config.port);

  logger.log(
    `API listening on port ${config.port} (NODE_ENV=${config.nodeEnv}, swagger=${config.swaggerEnabled}, rateLimit=${config.rateLimitEnabled})`,
  );
  if (config.auth.devMode) {
    logger.warn(
      `AUTH_DEV_MODE is on: every OTP is ${config.auth.devOtp} and new privileged users get password ${config.auth.devPassword}`,
    );
  }
}
void bootstrap();

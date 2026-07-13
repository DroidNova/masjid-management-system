import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { Logger } from 'nestjs-pino';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import 'dotenv/config';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { ApiException } from './common/exceptions/api.exception';
import { ERROR_CODES } from './common/constants/error-codes.constant';
import { SuccessResponseInterceptor } from './common/interceptors/success-response.interceptor';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { bufferLogs: true });
  app.useLogger(app.get(Logger));

  app.setGlobalPrefix('api/v1');

  app.enableCors({
    origin: true,
    credentials: true,
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

  const swaggerConfig = new DocumentBuilder()
    .setTitle('Platform Core API')
    .setDescription('Reusable backend core for future domain products')
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
  SwaggerModule.setup('docs', app, document);

  app.enableShutdownHooks();
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();

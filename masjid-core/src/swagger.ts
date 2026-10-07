import { INestApplication } from '@nestjs/common';
import { DocumentBuilder, OpenAPIObject, SwaggerModule } from '@nestjs/swagger';

/** Builds the OpenAPI document. Used by main.ts (Swagger UI) and scripts/export-openapi.ts. */
export function buildOpenApiDocument(app: INestApplication): OpenAPIObject {
  const config = new DocumentBuilder()
    .setTitle('Masjid Core API')
    .setDescription(
      'Backend for the masjid management system. Every masjid route needs a permission; see src/access/permissions.ts.',
    )
    .setVersion('1.0')
    .addServer('/api/v1')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'Access token from /auth/login/verify-otp',
      },
      'bearer',
    )
    .build();

  return SwaggerModule.createDocument(app, config, {
    // Paths in the document are relative to the /api/v1 server above.
    ignoreGlobalPrefix: true,
  });
}

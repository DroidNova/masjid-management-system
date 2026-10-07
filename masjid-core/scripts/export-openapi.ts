import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import * as fs from 'node:fs';
import * as path from 'node:path';
import { AppModule } from '../src/app.module';
import { buildOpenApiDocument } from '../src/swagger';

/**
 * Writes the API contract to docs/openapi.json without starting the server
 * or connecting to the database (lifecycle hooks only run on app.init()).
 *
 *   npm run openapi
 */
async function main(): Promise<void> {
  const app = await NestFactory.create(AppModule, { logger: false });
  const document = buildOpenApiDocument(app);
  // npm scripts run from masjid-core/, so the repo's docs folder is one level up.
  const out = path.resolve(process.cwd(), '..', 'docs', 'openapi.json');
  fs.writeFileSync(out, `${JSON.stringify(document, null, 2)}\n`);
  console.log(
    `Wrote ${Object.keys(document.paths).length} paths to ${path.relative(process.cwd(), out)}`,
  );
  await app.close();
}

void main().catch((error) => {
  console.error(error);
  process.exit(1);
});

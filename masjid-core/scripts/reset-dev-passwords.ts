import 'dotenv/config';
import { Logger } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../src/generated/prisma/client';
import { AppConfig } from '../src/config/app-config';

/**
 * Development helper: sets the password of every imam, committee member and
 * masjid admin to AUTH_DEV_PASSWORD (default 12345678) and signs them out.
 * Super admins are left alone. Refuses to run unless AUTH_DEV_MODE is on.
 *
 *   npm run dev:reset-passwords          (from source)
 *   npm run dev:reset-passwords:prod     (inside the Docker image)
 */

const logger = new Logger('ResetDevPasswords');
const ROLES = ['IMAM', 'COMMITTEE_MEMBER', 'MASJID_ADMIN'] as const;

async function main(): Promise<void> {
  const config = AppConfig.fromEnv();
  if (!config.auth.devMode) {
    throw new Error('AUTH_DEV_MODE is off; refusing to reset passwords.');
  }

  const prisma = new PrismaClient({
    adapter: new PrismaPg({ connectionString: config.databaseUrl }),
  });

  try {
    const users = await prisma.user.findMany({
      where: {
        userRoles: { some: { role: { name: { in: [...ROLES] } } } },
        NOT: { userRoles: { some: { role: { name: 'SUPER_ADMIN' } } } },
      },
      select: { id: true },
    });
    const ids = users.map((user) => user.id);

    const passwordHash = await bcrypt.hash(config.auth.devPassword, 10);
    const [updated] = await prisma.$transaction([
      prisma.user.updateMany({
        where: { id: { in: ids } },
        data: { passwordHash },
      }),
      prisma.session.deleteMany({ where: { userId: { in: ids } } }),
    ]);

    logger.log(
      `Reset ${updated.count} imam/committee/admin password(s) to AUTH_DEV_PASSWORD.`,
    );
  } finally {
    await prisma.$disconnect();
  }
}

void main().catch((error) => {
  logger.error(
    'Password reset failed',
    error instanceof Error ? error.message : String(error),
  );
  process.exit(1);
});

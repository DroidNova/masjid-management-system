import 'dotenv/config';
import { Logger } from '@nestjs/common';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../src/generated/prisma/client';
import {
  ALL_PERMISSIONS,
  ROLE_NAMES,
  ROLE_PERMISSIONS,
} from '../src/access/permissions';

/**
 * Creates the roles and copies the permission matrix from
 * src/access/permissions.ts into the Permission and RolePermission tables.
 *
 * The API reads permissions from that file directly, so these tables are a
 * reference copy (useful for reports and admin screens). Re-run after editing
 * the matrix to keep them in sync. Safe to run repeatedly.
 */

const logger = new Logger('PrismaSeed');

function createPrismaClient(): PrismaClient {
  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    throw new Error('DATABASE_URL is required to run seeds');
  }
  return new PrismaClient({
    adapter: new PrismaPg({ connectionString: databaseUrl }),
  });
}

async function main(): Promise<void> {
  const prisma = createPrismaClient();

  try {
    for (const name of ROLE_NAMES) {
      await prisma.role.upsert({
        where: { name },
        update: {},
        create: { name },
      });
    }

    for (const name of ALL_PERMISSIONS) {
      await prisma.permission.upsert({
        where: { name },
        update: {},
        create: { name },
      });
    }
    // Permissions no longer in the catalogue (cascades to RolePermission).
    const removed = await prisma.permission.deleteMany({
      where: { name: { notIn: [...ALL_PERMISSIONS] } },
    });

    const roles = await prisma.role.findMany({
      select: { id: true, name: true },
    });
    const permissions = await prisma.permission.findMany({
      select: { id: true, name: true },
    });
    const permissionId = new Map(permissions.map((p) => [p.name, p.id]));

    for (const role of roles) {
      const wanted = (ROLE_PERMISSIONS[role.name] ?? []).map(
        (name) => permissionId.get(name)!,
      );
      await prisma.$transaction([
        prisma.rolePermission.deleteMany({
          where: { roleId: role.id, permissionId: { notIn: wanted } },
        }),
        prisma.rolePermission.createMany({
          data: wanted.map((id) => ({ roleId: role.id, permissionId: id })),
          skipDuplicates: true,
        }),
      ]);
      logger.log(`${role.name}: ${wanted.length} permission(s)`);
    }

    logger.log(
      `Seed complete. ${ALL_PERMISSIONS.length} permissions, ${removed.count} stale permission(s) removed.`,
    );
  } finally {
    await prisma.$disconnect();
  }
}

void main().catch((error) => {
  logger.error(
    'Role/permission seed failed',
    error instanceof Error ? error.stack : String(error),
  );
  process.exit(1);
});

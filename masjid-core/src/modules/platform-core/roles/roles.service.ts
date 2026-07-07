import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';

const ROLE_NAMES = [
  'SUPER_ADMIN',
  'MASJID_ADMIN',
  'IMAM',
  'COMMITTEE_MEMBER',
  'MEMBER',
] as const;

type RoleName = (typeof ROLE_NAMES)[number];

@Injectable()
export class RolesService {
  constructor(private readonly prisma: PrismaService) {}

  getStatus() {
    return {
      success: true,
      message: 'Roles module is ready',
    };
  }

  async validateRoleNames(
    roleNames: string[],
  ): Promise<Array<{ id: string; name: string }>> {
    const uniqueNames = Array.from(new Set(roleNames));
    const allowedRoleNames = new Set(ROLE_NAMES);
    const uniqueRoleNames = uniqueNames.filter((name): name is RoleName =>
      allowedRoleNames.has(name as RoleName),
    );

    if (uniqueRoleNames.length !== uniqueNames.length) {
      const missing = uniqueNames.filter(
        (name) => !allowedRoleNames.has(name as RoleName),
      );
      throw new NotFoundException(`Roles not found: ${missing.join(', ')}`);
    }

    const roles = await this.prisma.role.findMany({
      where: {
        name: {
          in: uniqueRoleNames,
        },
      },
      select: {
        id: true,
        name: true,
      },
    });

    if (roles.length !== uniqueRoleNames.length) {
      const foundNames = new Set(
        roles.map((role: { name: string }) => role.name),
      );
      const missing = uniqueRoleNames.filter((name) => !foundNames.has(name));
      throw new NotFoundException(`Roles not found: ${missing.join(', ')}`);
    }

    return roles;
  }
}

import { HttpStatus, Injectable } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { ROLE_NAMES, RoleName } from '../../../access/permissions';
import { ApiException } from '../../../common/exceptions/api.exception';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';

export type RoleRef = { id: string; name: RoleName };

/**
 * Looks up the seeded Role rows. Roles are created by the seed and never
 * change at runtime, so their ids are read once and kept in memory.
 */
@Injectable()
export class RolesService {
  private roleIds: Promise<Map<string, string>> | null = null;

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Returns id and name for each distinct role name. Throws ROLE_NOT_FOUND
   * (404) for names that are not roles or are missing from the database.
   */
  async validateRoleNames(roleNames: string[]): Promise<RoleRef[]> {
    const uniqueNames = Array.from(new Set(roleNames));
    const allowed = new Set<string>(ROLE_NAMES);
    const unknown = uniqueNames.filter((name) => !allowed.has(name));
    if (unknown.length) throw this.notFound(unknown);

    let ids = await this.loadRoleIds();
    if (uniqueNames.some((name) => !ids.has(name))) {
      // The seed may have run after the first lookup; read once more.
      this.roleIds = null;
      ids = await this.loadRoleIds();
    }

    const missing = uniqueNames.filter((name) => !ids.has(name));
    if (missing.length) throw this.notFound(missing);

    return uniqueNames.map((name) => ({
      id: ids.get(name)!,
      name: name as RoleName,
    }));
  }

  /** Id of one seeded role (ROLE_NOT_FOUND if the seed has not run). */
  async getRoleId(name: RoleName): Promise<string> {
    const [role] = await this.validateRoleNames([name]);
    return role.id;
  }

  private loadRoleIds(): Promise<Map<string, string>> {
    if (!this.roleIds) {
      const loading = this.prisma.role
        .findMany({ select: { id: true, name: true } })
        .then((roles) => new Map(roles.map((role) => [role.name, role.id])));
      // A failed read is not cached, so the next call tries again.
      loading.catch(() => {
        if (this.roleIds === loading) this.roleIds = null;
      });
      this.roleIds = loading;
    }
    return this.roleIds;
  }

  private notFound(names: string[]): ApiException {
    return new ApiException(
      `Roles not found: ${names.join(', ')}`,
      HttpStatus.NOT_FOUND,
      ERROR_CODES.ROLE_NOT_FOUND,
    );
  }
}

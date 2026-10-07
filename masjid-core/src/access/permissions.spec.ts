import 'reflect-metadata';
import { ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import * as fs from 'node:fs';
import * as path from 'node:path';
import {
  ALL_PERMISSIONS,
  hasPermission,
  PERMISSIONS as P,
  Permission,
  permissionsForRoles,
  FIELD_LEVEL_PERMISSIONS,
  ROLE_PERMISSIONS,
} from './permissions';
import {
  PERMISSIONS_METADATA_KEY,
  PermissionsGuard,
} from './require-permissions';

const can = (role: string, permission: Permission) =>
  hasPermission({ roles: [role] }, permission);

describe('Role matrix (product rule)', () => {
  it('gives SUPER_ADMIN every permission', () => {
    expect(permissionsForRoles(['SUPER_ADMIN'])).toEqual([...ALL_PERMISSIONS]);
  });

  it('gives MASJID_ADMIN nothing, so no single villager controls a masjid', () => {
    expect(permissionsForRoles(['MASJID_ADMIN'])).toEqual([]);
  });

  it('lets the imam update namaz times and announcements only', () => {
    expect(can('IMAM', P.NAMAZ_TIMES_UPDATE)).toBe(true);
    expect(can('IMAM', P.ANNOUNCEMENTS_MANAGE)).toBe(true);

    for (const forbidden of [
      P.MASJID_UPDATE,
      P.MEMBERS_MANAGE,
      P.COLLECTIONS_MANAGE,
      P.EXPENSES_MANAGE,
      P.PROJECTS_MANAGE,
      P.CONTRIBUTIONS_RECORD,
      P.IMAM_SALARY_MANAGE,
    ]) {
      expect(can('IMAM', forbidden)).toBe(false);
    }
  });

  it('lets the committee run money, projects, members and the salary ledger', () => {
    for (const allowed of [
      P.MASJID_UPDATE,
      P.MEMBERS_MANAGE,
      P.COLLECTIONS_MANAGE,
      P.EXPENSES_MANAGE,
      P.PROJECTS_MANAGE,
      P.CONTRIBUTIONS_RECORD,
      P.IMAM_SALARY_MANAGE,
      P.NAMAZ_TIMES_UPDATE,
      P.ANNOUNCEMENTS_MANAGE,
    ]) {
      expect(can('COMMITTEE_MEMBER', allowed)).toBe(true);
    }
  });

  it('gives masjid roles no platform administration', () => {
    const platform = ALL_PERMISSIONS.filter((p) => p.startsWith('platform.'));
    for (const role of ['IMAM', 'COMMITTEE_MEMBER', 'MEMBER', 'MASJID_ADMIN']) {
      for (const permission of platform) {
        expect(can(role, permission)).toBe(false);
      }
    }
  });

  it('gives members read access only (plus leaving their masjid)', () => {
    const memberPermissions = permissionsForRoles(['MEMBER']);
    expect(
      memberPermissions.every(
        (p) => p.endsWith('.read') || p === P.MASJID_LEAVE,
      ),
    ).toBe(true);
    expect(memberPermissions).toContain(P.OWN_CONTRIBUTIONS_READ);
  });

  it('shows member phone numbers to imam and committee, not to members', () => {
    expect(can('IMAM', P.MEMBERS_CONTACT_READ)).toBe(true);
    expect(can('COMMITTEE_MEMBER', P.MEMBERS_CONTACT_READ)).toBe(true);
    expect(can('MEMBER', P.MEMBERS_CONTACT_READ)).toBe(false);
  });

  it('merges permissions of several roles and ignores unknown roles', () => {
    const merged = permissionsForRoles(['MEMBER', 'IMAM', 'NOT_A_ROLE']);
    expect(merged).toEqual(permissionsForRoles(['IMAM']));
  });

  it('only references permissions that exist in the catalogue', () => {
    for (const permissions of Object.values(ROLE_PERMISSIONS)) {
      for (const permission of permissions) {
        expect(ALL_PERMISSIONS).toContain(permission);
      }
    }
  });
});

/* ------------------------------------------------------------------ */

// Every controller under src/ (modules and shared ones like the audit log).
const MODULES_DIR = path.join(__dirname, '..');

/** Routes that are intentionally open or only need a signed-in user. */
const ROUTES_WITHOUT_PERMISSION = new Set([
  'AuthController.startLogin',
  'AuthController.verifyPassword',
  'AuthController.verifyOtp',
  'AuthController.refresh',
  'AuthController.logout',
  'AuthController.logoutAll',
  'AuthController.changePassword',
  'AuthController.me',
  'HealthController.getHealth',
  'MasjidRequestsController.create',
  'MasjidRequestsController.track',
]);

function findControllerFiles(dir: string): string[] {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) return findControllerFiles(full);
    return entry.name.endsWith('.controller.ts') ? [full] : [];
  });
}

type Route = { name: string; permissions: Permission[] | undefined };

function collectRoutes(): Route[] {
  const routes: Route[] = [];
  for (const file of findControllerFiles(MODULES_DIR)) {
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const exported = require(file) as Record<string, unknown>;
    for (const value of Object.values(exported)) {
      if (typeof value !== 'function') continue;
      const controller = value as { name: string; prototype: object };
      if (!Reflect.hasMetadata('path', controller)) continue;
      for (const key of Object.getOwnPropertyNames(controller.prototype)) {
        const handler = (controller.prototype as Record<string, unknown>)[key];
        if (typeof handler !== 'function' || key === 'constructor') continue;
        if (!Reflect.hasMetadata('path', handler)) continue;
        routes.push({
          name: `${controller.name}.${key}`,
          permissions: Reflect.getMetadata(
            PERMISSIONS_METADATA_KEY,
            handler,
          ) as Permission[] | undefined,
        });
      }
    }
  }
  return routes;
}

describe('Route coverage', () => {
  const routes = collectRoutes();

  it('finds the controllers', () => {
    expect(routes.length).toBeGreaterThan(50);
  });

  it('protects every route with a permission unless it is listed as open', () => {
    const unprotected = routes
      .filter((route) => !route.permissions?.length)
      .map((route) => route.name)
      .filter((name) => !ROUTES_WITHOUT_PERMISSION.has(name));
    expect(unprotected).toEqual([]);
  });

  it('uses every catalogue permission on at least one route', () => {
    const used = new Set(routes.flatMap((route) => route.permissions ?? []));
    expect(
      ALL_PERMISSIONS.filter(
        (p) => !used.has(p) && !FIELD_LEVEL_PERMISSIONS.includes(p),
      ),
    ).toEqual([]);
  });
});

/* ------------------------------------------------------------------ */

describe('PermissionsGuard', () => {
  const guard = new PermissionsGuard(new Reflector());

  function contextFor(
    required: Permission[] | undefined,
    user: { permissions: string[] } | undefined,
  ): ExecutionContext {
    const handler = () => undefined;
    if (required)
      Reflect.defineMetadata(PERMISSIONS_METADATA_KEY, required, handler);
    return {
      getHandler: () => handler,
      getClass: () => class {},
      switchToHttp: () => ({ getRequest: () => ({ user }) }),
    } as unknown as ExecutionContext;
  }

  it('allows a user holding the permission', () => {
    expect(
      guard.canActivate(
        contextFor([P.EXPENSES_MANAGE], { permissions: [P.EXPENSES_MANAGE] }),
      ),
    ).toBe(true);
  });

  it('rejects with 403 and names the missing permission', () => {
    expect(() =>
      guard.canActivate(
        contextFor([P.EXPENSES_MANAGE], {
          permissions: permissionsForRoles(['IMAM']),
        }),
      ),
    ).toThrow(
      expect.objectContaining({
        response: expect.objectContaining({
          errorCode: 'FORBIDDEN',
          errors: { missingPermissions: [P.EXPENSES_MANAGE] },
        }),
      }),
    );
  });

  it('rejects with 401 when there is no signed-in user', () => {
    expect(() =>
      guard.canActivate(contextFor([P.FINANCE_READ], undefined)),
    ).toThrow(expect.objectContaining({ status: 401 }));
  });

  it('allows routes that require nothing', () => {
    expect(guard.canActivate(contextFor(undefined, undefined))).toBe(true);
  });
});

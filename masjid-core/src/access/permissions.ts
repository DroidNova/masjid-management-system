/**
 * WHO CAN DO WHAT
 * ===============
 * This file is the single source of truth for access control.
 *
 * To change what a role may do, edit ROLE_PERMISSIONS below and restart the
 * API. Nothing else is needed: login and /auth/me return the resulting
 * permission list, the API guards check it, and the app shows or hides
 * features from it. (`npm run prisma:seed` copies the matrix into the
 * Permission/RolePermission tables for reference only.)
 *
 * Product rule (docs/IMPROVEMENT_PLAN.md, section 1):
 *  - SUPER_ADMIN can do everything, on every masjid.
 *  - IMAM updates namaz times and announcements, and can view the records
 *    that concern him (his salary ledger, contributions).
 *  - COMMITTEE_MEMBER runs everything else for their masjid.
 *  - MEMBER keeps read access to the masjid and their own contributions.
 *  - MASJID_ADMIN exists in the database but is intentionally given nothing,
 *    so no single villager can control a masjid.
 */

export const PERMISSIONS = {
  // Masjid home
  DASHBOARD_READ: 'dashboard.read',
  MASJID_READ: 'masjid.read',
  /** Edit the masjid profile (welcome message). */
  MASJID_UPDATE: 'masjid.update',

  // Prayer times and notices
  NAMAZ_TIMES_READ: 'namaz_times.read',
  NAMAZ_TIMES_UPDATE: 'namaz_times.update',
  ANNOUNCEMENTS_READ: 'announcements.read',
  ANNOUNCEMENTS_MANAGE: 'announcements.manage',

  // People of the masjid
  MEMBERS_READ: 'members.read',
  /** Add villagers (MEMBER role), edit them, activate/deactivate them. */
  MEMBERS_MANAGE: 'members.manage',

  // Money
  FINANCE_READ: 'finance.read',
  COLLECTIONS_MANAGE: 'collections.manage',
  EXPENSES_MANAGE: 'expenses.manage',
  PROJECTS_READ: 'projects.read',
  PROJECTS_MANAGE: 'projects.manage',
  /** See who contributed to a project or collection. */
  CONTRIBUTIONS_READ: 'contributions.read',
  /** Record a contribution received from someone. */
  CONTRIBUTIONS_RECORD: 'contributions.record',
  /** A user's own contribution and imam-salary payment history. */
  OWN_CONTRIBUTIONS_READ: 'own_contributions.read',

  // Imam salary ledger
  IMAM_SALARY_READ: 'imam_salary.read',
  /** Create months, set the amount per family, record payments, see the ledger. */
  IMAM_SALARY_MANAGE: 'imam_salary.manage',

  // Platform administration (super admin)
  PLATFORM_USERS_READ: 'platform.users.read',
  PLATFORM_USERS_MANAGE: 'platform.users.manage',
  PLATFORM_ROLES_ASSIGN: 'platform.roles.assign',
  PLATFORM_MASJIDS_MANAGE: 'platform.masjids.manage',
  PLATFORM_MASJID_REQUESTS_MANAGE: 'platform.masjid_requests.manage',
} as const;

export type Permission = (typeof PERMISSIONS)[keyof typeof PERMISSIONS];

export const ALL_PERMISSIONS: readonly Permission[] =
  Object.values(PERMISSIONS);

export const ROLE_NAMES = [
  'SUPER_ADMIN',
  'MASJID_ADMIN',
  'IMAM',
  'COMMITTEE_MEMBER',
  'MEMBER',
] as const;

export type RoleName = (typeof ROLE_NAMES)[number];

const P = PERMISSIONS;

/** What every signed-in person of a masjid can see. */
const EVERYONE: Permission[] = [
  P.DASHBOARD_READ,
  P.MASJID_READ,
  P.NAMAZ_TIMES_READ,
  P.ANNOUNCEMENTS_READ,
  P.MEMBERS_READ,
  P.FINANCE_READ,
  P.PROJECTS_READ,
  P.OWN_CONTRIBUTIONS_READ,
];

export const ROLE_PERMISSIONS: Record<RoleName, readonly Permission[]> = {
  SUPER_ADMIN: ALL_PERMISSIONS,

  // Intentionally empty: see the product rule above.
  MASJID_ADMIN: [],

  IMAM: [
    ...EVERYONE,
    P.NAMAZ_TIMES_UPDATE,
    P.ANNOUNCEMENTS_MANAGE,
    P.IMAM_SALARY_READ,
    P.CONTRIBUTIONS_READ,
  ],

  COMMITTEE_MEMBER: [
    ...EVERYONE,
    P.NAMAZ_TIMES_UPDATE,
    P.ANNOUNCEMENTS_MANAGE,
    P.MASJID_UPDATE,
    P.MEMBERS_MANAGE,
    P.COLLECTIONS_MANAGE,
    P.EXPENSES_MANAGE,
    P.PROJECTS_MANAGE,
    P.CONTRIBUTIONS_READ,
    P.CONTRIBUTIONS_RECORD,
    P.IMAM_SALARY_READ,
    P.IMAM_SALARY_MANAGE,
  ],

  MEMBER: [...EVERYONE],
};

/** Roles that can be handed out from the app. SUPER_ADMIN is created by script only. */
export const ASSIGNABLE_ROLES: readonly RoleName[] = [
  'IMAM',
  'COMMITTEE_MEMBER',
  'MEMBER',
];

function isRoleName(value: string): value is RoleName {
  return (ROLE_NAMES as readonly string[]).includes(value);
}

/** Union of the permissions of the given roles, in catalogue order. */
export function permissionsForRoles(roles: readonly string[]): Permission[] {
  const granted = new Set<Permission>();
  for (const role of roles) {
    if (isRoleName(role)) {
      ROLE_PERMISSIONS[role].forEach((permission) => granted.add(permission));
    }
  }
  return ALL_PERMISSIONS.filter((permission) => granted.has(permission));
}

export function hasPermission(
  user: { roles: readonly string[] },
  permission: Permission,
): boolean {
  return permissionsForRoles(user.roles).includes(permission);
}

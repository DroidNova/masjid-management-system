import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import {
  AUDIT_ACTION,
  AUDIT_ENTITY,
  AuditService,
} from '../../../common/audit/audit.service';
import { PrismaService } from '../../../prisma/prisma.service';
import { Prisma } from '../../../generated/prisma/client';
import {
  MasjidRegistrationStatus,
  MasjidStatus,
  RoleName,
  UserStatus,
} from '../../../generated/prisma/enums';
import { AuthenticatedUser } from '../auth/types/jwt-payload.type';
import { RolesService } from '../roles/roles.service';
import { AssignUserRolesDto } from './dto/assign-user-roles.dto';
import { ListAdminUsersDto } from './dto/list-admin-users.dto';
import {
  AdminUserStatus,
  UpdateUserStatusDto,
} from './dto/update-user-status.dto';
import { ASSIGNABLE_ROLES } from '../../../access/permissions';
import {
  ListAdminMasjidsDto,
  UpdateMasjidStatusDto,
} from './dto/admin-masjids.dto';
import { pageArgs, paged } from '../../../common/pagination';
import { ApiException } from '../../../common/exceptions/api.exception';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';

const SUPER_ADMIN_ROLE = 'SUPER_ADMIN';

const roleNamesSelect = {
  select: { role: { select: { name: true } } },
} as const;

/** Columns of GET /admin/users/:id (also returned by POST :id/roles). */
const userDetailSelect = {
  id: true,
  fullName: true,
  email: true,
  phone: true,
  fatherName: true,
  age: true,
  gender: true,
  isFamilyHead: true,
  familyMemberCount: true,
  status: true,
  masjidId: true,
  masjid: { select: { name: true } },
  createdAt: true,
  updatedAt: true,
  userRoles: roleNamesSelect,
} as const satisfies Prisma.UserSelect;

type UserDetailRow = Prisma.UserGetPayload<{
  select: typeof userDetailSelect;
}>;

const masjidDetailSelect = {
  id: true,
  name: true,
  country: true,
  locality: true,
  district: true,
  state: true,
  address: true,
  contactNo: true,
  description: true,
  welcomeMsg: true,
  status: true,
  requestedByName: true,
  requestedByPhone: true,
  requestedByEmail: true,
  imamUserId: true,
  imamUser: {
    select: { id: true, fullName: true, phone: true, email: true },
  },
  _count: { select: { users: true } },
  createdAt: true,
  updatedAt: true,
} as const satisfies Prisma.MasjidSelect;

/** Statuses that need a reason when the super admin sets them. */
const MASJID_STATUSES_NEEDING_REASON = new Set<MasjidStatus>([
  MasjidStatus.REJECTED,
  MasjidStatus.SUSPENDED,
]);

function roleNamesOf(user: {
  userRoles: Array<{ role: { name: string } }>;
}): string[] {
  return user.userRoles.map((userRole) => userRole.role.name);
}

function countByStatus(
  rows: Array<{ status: string; _count: { _all: number } }>,
): Record<string, number> & { total: number } {
  const counts: Record<string, number> = {};
  let total = 0;
  for (const row of rows) {
    counts[row.status] = row._count._all;
    total += row._count._all;
  }
  return Object.assign(counts, { total });
}

@Injectable()
export class AdminService {
  private readonly logger = new Logger(AdminService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly rolesService: RolesService,
    private readonly audit: AuditService,
  ) {}

  async listUsers(query: ListAdminUsersDto) {
    const { page, limit, skip, take } = pageArgs(query);
    const trimmedSearch = query.search?.trim();
    const where: Prisma.UserWhereInput = {};

    if (trimmedSearch) {
      where.OR = [
        { fullName: { contains: trimmedSearch, mode: 'insensitive' } },
        { email: { contains: trimmedSearch, mode: 'insensitive' } },
        { phone: { contains: trimmedSearch, mode: 'insensitive' } },
      ];
    }
    if (query.status) where.status = query.status;
    if (query.masjidId) where.masjidId = query.masjidId;
    if (query.role) {
      where.userRoles = {
        some: { role: { name: query.role.trim().toUpperCase() as RoleName } },
      };
    }

    const [items, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
        select: {
          id: true,
          fullName: true,
          email: true,
          phone: true,
          fatherName: true,
          age: true,
          gender: true,
          isFamilyHead: true,
          familyMemberCount: true,
          status: true,
          masjidId: true,
          createdAt: true,
          masjid: { select: { id: true, name: true } },
          userRoles: roleNamesSelect,
        },
      }),
      this.prisma.user.count({ where }),
    ]);

    return paged(
      items.map((user) => ({
        ...user,
        roles: roleNamesOf(user),
        masjidName: user.masjid?.name ?? null,
      })),
      total,
      page,
      limit,
    );
  }

  async getUserById(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: userDetailSelect,
    });
    if (!user) throw this.userNotFound();
    return this.toUserDetail(user);
  }

  /**
   * Changes a user's status. Setting INACTIVE or SUSPENDED also deletes the
   * user's sessions, so they are signed out immediately.
   */
  async updateUserStatus(
    id: string,
    dto: UpdateUserStatusDto,
    actor: AuthenticatedUser,
  ) {
    const signOut = dto.status !== AdminUserStatus.ACTIVE;

    const { updated, signedOutSessions } = await this.prisma.$transaction(
      async (tx) => {
        const before = await tx.user.findUnique({
          where: { id },
          select: {
            id: true,
            fullName: true,
            status: true,
            masjidId: true,
            userRoles: roleNamesSelect,
          },
        });
        if (!before) throw this.userNotFound();
        this.assertCanModifyTargetUser(roleNamesOf(before));

        const result = await tx.user.update({
          where: { id },
          data: { status: dto.status },
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            status: true,
            updatedAt: true,
          },
        });
        const sessions = signOut
          ? await tx.session.deleteMany({ where: { userId: id } })
          : { count: 0 };
        await this.audit.record(
          {
            masjidId: before.masjidId ?? null,
            actor,
            action: AUDIT_ACTION.STATUS_CHANGE,
            entity: AUDIT_ENTITY.USER,
            entityId: id,
            summary: `User "${before.fullName}" status ${before.status} -> ${dto.status}`,
            before: {
              id: before.id,
              fullName: before.fullName,
              status: before.status,
              masjidId: before.masjidId,
            },
            after: result,
          },
          tx,
        );
        return { updated: result, signedOutSessions: sessions.count };
      },
    );

    this.logger.log({
      message: 'User status changed',
      userId: id,
      status: dto.status,
      signedOutSessions,
      actorId: actor.id,
    });
    return updated;
  }

  /** Three grouped counts instead of one count per status. */
  async getDashboardSummary() {
    const [users, masjids, requests] = await Promise.all([
      this.prisma.user.groupBy({ by: ['status'], _count: { _all: true } }),
      this.prisma.masjid.groupBy({ by: ['status'], _count: { _all: true } }),
      this.prisma.masjidRegistrationRequest.groupBy({
        by: ['status'],
        _count: { _all: true },
      }),
    ]);
    const userCounts = countByStatus(users);
    const masjidCounts = countByStatus(masjids);
    const requestCounts = countByStatus(requests);

    return {
      totalUsers: userCounts.total,
      activeUsers: userCounts[UserStatus.ACTIVE] ?? 0,
      inactiveUsers: userCounts[UserStatus.INACTIVE] ?? 0,
      suspendedUsers: userCounts[UserStatus.SUSPENDED] ?? 0,
      totalMasjids: masjidCounts.total,
      approvedMasjids: masjidCounts[MasjidStatus.APPROVED] ?? 0,
      pendingMasjids: masjidCounts[MasjidStatus.PENDING] ?? 0,
      suspendedMasjids: masjidCounts[MasjidStatus.SUSPENDED] ?? 0,
      pendingRequests: requestCounts[MasjidRegistrationStatus.PENDING] ?? 0,
      approvedRequests: requestCounts[MasjidRegistrationStatus.APPROVED] ?? 0,
      rejectedRequests: requestCounts[MasjidRegistrationStatus.REJECTED] ?? 0,
    };
  }

  async listMasjids(query: ListAdminMasjidsDto) {
    const { page, limit, skip, take } = pageArgs(query);
    const search = query.search?.trim();
    const where: Prisma.MasjidWhereInput = {};

    if (query.status) where.status = query.status;
    if (query.state)
      where.state = { contains: query.state, mode: 'insensitive' };
    if (query.country)
      where.country = { contains: query.country, mode: 'insensitive' };
    if (query.district)
      where.district = { contains: query.district, mode: 'insensitive' };
    if (query.locality)
      where.locality = { contains: query.locality, mode: 'insensitive' };
    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { state: { contains: search, mode: 'insensitive' } },
        { country: { contains: search, mode: 'insensitive' } },
        { district: { contains: search, mode: 'insensitive' } },
        { locality: { contains: search, mode: 'insensitive' } },
        { address: { contains: search, mode: 'insensitive' } },
        { contactNo: { contains: search, mode: 'insensitive' } },
        { requestedByName: { contains: search, mode: 'insensitive' } },
        { requestedByPhone: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [items, total] = await Promise.all([
      this.prisma.masjid.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        select: masjidDetailSelect,
      }),
      this.prisma.masjid.count({ where }),
    ]);

    return paged(
      items.map((masjid) => ({
        ...masjid,
        imamName: masjid.imamUser?.fullName ?? null,
        usersCount: masjid._count.users,
      })),
      total,
      page,
      limit,
    );
  }

  async getMasjidById(id: string) {
    const masjid = await this.prisma.masjid.findUnique({
      where: { id },
      select: { ...masjidDetailSelect, rejectionReason: true },
    });

    if (!masjid) throw this.masjidNotFound();

    return {
      ...masjid,
      imamName: masjid.imamUser?.fullName ?? null,
      usersCount: masjid._count.users,
    };
  }

  /** REJECTED and SUSPENDED need a reason, shown to the masjid. */
  async updateMasjidStatus(
    id: string,
    dto: UpdateMasjidStatusDto,
    actor: AuthenticatedUser,
  ) {
    const reason = dto.reason?.trim() || null;
    if (MASJID_STATUSES_NEEDING_REASON.has(dto.status) && !reason) {
      throw new ApiException(
        `A reason is required to set the masjid ${dto.status.toLowerCase()}`,
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.VALIDATION_ERROR,
        { reason: ['Reason is required'] },
      );
    }

    return this.prisma.$transaction(async (tx) => {
      const before = await tx.masjid.findUnique({
        where: { id },
        select: { id: true, name: true, status: true, rejectionReason: true },
      });
      if (!before) throw this.masjidNotFound();

      const updated = await tx.masjid.update({
        where: { id },
        data: { status: dto.status, rejectionReason: reason },
        select: {
          id: true,
          name: true,
          country: true,
          state: true,
          address: true,
          contactNo: true,
          status: true,
          rejectionReason: true,
          updatedAt: true,
        },
      });
      await this.audit.record(
        {
          masjidId: id,
          actor,
          action: AUDIT_ACTION.STATUS_CHANGE,
          entity: AUDIT_ENTITY.MASJID,
          entityId: id,
          summary: `Masjid "${updated.name}" status ${before.status} -> ${updated.status}${updated.rejectionReason ? ` (${updated.rejectionReason})` : ''}`,
          before,
          after: updated,
        },
        tx,
      );
      return updated;
    });
  }

  /** Replaces the user's roles. Returns the same shape as GET /admin/users/:id. */
  async assignRoles(
    id: string,
    dto: AssignUserRolesDto,
    actor: AuthenticatedUser,
  ) {
    const normalizedRoleNames = Array.from(
      new Set(
        dto.roleNames
          .map((roleName) =>
            roleName
              .trim()
              .toUpperCase()
              .replace(/[\s-]+/g, '_'),
          )
          .filter(Boolean),
      ),
    );

    if (!normalizedRoleNames.length) {
      throw new ApiException(
        'At least one role name is required',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.VALIDATION_ERROR,
      );
    }

    if (normalizedRoleNames.includes(SUPER_ADMIN_ROLE)) {
      throw new ApiException(
        'SUPER_ADMIN role can only be provisioned manually',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.ROLE_NOT_ASSIGNABLE,
      );
    }

    const notAssignable = normalizedRoleNames.filter(
      (name) => !(ASSIGNABLE_ROLES as readonly string[]).includes(name),
    );
    if (notAssignable.length) {
      throw new ApiException(
        `These roles cannot be assigned: ${notAssignable.join(', ')}. Allowed: ${ASSIGNABLE_ROLES.join(', ')}`,
        HttpStatus.FORBIDDEN,
        ERROR_CODES.ROLE_NOT_ASSIGNABLE,
      );
    }

    // Cached after the first call: normally no query.
    const roles =
      await this.rolesService.validateRoleNames(normalizedRoleNames);
    const afterRoles = roles.map((role) => role.name);

    // Replace roles atomically so a failure never leaves the user with none.
    const user = await this.prisma.$transaction(async (tx) => {
      const before = await tx.user.findUnique({
        where: { id },
        select: userDetailSelect,
      });
      if (!before) throw this.userNotFound();
      const beforeRoles = roleNamesOf(before);
      this.assertCanModifyTargetUser(beforeRoles);

      await tx.userRole.deleteMany({ where: { userId: id } });
      await tx.userRole.createMany({
        data: roles.map((role) => ({ userId: id, roleId: role.id })),
        skipDuplicates: true,
      });
      await this.audit.record(
        {
          masjidId: before.masjidId ?? null,
          actor,
          action: AUDIT_ACTION.ROLES_CHANGE,
          entity: AUDIT_ENTITY.USER,
          entityId: id,
          summary: `User "${before.fullName}" roles ${beforeRoles.join(', ') || 'none'} -> ${afterRoles.join(', ')}`,
          before: { roles: beforeRoles },
          after: { roles: afterRoles },
        },
        tx,
      );
      return before;
    });
    this.logger.log({
      message: 'User roles replaced',
      userId: id,
      roles: afterRoles,
      actorId: actor.id,
    });

    return { ...this.toUserDetail(user), roles: afterRoles };
  }

  private toUserDetail(user: UserDetailRow) {
    return {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      fatherName: user.fatherName,
      age: user.age,
      gender: user.gender,
      isFamilyHead: user.isFamilyHead,
      familyMemberCount: user.familyMemberCount,
      status: user.status,
      masjidId: user.masjidId,
      masjidName: user.masjid?.name ?? null,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      roles: roleNamesOf(user),
    };
  }

  /** Admin APIs are super-admin only; super admin accounts are managed by script. */
  private assertCanModifyTargetUser(targetRoleNames: string[]): void {
    if (targetRoleNames.includes(SUPER_ADMIN_ROLE)) {
      throw new ApiException(
        'SUPER_ADMIN account cannot be modified from admin APIs',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.SUPER_ADMIN_IMMUTABLE,
      );
    }
  }

  private userNotFound(): ApiException {
    return new ApiException(
      'User not found',
      HttpStatus.NOT_FOUND,
      ERROR_CODES.USER_NOT_FOUND,
    );
  }

  private masjidNotFound(): ApiException {
    return new ApiException(
      'Masjid not found',
      HttpStatus.NOT_FOUND,
      ERROR_CODES.MASJID_NOT_FOUND,
    );
  }
}

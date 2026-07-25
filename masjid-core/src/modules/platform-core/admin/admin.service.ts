import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../auth/types/jwt-payload.type';
import { RolesService } from '../roles/roles.service';
import { AssignUserRolesDto } from './dto/assign-user-roles.dto';
import { ListAdminUsersDto } from './dto/list-admin-users.dto';
import { UpdateUserStatusDto } from './dto/update-user-status.dto';

const SUPER_ADMIN_ROLE = 'SUPER_ADMIN';
const MASJID_ADMIN_ROLE = 'MASJID_ADMIN';

@Injectable()
export class AdminService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly rolesService: RolesService,
  ) {}

  async listUsers(query: ListAdminUsersDto) {
    const page = query.page ?? 1;
    const limit = Math.min(query.limit ?? 20, 100);
    const skip = (page - 1) * limit;

    const trimmedSearch = query.search?.trim();
    const where = {} as any;

    if (trimmedSearch) {
      where.OR = [
        {
          fullName: {
            contains: trimmedSearch,
            mode: 'insensitive' as const,
          },
        },
        {
          email: { contains: trimmedSearch, mode: 'insensitive' as const },
        },
        {
          phone: { contains: trimmedSearch, mode: 'insensitive' as const },
        },
      ];
    }
    if (query.status) where.status = query.status;
    if (query.masjidId) where.masjidId = query.masjidId;
    if (query.role) {
      where.userRoles = {
        some: { role: { name: query.role.trim().toUpperCase() } },
      };
    }

    const [items, total] = await this.prisma.$transaction([
      this.prisma.user.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
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
          userRoles: { select: { role: { select: { name: true } } } },
        },
      }),
      this.prisma.user.count({ where }),
    ]);

    return {
      items: items.map((user) => ({
        ...user,
        roles: user.userRoles.map((userRole) => userRole.role.name),
        masjidName: user.masjid?.name ?? null,
      })),
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async getUserById(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
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
        createdAt: true,
        updatedAt: true,
        userRoles: {
          include: {
            role: true,
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

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
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      roles: user.userRoles.map(
        (userRole: { role: { name: string } }) => userRole.role.name,
      ),
    };
  }

  async updateUserStatus(
    id: string,
    dto: UpdateUserStatusDto,
    actor: AuthenticatedUser,
  ) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        userRoles: {
          select: {
            role: {
              select: {
                name: true,
              },
            },
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    this.assertCanModifyTargetUser({
      actorRoles: actor.roles,
      targetRoleNames: user.userRoles.map((userRole) => userRole.role.name),
    });

    return this.prisma.user.update({
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
  }

  async getDashboardSummary() {
    const [
      totalUsers,
      activeUsers,
      inactiveUsers,
      suspendedUsers,
      totalMasjids,
      approvedMasjids,
      pendingMasjids,
      suspendedMasjids,
      pendingRequests,
      approvedRequests,
      rejectedRequests,
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.user.count({ where: { status: 'ACTIVE' } }),
      this.prisma.user.count({ where: { status: 'INACTIVE' } }),
      this.prisma.user.count({ where: { status: 'SUSPENDED' } }),
      this.prisma.masjid.count(),
      this.prisma.masjid.count({ where: { status: 'APPROVED' } }),
      this.prisma.masjid.count({ where: { status: 'PENDING' } }),
      this.prisma.masjid.count({ where: { status: 'SUSPENDED' } }),
      this.prisma.masjidRegistrationRequest.count({
        where: { status: 'PENDING' },
      }),
      this.prisma.masjidRegistrationRequest.count({
        where: { status: 'APPROVED' },
      }),
      this.prisma.masjidRegistrationRequest.count({
        where: { status: 'REJECTED' },
      }),
    ]);

    return {
      totalUsers,
      activeUsers,
      inactiveUsers,
      suspendedUsers,
      totalMasjids,
      approvedMasjids,
      pendingMasjids,
      suspendedMasjids,
      pendingRequests,
      approvedRequests,
      rejectedRequests,
    };
  }

  async listMasjids(query: {
    search?: string;
    status?: string;
    state?: string;
    country?: string;
    district?: string;
    locality?: string;
    page?: number;
    limit?: number;
  }) {
    const page = Number(query.page ?? 1) || 1;
    const limit = Math.min(Number(query.limit ?? 20) || 20, 100);
    const search = query.search?.trim();
    const where = {} as any;

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
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
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
        },
      }),
      this.prisma.masjid.count({ where }),
    ]);

    return {
      items: items.map((masjid) => ({
        ...masjid,
        imamName: masjid.imamUser?.fullName ?? null,
        usersCount: masjid._count.users,
      })),
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async getMasjidById(id: string) {
    const masjid = await this.prisma.masjid.findUnique({
      where: { id },
      select: {
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
        rejectionReason: true,
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
      },
    });

    if (!masjid) throw new NotFoundException('Masjid not found');

    return {
      ...masjid,
      imamName: masjid.imamUser?.fullName ?? null,
      usersCount: masjid._count.users,
    };
  }

  async updateMasjidStatus(
    id: string,
    dto: { status: string; reason?: string },
  ) {
    const masjid = await this.prisma.masjid.findUnique({
      where: { id },
      select: { id: true },
    });

    if (!masjid) throw new NotFoundException('Masjid not found');

    return this.prisma.masjid.update({
      where: { id },
      data: {
        status: dto.status as any,
        rejectionReason: dto.reason?.trim() || null,
      },
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
  }

  async assignRoles(
    id: string,
    dto: AssignUserRolesDto,
    actor: AuthenticatedUser,
  ) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        userRoles: {
          select: {
            role: {
              select: {
                name: true,
              },
            },
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

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
      throw new BadRequestException('At least one role name is required');
    }

    if (normalizedRoleNames.includes(SUPER_ADMIN_ROLE)) {
      throw new ForbiddenException(
        'SUPER_ADMIN role can only be provisioned manually',
      );
    }

    const isActorSuperAdmin = actor.roles.includes(SUPER_ADMIN_ROLE);
    const isPromotingToAdmin = normalizedRoleNames.includes(MASJID_ADMIN_ROLE);

    if (isPromotingToAdmin && !isActorSuperAdmin) {
      throw new ForbiddenException(
        'Only super admin can assign MASJID_ADMIN role',
      );
    }

    this.assertCanModifyTargetUser({
      actorRoles: actor.roles,
      targetRoleNames: user.userRoles.map((userRole) => userRole.role.name),
    });

    const roles =
      await this.rolesService.validateRoleNames(normalizedRoleNames);

    await this.prisma.userRole.deleteMany({ where: { userId: id } });
    await this.prisma.userRole.createMany({
      data: roles.map((role) => ({ userId: id, roleId: role.id })),
      skipDuplicates: true,
    });

    return this.getUserById(id);
  }

  private assertCanModifyTargetUser(params: {
    actorRoles: string[];
    targetRoleNames: string[];
  }): void {
    const { actorRoles, targetRoleNames } = params;
    const isActorSuperAdmin = actorRoles.includes(SUPER_ADMIN_ROLE);
    const isTargetSuperAdmin = targetRoleNames.includes(SUPER_ADMIN_ROLE);
    const isTargetAdmin = targetRoleNames.includes(MASJID_ADMIN_ROLE);

    if (isTargetSuperAdmin) {
      throw new ForbiddenException(
        'SUPER_ADMIN account cannot be modified from admin APIs',
      );
    }

    if (isTargetAdmin && !isActorSuperAdmin) {
      throw new ForbiddenException(
        'Only super admin can modify masjid admin accounts',
      );
    }
  }
}

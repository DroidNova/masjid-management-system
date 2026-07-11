import { getPhoneSearchVariants, normalizePhone } from '../../../common/utils/phone.util';
import { randomBytes } from 'crypto';
import { HttpStatus, Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import {
  CreateMasjidUserDto,
  CreateMasjidUserRoleDto,
} from './dto/create-masjid-user.dto';
import { UpdateWelcomeMessageDto } from './dto/update-welcome-message.dto';

type BasicUser = {
  id: string;
  fullName: string;
  email: string | null;
  phone: string | null;
};

type CreatedMasjidUserResponse = {
  id: string;
  fullName: string;
  email: string | null;
  phone: string | null;
  status: string;
  masjidId: string;
  roles: string[];
  temporaryPassword?: string;
  message?: string;
};

type CurrentUserWithRoles = {
  id: string;
  masjidId: string | null;
  userRoles: Array<{ role: { name: string } }>;
};

type CreatedUserWithRoles = {
  id: string;
  fullName: string;
  email: string | null;
  phone: string | null;
  status: string;
  masjidId: string | null;
  userRoles: Array<{ role: { name: string } }>;
};

type UserRoleRecord = {
  role: {
    name: string;
  };
};

type MasjidMemberRecord = {
  id: string;
  fullName: string;
  email: string | null;
  phone: string | null;
  status: string;
  masjidId: string | null;
  createdAt: Date;
  updatedAt: Date;
  userRoles: UserRoleRecord[];
};

type MasjidMemberResponse = {
  id: string;
  fullName: string;
  email: string | null;
  phone: string | null;
  status: string;
  masjidId: string;
  createdAt: Date;
  updatedAt: Date;
  roles: string[];
};

type NamazTimeRecord = {
  id: string;
  fajr: string | null;
  zuhr: string | null;
  asr: string | null;
  maghrib: string | null;
  isha: string | null;
  jumma: string | null;
  note: string | null;
};

type AnnouncementRecord = {
  id: string;
  title: string;
  message: string;
  createdAt: Date;
};

type MasjidProfileRecord = {
  id: string;
  name: string;
  village: string | null;
  city: string | null;
  district: string | null;
  state: string | null;
  country: string | null;
  address: string | null;
  requestedByName: string | null;
  requestedByPhone: string | null;
  requestedByEmail: string | null;
  contactNo: string | null;
  description: string | null;
  welcomeMsg: string | null;
  status: string;
  createdAt: Date;
  updatedAt: Date;
  imamUser: BasicUser | null;
  namazTime: NamazTimeRecord | null;
  announcements: AnnouncementRecord[];
};

type MasjidWelcomeRecord = {
  id: string;
  name: string;
  welcomeMsg: string | null;
  updatedAt: Date;
};

type MasjidsUserDelegate = {
  findMany(args: {
    where: { masjidId: string };
    orderBy: { fullName: 'asc' };
    select: typeof masjidMemberSelect;
  }): Promise<MasjidMemberRecord[]>;
};

type MasjidsMasjidDelegate = {
  findUnique(args: {
    where: { id: string };
    select: typeof masjidProfileSelect;
  }): Promise<MasjidProfileRecord | null>;
  update(args: {
    where: { id: string };
    data: { welcomeMsg: string };
    select: typeof masjidWelcomeSelect;
  }): Promise<MasjidWelcomeRecord>;
};

type MasjidsPrismaDelegate = {
  user: MasjidsUserDelegate;
  masjid: MasjidsMasjidDelegate;
};

const basicUserSelect = {
  id: true,
  fullName: true,
  email: true,
  phone: true,
} as const;

const masjidProfileSelect = {
  id: true,
  name: true,
  village: true,
  city: true,
  district: true,
  state: true,
  country: true,
  address: true,
  requestedByName: true,
  requestedByPhone: true,
  requestedByEmail: true,
  contactNo: true,
  description: true,
  welcomeMsg: true,
  status: true,
  createdAt: true,
  updatedAt: true,
  imamUser: { select: basicUserSelect },
  namazTime: {
    select: {
      id: true,
      fajr: true,
      zuhr: true,
      asr: true,
      maghrib: true,
      isha: true,
      jumma: true,
      note: true,
    },
  },
  announcements: {
    where: { isActive: true },
    orderBy: { createdAt: 'desc' },
    take: 3,
    select: {
      id: true,
      title: true,
      message: true,
      createdAt: true,
    },
  },
} as const;

const masjidWelcomeSelect = {
  id: true,
  name: true,
  welcomeMsg: true,
  updatedAt: true,
} as const;

const masjidUserCreateSelect = {
  id: true,
  fullName: true,
  email: true,
  phone: true,
  status: true,
  masjidId: true,
  userRoles: {
    select: {
      role: {
        select: {
          name: true,
        },
      },
    },
  },
} as const;

const masjidMemberSelect = {
  id: true,
  fullName: true,
  email: true,
  phone: true,
  status: true,
  masjidId: true,
  createdAt: true,
  updatedAt: true,
  userRoles: {
    select: {
      role: {
        select: {
          name: true,
        },
      },
    },
  },
} as const;

@Injectable()
export class MasjidsService {
  constructor(private readonly prisma: PrismaService) {}

  private get db(): MasjidsPrismaDelegate {
    return this.prisma as unknown as MasjidsPrismaDelegate;
  }

  async getMyMasjid(actor: AuthenticatedUser): Promise<MasjidProfileRecord> {
    if (!actor.masjidId) {
      throw new ApiException(
        'Current user is not assigned to a masjid',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.USER_MASJID_NOT_ASSIGNED,
      );
    }

    const masjid = await this.db.masjid.findUnique({
      where: { id: actor.masjidId },
      select: masjidProfileSelect,
    });

    if (!masjid) {
      throw new ApiException(
        'Masjid not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.MASJID_NOT_FOUND,
      );
    }

    return masjid;
  }

  async updateWelcomeMessage(
    dto: UpdateWelcomeMessageDto,
    actor: AuthenticatedUser,
  ): Promise<MasjidWelcomeRecord> {
    if (!actor.masjidId) {
      throw new ApiException(
        'Current user is not assigned to a masjid',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.USER_MASJID_NOT_ASSIGNED,
      );
    }

    try {
      return await this.db.masjid.update({
        where: { id: actor.masjidId },
        data: { welcomeMsg: dto.welcomeMsg },
        select: masjidWelcomeSelect,
      });
    } catch {
      throw new ApiException(
        'Masjid not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.MASJID_NOT_FOUND,
      );
    }
  }

  async createMyMasjidUser(
    actor: AuthenticatedUser,
    dto: CreateMasjidUserDto,
  ): Promise<CreatedMasjidUserResponse> {
    const currentUser = this.toCurrentUserWithRoles(actor);

    const callerRoles = this.resolveCallerRoles(actor, currentUser);
    this.assertCanCreateRole(callerRoles, dto.role);

    if (!callerRoles.includes('SUPER_ADMIN') && dto.masjidId) {
      throw new ApiException(
        'You are not allowed to choose a masjid',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.FORBIDDEN,
      );
    }

    const masjidId = this.resolveTargetMasjidId(callerRoles, currentUser, dto);
    const masjid = await this.prisma.masjid.findUnique({
      where: { id: masjidId },
      select: { id: true, status: true },
    });

    if (!masjid) {
      throw new ApiException(
        'Masjid not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.MASJID_NOT_FOUND,
      );
    }

    if (masjid.status !== 'APPROVED') {
      throw new ApiException(
        'Masjid is not approved',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.MASJID_NOT_APPROVED,
      );
    }

    const phone = normalizePhone(dto.phone);
    const email = dto.email?.trim().toLowerCase() || null;

    const existingByPhone = await this.prisma.user.findFirst({
      where: { phone: { in: getPhoneSearchVariants(phone) } },
      select: { id: true },
    });

    if (existingByPhone) {
      throw new ApiException(
        'Phone number already exists',
        HttpStatus.CONFLICT,
        ERROR_CODES.PHONE_ALREADY_EXISTS,
      );
    }

    if (email) {
      const existingByEmail = await this.prisma.user.findUnique({
        where: { email },
        select: { id: true },
      });

      if (existingByEmail) {
        throw new ApiException(
          'Email already exists',
          HttpStatus.CONFLICT,
          ERROR_CODES.EMAIL_ALREADY_EXISTS,
        );
      }
    }

    const role = await this.prisma.role.findUnique({
      where: { name: dto.role },
      select: { id: true, name: true },
    });

    if (!role) {
      throw new ApiException(
        'Role not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.ROLE_NOT_FOUND,
      );
    }

    const temporaryPassword = this.requiresTemporaryPassword(dto.role)
      ? '12345678'
      : null;
    const generatedPassword =
      temporaryPassword ?? randomBytes(32).toString('hex');
    // TODO: Replace temporary password with secure invite/reset password flow before production.
    const passwordHash = await bcrypt.hash(generatedPassword, 10);

    const createdUser = await this.prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          fullName: dto.fullName.trim(),
          phone,
          email,
          masjidId,
          status: 'ACTIVE',
          isPhoneVerified: false,
          isEmailVerified: false,
          passwordHash,
        },
        select: {
          id: true,
          fullName: true,
          email: true,
          phone: true,
          status: true,
          masjidId: true,
        },
      });

      await tx.userRole.create({
        data: {
          userId: user.id,
          roleId: role.id,
        },
      });

      if (dto.role === CreateMasjidUserRoleDto.IMAM) {
        // Replacing imamUserId is allowed here; the previous imam user is not deleted.
        await tx.masjid.update({
          where: { id: masjidId },
          data: { imamUserId: user.id },
          select: { id: true },
        });
      }

      return tx.user.findUnique({
        where: { id: user.id },
        select: masjidUserCreateSelect,
      });
    });

    if (!createdUser) {
      throw new ApiException(
        'Masjid user not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.MASJID_USER_NOT_FOUND,
      );
    }

    const response = this.toCreatedMasjidUserResponse(
      createdUser as CreatedUserWithRoles,
    );

    if (temporaryPassword) {
      response.temporaryPassword = temporaryPassword;
      response.message =
        'Temporary password is 12345678. Ask user to change it later.';
    }

    return response;
  }

  async findMyMasjidUsers(
    actor: AuthenticatedUser,
  ): Promise<MasjidMemberResponse[]> {
    if (!actor.masjidId) {
      throw new ApiException(
        'Current user is not assigned to a masjid',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.USER_MASJID_NOT_ASSIGNED,
      );
    }

    const users = await this.db.user.findMany({
      where: { masjidId: actor.masjidId },
      orderBy: { fullName: 'asc' },
      select: masjidMemberSelect,
    });

    return users.map((user) => this.toMasjidMemberResponse(user));
  }

  private resolveCallerRoles(
    actor: AuthenticatedUser,
    currentUser: CurrentUserWithRoles,
  ): string[] {
    if (actor.roles?.length) {
      return actor.roles;
    }

    return currentUser.userRoles.map((userRole) => userRole.role.name);
  }

  private toCurrentUserWithRoles(actor: AuthenticatedUser): CurrentUserWithRoles {
    return {
      id: actor.id,
      masjidId: actor.masjidId,
      userRoles: actor.roles.map((role) => ({ role: { name: role } })),
    };
  }

  private assertCanCreateRole(
    callerRoles: string[],
    targetRole: CreateMasjidUserRoleDto,
  ): void {
    const allowedRoles = this.getAllowedCreatableRoles(callerRoles);

    if (!allowedRoles.includes(targetRole)) {
      throw new ApiException(
        'You are not allowed to add this role',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.INVALID_ROLE_FOR_CREATION,
      );
    }
  }

  private getAllowedCreatableRoles(
    callerRoles: string[],
  ): CreateMasjidUserRoleDto[] {
    if (
      callerRoles.includes('SUPER_ADMIN') ||
      callerRoles.includes('MASJID_ADMIN')
    ) {
      return [
        CreateMasjidUserRoleDto.IMAM,
        CreateMasjidUserRoleDto.COMMITTEE_MEMBER,
      ];
    }

    if (callerRoles.includes('COMMITTEE_MEMBER')) {
      return [CreateMasjidUserRoleDto.MEMBER];
    }

    return [];
  }

  private resolveTargetMasjidId(
    callerRoles: string[],
    currentUser: CurrentUserWithRoles,
    dto: CreateMasjidUserDto,
  ): string {
    const masjidId = callerRoles.includes('SUPER_ADMIN')
      ? currentUser.masjidId ?? dto.masjidId
      : currentUser.masjidId;

    if (!masjidId) {
      throw new ApiException(
        'Current user is not assigned to a masjid',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.USER_MASJID_NOT_ASSIGNED,
      );
    }

    return masjidId;
  }

  private requiresTemporaryPassword(role: CreateMasjidUserRoleDto): boolean {
    return (
      role === CreateMasjidUserRoleDto.IMAM ||
      role === CreateMasjidUserRoleDto.COMMITTEE_MEMBER
    );
  }

  private toCreatedMasjidUserResponse(
    user: CreatedUserWithRoles,
  ): CreatedMasjidUserResponse {
    return {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      status: user.status,
      masjidId: user.masjidId ?? '',
      roles: user.userRoles.map((userRole) => userRole.role.name),
    };
  }

  private toMasjidMemberResponse(
    user: MasjidMemberRecord,
  ): MasjidMemberResponse {
    return {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      status: user.status,
      masjidId: user.masjidId ?? '',
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      roles: user.userRoles.map((userRole) => userRole.role.name),
    };
  }
}

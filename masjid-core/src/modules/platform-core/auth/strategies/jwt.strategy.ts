import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PrismaService } from '../../../../prisma/prisma.service';
import { AppConfig } from '../../../../config/app-config';
import { AuthenticatedUser, JwtPayload } from '../types/jwt-payload.type';
import { ApiException } from '../../../../common/exceptions/api.exception';
import { ERROR_CODES } from '../../../../common/constants/error-codes.constant';
import { permissionsForRoles } from '../../../../access/permissions';

/** One row: the session's user with their role names. */
type SessionUserRow = {
  id: string;
  fullName: string;
  email: string | null;
  phone: string | null;
  status: string;
  masjidId: string | null;
  isEmailVerified: boolean;
  isPhoneVerified: boolean;
  isFamilyHead: boolean;
  createdAt: Date;
  updatedAt: Date;
  roles: string[];
};

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private readonly prisma: PrismaService,
    config: AppConfig,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.jwt.accessSecret,
    });
  }

  /**
   * Runs on every authenticated request, so it is a single SQL statement:
   * the token's session must still exist (logout, logout-all and password
   * changes take effect immediately), joined to its user and role names.
   * Only the columns the API needs are read (never the password hash).
   */
  async validate(payload: JwtPayload): Promise<AuthenticatedUser> {
    if (payload.typ !== 'access' || !payload.sid) {
      throw new ApiException(
        'Invalid authentication token',
        401,
        ERROR_CODES.UNAUTHORIZED,
      );
    }

    const rows = await this.prisma.$queryRaw<SessionUserRow[]>`
      SELECT u."id", u."fullName", u."email", u."phone", u."status"::text AS "status",
             u."masjidId", u."isEmailVerified", u."isPhoneVerified", u."isFamilyHead",
             u."createdAt", u."updatedAt",
             COALESCE(
               array_agg(r."name"::text) FILTER (WHERE r."name" IS NOT NULL),
               '{}'
             ) AS "roles"
      FROM "Session" s
      JOIN "User" u ON u."id" = s."userId"
      LEFT JOIN "UserRole" ur ON ur."userId" = u."id"
      LEFT JOIN "Role" r ON r."id" = ur."roleId"
      WHERE s."id" = ${payload.sid}::uuid
        AND s."userId" = ${payload.sub}::uuid
        AND s."expiresAt" > now()
      GROUP BY u."id"
    `;

    const user = rows[0];
    if (!user) {
      throw new ApiException(
        'Your session has ended. Please login again.',
        401,
        ERROR_CODES.SESSION_EXPIRED,
      );
    }
    if (user.status !== 'ACTIVE') {
      throw new ApiException(
        'Invalid authentication token',
        401,
        ERROR_CODES.UNAUTHORIZED,
      );
    }

    return {
      id: user.id,
      sessionId: payload.sid,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      masjidId: user.masjidId,
      status: user.status,
      isEmailVerified: user.isEmailVerified,
      isPhoneVerified: user.isPhoneVerified,
      isFamilyHead: user.isFamilyHead,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      roles: user.roles,
      permissions: permissionsForRoles(user.roles),
    };
  }
}

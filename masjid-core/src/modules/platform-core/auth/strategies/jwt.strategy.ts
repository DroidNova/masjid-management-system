import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PrismaService } from '../../../../prisma/prisma.service';
import { AppConfig } from '../../../../config/app-config';
import { AuthenticatedUser, JwtPayload } from '../types/jwt-payload.type';
import { ApiException } from '../../../../common/exceptions/api.exception';
import { ERROR_CODES } from '../../../../common/constants/error-codes.constant';
import { toSafeUser, USER_ACCESS_INCLUDE } from '../auth.service';

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
   * Runs on every authenticated request. The token is only accepted while its
   * session row exists, so logout, logout-all and password changes take effect
   * immediately rather than when the access token expires.
   */
  async validate(payload: JwtPayload): Promise<AuthenticatedUser> {
    if (payload.typ !== 'access' || !payload.sid) {
      throw new ApiException(
        'Invalid authentication token',
        401,
        ERROR_CODES.UNAUTHORIZED,
      );
    }

    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
      include: {
        ...USER_ACCESS_INCLUDE,
        sessions: {
          where: { id: payload.sid, expiresAt: { gt: new Date() } },
          select: { id: true },
        },
      },
    });

    if (!user || user.status !== 'ACTIVE') {
      throw new ApiException(
        'Invalid authentication token',
        401,
        ERROR_CODES.UNAUTHORIZED,
      );
    }

    if (!user.sessions.length) {
      throw new ApiException(
        'Your session has ended. Please login again.',
        401,
        ERROR_CODES.SESSION_EXPIRED,
      );
    }

    return { ...toSafeUser(user), sessionId: payload.sid };
  }
}

import {
  applyDecorators,
  CanActivate,
  ExecutionContext,
  HttpStatus,
  Injectable,
  SetMetadata,
  UseGuards,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ApiForbiddenResponse } from '@nestjs/swagger';
import { ApiException } from '../common/exceptions/api.exception';
import { ERROR_CODES } from '../common/constants/error-codes.constant';
import { Permission } from './permissions';

export const PERMISSIONS_METADATA_KEY = 'requiredPermissions';

/**
 * Checks that the signed-in user holds every permission named in
 * @RequirePermissions. Must run after JwtAuthGuard (put JwtAuthGuard on the
 * controller class; this decorator adds the permission check per route).
 */
@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<Permission[] | undefined>(
      PERMISSIONS_METADATA_KEY,
      [context.getHandler(), context.getClass()],
    );
    if (!required?.length) return true;

    const user = context
      .switchToHttp()
      .getRequest<{ user?: { permissions?: string[] } }>().user;

    if (!user) {
      throw new ApiException(
        'Authentication token is missing',
        HttpStatus.UNAUTHORIZED,
        ERROR_CODES.UNAUTHORIZED,
      );
    }

    const granted = new Set(user.permissions ?? []);
    const missing = required.filter((permission) => !granted.has(permission));
    if (missing.length) {
      throw new ApiException(
        'You do not have permission to do this',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.FORBIDDEN,
        { missingPermissions: missing },
      );
    }

    return true;
  }
}

/** Route needs all of these permissions (see src/access/permissions.ts). */
export function RequirePermissions(...permissions: Permission[]) {
  return applyDecorators(
    SetMetadata(PERMISSIONS_METADATA_KEY, permissions),
    UseGuards(PermissionsGuard),
    ApiForbiddenResponse({
      description: `Requires permission: ${permissions.join(', ')}`,
    }),
  );
}

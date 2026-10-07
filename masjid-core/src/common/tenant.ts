import { HttpStatus } from '@nestjs/common';
import { ApiException } from './exceptions/api.exception';
import { ERROR_CODES, type ErrorCode } from './constants/error-codes.constant';

/**
 * Masjid scoping (multi-tenancy).
 *
 * Every masjid-level query must be scoped to the signed-in user's masjid,
 * taken from the token, never from the request body or query string.
 */

/** The signed-in user's masjid id, or 403 USER_MASJID_NOT_ASSIGNED. */
export function requireMasjidId(actor: { masjidId: string | null }): string {
  if (!actor.masjidId) {
    throw new ApiException(
      'Current user is not assigned to a masjid',
      HttpStatus.FORBIDDEN,
      ERROR_CODES.USER_MASJID_NOT_ASSIGNED,
    );
  }
  return actor.masjidId;
}

/**
 * Throws 403 when a record loaded by id belongs to another masjid.
 * Pass the module's own message and error code so responses stay specific.
 */
export function assertSameMasjid(
  recordMasjidId: string,
  masjidId: string,
  message: string,
  errorCode: ErrorCode,
): void {
  if (recordMasjidId !== masjidId) {
    throw new ApiException(message, HttpStatus.FORBIDDEN, errorCode);
  }
}

import { Prisma } from '../../generated/prisma/client';

/**
 * True when `error` is a Prisma known request error with this code, e.g.
 * P2002 (unique constraint) or P2025 (record to update not found).
 *
 * Use it to turn an expected database outcome into a module-specific error
 * code; anything else should be rethrown for the global exception filter.
 */
export function isPrismaError(error: unknown, code: string): boolean {
  return (
    error instanceof Prisma.PrismaClientKnownRequestError && error.code === code
  );
}

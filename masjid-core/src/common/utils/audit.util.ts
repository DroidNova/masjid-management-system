import { AuthenticatedUser } from '../../modules/platform-core/auth/types/jwt-payload.type';

const auditDisplayName = (user: AuthenticatedUser): string =>
  user.fullName?.trim() || user.phone?.trim() || 'Unknown';

export const getCreateAuditFields = (user: AuthenticatedUser) => ({
  createdById: user.id,
  createdByName: auditDisplayName(user),
});

export const getUpdateAuditFields = (user: AuthenticatedUser) => ({
  updatedById: user.id,
  updatedByName: auditDisplayName(user),
});

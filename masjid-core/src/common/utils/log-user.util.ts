import { Request } from 'express';

type RequestWithUser = Request & {
  user?: {
    id?: unknown;
    userId?: unknown;
    sub?: unknown;
    role?: unknown;
    roles?: unknown;
  };
};

export function getLogUser(req: RequestWithUser): {
  userId?: string;
  roles?: string[];
} {
  const user = req.user;

  if (!user || typeof user !== 'object') {
    return {};
  }

  const userId = firstString(user.id, user.userId, user.sub);
  const roles = normalizeRoles(user.roles ?? user.role);

  return {
    ...(userId ? { userId } : {}),
    ...(roles.length > 0 ? { roles } : {}),
  };
}

function firstString(...values: unknown[]): string | undefined {
  const value = values.find((item) => typeof item === 'string' && item.trim());
  return typeof value === 'string' ? value : undefined;
}

function normalizeRoles(value: unknown): string[] {
  if (Array.isArray(value)) {
    return value.filter((role): role is string => typeof role === 'string');
  }

  return typeof value === 'string' && value.trim() ? [value] : [];
}

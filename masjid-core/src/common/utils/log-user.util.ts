type LogUserPayload = {
  id?: unknown;
  userId?: unknown;
  sub?: unknown;
  role?: unknown;
  roles?: unknown;
};

export function getLogUser(req: unknown): {
  userId?: string;
  roles?: string[];
} {
  if (!req || typeof req !== 'object' || !('user' in req)) {
    return {};
  }

  const user = (req as { user?: unknown }).user;

  if (!user || typeof user !== 'object') {
    return {};
  }

  const payload = user as LogUserPayload;
  const userId = firstString(payload.id, payload.userId, payload.sub);
  const roles = normalizeRoles(payload.roles ?? payload.role);

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

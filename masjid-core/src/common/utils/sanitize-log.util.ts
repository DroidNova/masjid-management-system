const SENSITIVE_KEYS = new Set([
  'authorization',
  'cookie',
  'password',
  'passwordhash',
  'otp',
  'accesstoken',
  'refreshtoken',
  'token',
  'refreshtokenhash',
]);

export function sanitizeForLog<T>(value: T): T {
  return sanitizeValue(value) as T;
}

function sanitizeValue(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map((item) => sanitizeValue(item));
  }

  if (!value || typeof value !== 'object') {
    return value;
  }

  if (value instanceof Date) {
    return value.toISOString();
  }

  return Object.fromEntries(
    Object.entries(value as Record<string, unknown>).map(([key, entry]) => [
      key,
      SENSITIVE_KEYS.has(key.toLowerCase()) ? '[REDACTED]' : sanitizeValue(entry),
    ]),
  );
}

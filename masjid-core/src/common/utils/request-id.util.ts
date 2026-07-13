import { randomUUID } from 'node:crypto';
import { IncomingMessage } from 'node:http';

const REQUEST_ID_HEADER = 'x-request-id';
const MAX_REQUEST_ID_LENGTH = 64;
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const SAFE_REQUEST_ID_PATTERN = /^[0-9a-fA-F-]+$/;

type RequestWithHeaders = IncomingMessage & {
  headers: IncomingMessage['headers'] & Record<string, unknown>;
};

export function isValidRequestId(value: unknown): boolean {
  const candidate = normalizeHeaderValue(value);

  if (!candidate) return false;
  if (candidate.length > MAX_REQUEST_ID_LENGTH) return false;
  if (!SAFE_REQUEST_ID_PATTERN.test(candidate)) return false;

  return UUID_PATTERN.test(candidate);
}

export function getOrCreateRequestId(req: RequestWithHeaders): string {
  const headerValue = normalizeHeaderValue(req.headers?.[REQUEST_ID_HEADER]);

  if (isValidRequestId(headerValue)) {
    return headerValue;
  }

  return randomUUID();
}

function normalizeHeaderValue(value: unknown): string {
  const firstValue = Array.isArray(value) ? value[0] : value;

  if (typeof firstValue !== 'string') {
    return '';
  }

  return firstValue.trim();
}

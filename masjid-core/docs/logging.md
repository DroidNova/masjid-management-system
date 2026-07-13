# Backend Logging

The NestJS backend uses `nestjs-pino`, `pino`, and `pino-http` for lightweight environment-based logging. Logs are written to stdout so Docker or the hosting platform can manage retention.

## Packages

- `nestjs-pino`
- `pino`
- `pino-http`
- `pino-pretty` for local development only

## Modes

### Development

```env
NODE_ENV=development
LOG_LEVEL=debug
PRISMA_LOG_QUERIES=false
```

Development uses pretty, colorized, single-line logs with timestamps. Debug logs may be added for important service/business flows, but they must not include full request bodies or sensitive values.

Set `PRISMA_LOG_QUERIES=true` only for temporary local debugging when SQL query visibility is needed.

### Production

```env
NODE_ENV=production
LOG_LEVEL=info
PRISMA_LOG_QUERIES=false
```

Production uses structured JSON logs with no pretty transport. Keep production logs minimal: request completion, warnings, errors, and short important business events only. Do not log request bodies, response bodies, or every database query.

## Request ID Flow

1. The Flutter frontend should generate a UUID for each request and send it as:

   ```http
   x-request-id: <uuid>
   ```

2. The backend validates the `x-request-id` header.
3. If the header is a valid UUID, the backend uses it.
4. If the header is missing or invalid, the backend generates a new UUID with Node.js `crypto.randomUUID()`.
5. The backend returns the same request ID in every response:

   ```http
   x-request-id: <same-request-id>
   ```

6. Request and error logs include `requestId` so a single request can be traced across logs and API responses.

## Searching Logs by Request ID

Docker Linux:

```bash
docker logs masjid-backend 2>&1 | grep "request-id-here"
```

PowerShell:

```powershell
docker logs masjid-backend 2>&1 | Select-String "request-id-here"
```

## Sensitive Data Policy

Sensitive fields are redacted from logs in both development and production, including:

- `Authorization` header
- `Cookie` header
- `password`
- `passwordHash`
- `otp`
- `accessToken`
- `refreshToken`
- `token`
- `refreshTokenHash`
- `set-cookie` response header

If a debug payload is needed during development, sanitize it with `sanitizeForLog()` before logging. Do not add request body logging in production.

## Prisma Query Logging

Prisma always keeps warning/error logs available. Query logs are disabled by default and should only be enabled locally:

```env
NODE_ENV=development
PRISMA_LOG_QUERIES=true
```

Query logs are intentionally not enabled in production to keep logs cheap for small VPS deployments.

## Docker Log Rotation

Prefer Docker's `json-file` log rotation instead of storing logs in the database or writing custom log files. Add this to the backend service in `docker-compose.yml` when running with Docker Compose:

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "5"
```

This keeps logging lightweight for small VPS deployments.

# API Contracts

All paths are relative to the frontend `ApiClient` base URL, which already includes `/api/v1`.

## Response envelope
Success responses are unwrapped by the frontend from `{ success, message, data }`. Lists may be returned as either a list or `{ items, total, page, limit, totalPages }`.

## Auth
- `POST /auth/login/start` public. Body: `{ phone }`. Returns next login step and optional challenge id.
- `POST /auth/login/password` public. Body: `{ phone, password }`. Returns OTP challenge.
- `POST /auth/login/verify-otp` public. Body: `{ phone, challengeId, otp }`. Returns user and tokens.
- `POST /auth/refresh` public. Body: `{ refreshToken }`. Returns tokens.
- `POST /auth/logout` authenticated. Body: `{ refreshToken }`. Returns success.

## Masjid Request
- `POST /masjid-requests` public. Body: requester fields, masjid fields, flat `imamName`/`imamPhone`/`imamEmail`, and `committeeMembers: [{ name, phone }]`.
- `GET /masjid-requests` admin. Query: `id`, `status`, `search`, `masjidName`, `city`, `state`, `country`, `requesterPhone`, `page`, `limit`. Returns paginated request rows.
- `PATCH /masjid-requests/:id/status` admin. Body: `{ status: "APPROVED" }` or `{ status: "REJECTED", reason }`.

## Dashboard and current masjid
- `GET /dashboard/my-masjid` authenticated masjid user. Returns dashboard summary.
- `GET /masjids/my` authenticated. Returns current masjid.
- `GET /masjids/my/users` authenticated. Returns current masjid users.
- `POST /masjids/my/users` admin roles. Body: `{ fullName, phone, email?, role, masjidId? }`.
- `PATCH /masjids/my/welcome-message` admin roles. Body: `{ welcomeMsg }`.

## Namaz Time
- `GET /namaz-times/:masjidId` authenticated. Returns namaz times.
- `PUT /namaz-times/:masjidId` admin roles. Body: namaz time fields.

## Announcements
- `GET /announcements/my-masjid` authenticated. Optional list query.
- `POST /announcements/my-masjid` admin roles. Body: announcement create fields.
- `PATCH /announcements/:id` admin roles. Body: update fields.
- `DELETE /announcements/:id` admin roles.

## Finance
- `GET /finance/my-masjid/summary` authenticated.
- `GET /collections/my-masjid` authenticated. Query supports list filters when provided by UI.
- `POST /collections/my-masjid` finance roles. Body: collection create fields.
- `GET /expenses/my-masjid` authenticated. Query supports list filters when provided by UI.
- `POST /expenses/my-masjid` finance roles. Body: expense create fields.

## Projects
- `GET /projects/my-masjid` authenticated. Query: `status`, `search`, `page`, `limit` when used.
- `POST /projects/my-masjid` admin roles. Body: project create fields.
- `GET /projects/:id`, `PATCH /projects/:id`, `DELETE /projects/:id` authenticated/admin as appropriate.

## Imam Salary
- `GET /imam-salaries/my-masjid`, `POST /imam-salaries/my-masjid`, `GET /imam-salaries/:id`, `PATCH /imam-salaries/:id`, `DELETE /imam-salaries/:id` authenticated/admin as appropriate.

## Super Admin
- `GET /admin/dashboard/summary` requires `users.read`. Returns count-only dashboard totals.
- `GET /admin/users` requires `users.read`. Query: `search`, `status`, `role`, `masjidId`, `page`, `limit`.
- `GET /admin/users/:id` requires `users.read`.
- `PATCH /admin/users/:id/status` requires `users.update`. Body: `{ status }`.
- `POST /admin/users/:id/roles` requires `roles.assign`. Body: `{ roles }`.
- `GET /admin/masjids` requires `users.read`. Query: `search`, `status`, `state`, `country`, `page`, `limit`.
- `GET /admin/masjids/:id` requires `users.read`.
- `PATCH /admin/masjids/:id/status` requires `users.update`. Body: `{ status, reason? }`.

## Common errors
`UNAUTHORIZED`, `SESSION_EXPIRED`, `FORBIDDEN`, `ROLE_FORBIDDEN`, `VALIDATION_ERROR`, `PHONE_ALREADY_EXISTS`, `EMAIL_ALREADY_EXISTS`, and request/masjid not found errors are handled by the frontend error helper.

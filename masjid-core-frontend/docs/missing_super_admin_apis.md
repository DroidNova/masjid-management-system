# Missing / Unconfirmed Super Admin APIs

The Flutter UI is wired to the currently expected endpoints and handles 404/not-implemented responses with friendly messages instead of faking success.

## Connected endpoints

- `GET /api/v1/admin/users`
- `GET /api/v1/admin/users/:id`
- `PATCH /api/v1/admin/users/:id/status`
- `POST /api/v1/admin/users/:id/roles` using `{ "roles": [...] }`
- `GET /api/v1/masjid-requests`
- `PATCH /api/v1/masjid-requests/:id/status` using `{ "status": "APPROVED|REJECTED", "reason": "...", "rejectionReason": "..." }`
- `GET /api/v1/masjids`
- `GET /api/v1/masjids/:id`
- `PATCH /api/v1/masjids/:id/status`

## Needs backend confirmation

- Whether masjid admin endpoints should be `/masjids` or `/admin/masjids`. The frontend currently uses `/masjids`.
- Whether masjid status updates are available. If the backend returns 404, the UI shows “Masjid status API is not available yet.”
- Whether role assignment accepts role names (`roles`) or role IDs (`roleIds`). The existing frontend admin datasource uses `roles`, so Super Admin uses the same shape.
- No dedicated dashboard summary API was found in the frontend. The dashboard calculates summary counts from list endpoints.

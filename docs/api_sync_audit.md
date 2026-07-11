# API Sync Audit

| Feature | Frontend API Call | Backend Endpoint Exists? | Method | Request Body Match? | Response Match? | Status |
| ------- | ----------------- | ------------------------ | ------ | ------------------- | --------------- | ------ |
| Auth | `/auth/login/start` | Yes | POST | Yes | Yes | Synced |
| Auth | `/auth/login/password` | Yes | POST | Yes | Yes | Synced |
| Auth | `/auth/login/verify-otp` | Yes | POST | Yes | Yes | Synced |
| Auth | `/auth/refresh` | Yes | POST | Yes | Yes | Synced |
| Auth | `/auth/logout` | Yes | POST | Yes | Yes | Synced |
| Masjid Request | `/masjid-requests` | Yes | POST | Yes, flat imam keys supported | Yes | Synced |
| Masjid Request | `/masjid-requests` | Yes | GET | Query synced | Paginated | Synced |
| Masjid Request | `/masjid-requests/:id/status` | Yes | PATCH | `status`, `reason` | Yes | Synced |
| Dashboard | `/dashboard/my-masjid` | Yes | GET | N/A | Yes | Synced |
| Masjid | `/masjids/my` | Yes | GET | N/A | Yes | Synced |
| Masjid | `/masjids/my/users` | Yes | GET | N/A | Yes | Synced |
| Masjid | `/masjids/my/users` | Yes | POST | Yes | Yes | Synced |
| Masjid | `/masjids/my/welcome-message` | Yes | PATCH | Yes | Yes | Synced |
| Namaz Time | `/namaz-times/:masjidId` | Yes | GET | N/A | Yes | Synced |
| Namaz Time | `/namaz-times/:masjidId` | Yes | PUT | Yes | Yes | Synced |
| Announcements | `/announcements/my-masjid` | Yes | GET/POST | Yes | Yes | Synced |
| Announcements | `/announcements/:id` | Yes | PATCH/DELETE | Yes | Yes | Synced |
| Finance | `/finance/my-masjid/summary` | Yes | GET | N/A | Yes | Synced |
| Collections | `/collections/my-masjid` | Yes | GET/POST | Yes | Yes | Synced |
| Expenses | `/expenses/my-masjid` | Yes | GET/POST | Yes | Yes | Synced |
| Projects | `/projects/my-masjid` | Yes | GET/POST | Yes | Yes | Synced |
| Projects | `/projects/:id` | Yes | GET/PATCH/DELETE | Yes | Yes | Synced |
| Imam Salary | `/imam-salaries/my-masjid` | Yes | GET/POST | Yes | Yes | Synced |
| Imam Salary | `/imam-salaries/:id` | Yes | GET/PATCH/DELETE | Yes | Yes | Synced |
| Super Admin Users | `/admin/users` | Yes | GET | Query synced | Paginated | Synced |
| Super Admin Users | `/admin/users/:id` | Yes | GET | N/A | Yes | Synced |
| Super Admin Users | `/admin/users/:id/status` | Yes | PATCH | `status` | Yes | Synced |
| Super Admin Users | `/admin/users/:id/roles` | Yes | POST | `roles` | Yes | Existing contract |
| Super Admin Masjids | `/admin/masjids` | Added | GET | Query synced | Paginated | Synced |
| Super Admin Masjids | `/admin/masjids/:id` | Added | GET | N/A | Yes | Synced |
| Super Admin Masjids | `/admin/masjids/:id/status` | Added | PATCH | `status`, `reason` | Yes | Synced |
| Super Admin Dashboard | `/admin/dashboard/summary` | Added | GET | N/A | Yes | Synced |

## Missing backend APIs
None identified for active Flutter calls after this sync.

## Frontend calls that used wrong endpoint
Super Admin masjid list/detail/status now use `/admin/masjids` instead of unscoped `/masjids` routes.

## Request body mismatches
Masjid request submission now emits flat `imamName`, `imamPhone`, `imamEmail` fields while backend accepts the same contract.

## Response model mismatches
Super Admin dashboard now calls the optimized summary endpoint instead of deriving totals from multiple list endpoints.

## Query param mismatches
Admin users supports `search`, `status`, `role`, `masjidId`, `page`, and `limit`. Admin masjids supports `search`, `status`, `state`, `country`, `page`, and `limit`.

## Optimization issues
Super Admin dashboard previously made multiple list requests for counts; it now uses one count-only backend endpoint.

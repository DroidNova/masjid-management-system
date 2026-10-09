# Masjid Management System: Improvement Plan

Written 2026-10-07 after a full audit of `masjid-core` (NestJS + Prisma) and `masjid-core-frontend` (Flutter).
This file is the working plan. Each milestone is done in one or more chat sessions directly on `main`.
Update the checkboxes and the status table as work lands.

## Checkpoint (read this first in a new session)

Last updated 2026-10-09.

- **Done:** M0 to M5, plus an API audit and optimization pass (2026-10-08): fewer queries per request, race-safe money/OTP/approval writes, Prisma errors mapped to API errors, query-tuning indexes. Both apps lint, build, and test clean. CI runs on every push to `main`.
- **Next:** the UI redesign, phase by phase (`docs/UI_REDESIGN_PLAN.md`; U0 design foundation and U1 start/login screens done 2026-10-09, next U2). Deployment (M6) waits until the product is finished; then the owner decides domain and SMS provider. The VPS will be a small one.
- **App rules:** auth state lives only in `AuthController`; widgets read `currentUserProvider`/`currentPermissionsProvider`, never secure storage. Network calls go through `ApiClient` (`apiClientProvider`) and fail with `ApiException` (switch on `code`). Logging out = `authControllerProvider.notifier.signOut()`; the router redirect does the navigation.
- **Money rule:** amounts are Decimal in the database and in all arithmetic (`src/common/money.ts`); convert to numbers only in responses. Finance totals come only from `FinanceCalculator`. Every money or membership change writes an `AuditLog` entry in the same transaction.
- **Access rule:** who can do what lives only in `masjid-core/src/access/permissions.ts`. Every route needs `@RequirePermissions`; the app reads `user.permissions`. Three role decisions await owner confirmation (see section 1).
- **Database:** since 2026-10-08 the whole stack runs in Docker Compose (Postgres 18 in volume `pgdata`, backend, web frontend, optional ngrok `tunnel` profile for testing the APK and website from anywhere). The old native Postgres on localhost:5432 is no longer used. Guide: `docs/DOCKER.md`.
- **Model:** from M1 onward the owner runs sessions on Claude Opus 5.5 to save usage. Keep each session to one milestone or less.
- **How to work:** commit directly on `main`, push when green, tick the checkboxes below, update this checkpoint at the end of every session, and finish with a short plain-language summary of what changed.
- **Config rule:** all env vars are declared and validated in `masjid-core/src/config/app-config.ts`. Inject `AppConfig`; never read `process.env` in app code.
- **Query rules:** the JWT strategy loads session + user + roles in one SQL statement; services use `req.user` (masjidId, isFamilyHead, roles) instead of re-reading the user. Scope reads/writes by `{ id, masjidId }` in one query (another masjid's id is a 404, not a 403). Finance totals come from `FinanceCalculator.summary()` (one SQL statement for all-time + period). Prisma `relationJoins` is on, so nested selects are one query. Concurrent writes use conditional `updateMany` instead of read-then-write or Serializable transactions. Pool size: `DB_POOL_MAX` (default 10).
- **Known debt carried forward:** None in the app structure; see M7 for strings and UI.

## 1. What the app is

A management system for masjids in villages and cities (example: the masjid in Barota village).

- The **imam** sets namaz times and sees what concerns him.
- **Committee members** (core members) run the money side: imam salary collection per family head, projects and their contributions, collections (jumma, donation box, zakat...), expenses, and announcements.
- **Members** (villagers) see times, announcements, and their own contribution history.
- **Super admin** approves masjid registration requests and manages the platform.
- The **masjid admin** role is deliberately NOT used. Power is distributed between the imam and the committee so no single villager controls a masjid. This is a product rule, and the code must reflect it.

Deployment goal: website + Android app on Play Store (iOS maybe later), backend on a VPS.

### Owner's standing rules (2026-10-07)

- **Dev auth:** while developing, the OTP is fixed to `1111` and the default password is `12345678` (passwords are at least 8 characters). These are env-driven dev values. The real OTP generator and SMS provider are built, configured, and tested only when shipping (M6). Production refuses to start with dev auth enabled.
- **UI redesign started 2026-10-09.** The owner lifted the "no UI work" rule; the redesign plan is `docs/UI_REDESIGN_PLAN.md` (simple, visual, for low-literacy users).
- **Low budget, full features.** This is a startup with very little money. Every choice is optimised for cost: one small VPS, self-hosted Postgres, free tiers for CI, monitoring, and backups, cheap Indian SMS. Saving money never removes a feature.
- **Role matrix** (the product rule; implemented in M2):

Implemented in M2 in `masjid-core/src/access/permissions.ts` (the code is the authority; this table is a summary):

| Capability | SUPER_ADMIN | IMAM | COMMITTEE_MEMBER | MEMBER |
|---|---|---|---|---|
| Everything, every masjid, platform admin | yes | | | |
| Update namaz times | yes | yes | yes | |
| Create, edit, delete announcements | yes | yes | yes | |
| View imam salary ledger and contribution lists | yes | yes | yes | |
| Imam salary months, amounts, record payments | yes | | yes | |
| Projects, collections, expenses, record contributions | yes | | yes | |
| Edit masjid welcome message | yes | | yes | |
| Members: add villagers, edit, activate/deactivate | yes | | yes | |
| Appoint imams and committee members | yes | | | |
| See members' phone numbers and emails | yes | yes | yes | |
| Read dashboard, namaz times, announcements, finance summary, projects, member names, own contributions | yes | yes | yes | yes |
| Leave their masjid | | yes | yes | yes |

MASJID_ADMIN exists in the database but has no permissions.

Owner decisions (2026-10-08):
- Members see names only; phone numbers and emails are for the imam and committee (`members.contact.read`). A member always sees their own number.
- One phone number belongs to one masjid at a time. Adding a person who is in another masjid fails with `USER_IN_ANOTHER_MASJID` ("ask them to leave that masjid first"). Anyone can leave their masjid from the app menu (`POST /masjids/my/leave`); their imam/committee role ends and they become a plain member with no masjid until a committee adds them again. History is kept.
- Accepted without objection: committee keeps namaz times and announcements; the imam does not edit the welcome message.

- **Permissions must be easy to change.** One file holds the permission catalogue and the role-to-permission matrix. Changing who can do what means editing that file and re-seeding. The Flutter app receives the user's permission list at login and shows or hides features from it, never from role names.

## 2. Audit summary

### What is good and worth keeping

- Prisma schema: money is `Decimal(12,2)`, indexes exist, the imam salary ledger (month, assignment, payment) is modelled sensibly with Serializable transactions.
- Pino logging with request ids and redaction.
- The response envelope, exception filter, validation pipe, and Swagger skeleton.
- Docker multi-stage builds, non-root runtime, `migrate deploy` on start.
- Flutter feature folder layout and go_router are the right choices.

### Ship-blocking problems (verified)

| # | Problem | Where |
|---|---|---|
| 1 | OTP is hardcoded `111111`, SMS is never sent. Anyone with a member's phone number can log in as them. | `masjid-core/src/modules/platform-core/auth/auth.service.ts:432` |
| 2 | Every imam and committee user is created with password `12345678`, returned in the API, and there is no change or reset flow. | `masjid-requests.service.ts:25`, `masjids.service.ts:461` |
| 3 | MASJID_ADMIN gets global `users.*` permissions, so an admin of masjid A can list every user, suspend users of masjid B, and change any masjid's status. | `prisma/seed.ts:28`, `admin.controller.ts` |
| 4 | Postgres is published on host port 5433. On a VPS the database is reachable from the internet. | `docker-compose.yml:19` |
| 5 | No rate limiting or lockout on login, OTP, or the public masjid request endpoints. | whole backend |
| 6 | Release Android build has no `INTERNET` permission and is signed with the debug keystore. App id is still `com.droidnova.platform_core_frontend`. | `android/app/src/main/AndroidManifest.xml`, `build.gradle.kts:33` |
| 7 | Every Flutter feature creates its own Dio client and interceptor. Parallel 401s trigger racing token refreshes. | `core/network/api_client.dart` |
| 8 | No global route redirect. Logged-out users can open most screens until an API call fails. | `app/router.dart` |

### Architecture problems

Backend:
- Roles are **global**, not per masjid. A user belongs to one masjid via `User.masjidId` and holds a role everywhere. This is the root of the cross-masjid leaks.
- A permissions table exists but almost every controller is gated with hardcoded `@Roles(...)` lists that include MASJID_ADMIN. The product rule (distribute via permissions) is not implemented.
- OTP challenges live in process memory. Lost on restart, broken with more than one instance.
- Money is converted to JS `number` and added with float math before being written back.
- Finance summary only sums `Collection` and `Expense`, so imam salary payments and project contributions never reach it. `CollectionContribution` double-writes an unlinked `Collection` row.
- Dashboard reads the legacy `ImamSalary` model, so the salary summary is always empty. The legacy model and its DTOs are dead.
- Prisma types are discarded with `as unknown as` delegates and a `class-validator.d.ts` shim. Typos compile.
- Three different pagination envelopes. Duplicated tenant checks, number parsing, and serialisation in every service.
- No config validation, health check never touches the DB, Swagger and permissive CORS are on in production.
- Hard cascade deletes with no soft delete and no audit log on financial rows.
- Tests cover almost nothing security-relevant.

Flutter:
- Two generations of code coexist. The clean-architecture template (datasources, domain, `DioClient`, `AuthController`, `core/routing`) is **entirely dead**: 76 files, about 25% of the codebase, including everything the existing tests and `docs/architecture.md` describe.
- No state management and no DI. Every screen is a StatefulWidget that re-reads the user from secure storage, so role-gated buttons appear a frame late.
- Error handling matches on message substrings instead of the backend `errorCode`. Ten copies of the Dio error extractor, ten copies of JSON helpers, four pagination implementations.
- 35 hand-written `fromJson` models with no equality or copyWith. 31 files contain minified lines over 200 characters.
- No localisation. All strings are inline English. Hindi and Urdu will be needed.
- Web shell and manifest still carry template values. Package is still named `platform_core_frontend`.

## 3. Target architecture

### Backend (NestJS 11, Prisma 7, Postgres)

- **Tenancy:** new `MasjidMembership { userId, masjidId, role, status }` table with a unique `(userId, masjidId)`. Roles live on the membership, not on the user. `User.masjidId` and `UserRole` go away after migration. SUPER_ADMIN stays a global flag.
- **Access control:** permission based. One `permissions.ts` file declares the catalogue (`namaz.update`, `salary.month.create`, `salary.payment.record`, `project.manage`, `finance.read`, `announcement.manage`, `members.manage`, ...) and a role-to-permission matrix for IMAM, COMMITTEE_MEMBER, MEMBER. Controllers use only `@RequirePermission(...)`. MASJID_ADMIN is removed from every guard and from the seed. A `TenantGuard` resolves the active masjid from the membership and puts a `TenantContext` on the request.
- **Auth:** real OTP generated per challenge, stored hashed in an `OtpChallenge` table with expiry and attempt counter, sent through an SMS provider behind an `SmsProvider` interface (MSG91 or Fast2SMS for India, a console provider for dev). Password set on first login and reset via OTP. Refresh tokens hashed with SHA-256, session id in the JWT, reuse detection, logout-all.
- **Hardening:** `@nestjs/config` with a zod schema (fail fast on missing secrets), `@nestjs/throttler`, `helmet`, strict CORS list, Swagger only outside production, health check that pings the DB.
- **Money:** `Prisma.Decimal` end to end, no `Number()` on amounts.
- **Finance:** one `FinanceEntry` ledger that every money flow writes to (collections, expenses, salary payments, project contributions), so summaries come from one table. Soft delete (`deletedAt`) and an `AuditLog` table for financial mutations.
- **Structure:** typed Prisma client, a `BaseMasjidService` or helper set for scoping and pagination, one `PaginatedResponse<T>` shape, one error code catalogue shared with the app.

### Flutter (web + Android)

- **State and DI:** Riverpod (`flutter_riverpod`, `riverpod_annotation`). One `ProviderScope`. Providers for a single `Dio`, token storage, `AuthNotifier` holding `AuthState` in memory, one repository per feature, `AsyncNotifier` per screen. `ref.invalidate` replaces the refresh bus and the request coordinator.
- **Router:** one `GoRouter` with `redirect` driven by `AuthNotifier` through `refreshListenable`, `StatefulShellRoute.indexedStack` for both shells, typed routes via `go_router_builder` so web refresh keeps working.
- **Network:** single `ApiClient` with one interceptor that holds a refresh lock. One `ApiEnvelope<T>` and one `ApiException { code, message, status, fieldErrors }`. UI switches on `code`, never on text.
- **Models:** `freezed` + `json_serializable` with shared converters for money and dates.
- **Localisation:** `flutter_localizations` + ARB files from the start of the refactor (en now, hi and ur later).
- **Permissions in UI:** the app reads `permissions` from the login response and gates widgets on permission names, not role names. Same catalogue as the backend.
- **Environments:** `--dart-define-from-file` with `env/dev.json`, `env/staging.json`, `env/prod.json`.

### Infrastructure

Budget target: roughly 400 to 600 INR per month total until there is real traffic.

- One small VPS (2 vCPU, 2 to 4 GB RAM, Hetzner or a cheap Indian provider) runs `docker compose` with Postgres (internal network only), the API, and Caddy as reverse proxy with free automatic TLS. Caddy also serves the Flutter web build. No managed database, no separate hosting for the website.
- Keep memory low: single API container, Node in production mode, Postgres tuned for 1 GB, Flutter web built with `--release` and served with long cache headers.
- Nightly `pg_dump` to Backblaze B2 or Cloudflare R2 (both have a free tier that covers this database for years). Restore tested once.
- GitHub Actions free tier for lint, test, build, and the deploy over SSH on a tag. Keep workflows short so free minutes last.
- Sentry free tier for error reporting on backend and app. UptimeRobot free tier for uptime checks.
- SMS: cheapest Indian transactional provider at ship time (Fast2SMS or MSG91, roughly 0.15 to 0.25 INR per OTP). Resend cooldown and attempt limits keep the bill small.
- Android App Bundle built with a real upload keystore kept outside the repo. Play Console one-time fee is the only platform cost.

## 4. Milestones

Order matters. M1 and M2 remove the security holes and must land before anything is exposed to real users. M4 and M5 are the Flutter rewrite. M6 is deployment.

### M0: Hygiene and guardrails

Goal: make the repo honest and give every later milestone a safety net.

- [x] Delete the 76 dead Flutter files, the dead backend files (`GlobalExceptionFilter`, `sanitizeForLog`, `pagination.util`, `LoginDto`, `RegisterDto`, legacy `ImamSalary` DTOs), and `src/types/class-validator.d.ts`.
- [x] Rename the Flutter package to `masjid_core_frontend`, app id `com.droidnova.masjid_core`, label "Masjid Core", web title and manifest.
- [x] `dart format` on everything, `dart fix`, tightened `flutter_lints` rules in `analysis_options.yaml`. Analyzer is clean.
- [x] Backend: ESLint and Prettier run clean. `ts-node` and `typescript` moved to dev dependencies (`prisma` stays: the container runs `migrate deploy`). `.env` load order fixed in `main.ts`.
  - The `no-unsafe-*` ESLint rules are downgraded to warnings (about 200) until M3 replaces the untyped Prisma delegates. Raise them back to errors in M3.
- [x] Deleted all `docs/` files that described the dead code generation, and the tests that tested dead code. Added a `PermissionHelper` test so the Flutter test job has live coverage.
- [x] Rewrote `README.md`.
- [x] GitHub Actions workflow `.github/workflows/ci.yml`: backend lint, format, build, test; Flutter format, analyze, test, web build.
- [x] `src/generated/prisma` is no longer committed. `prisma generate` runs before `build`, `start:dev`, and `test`, and in the Docker build stage.

Done when: CI is green on `main`, no dead files, both apps build.

### M1: Backend security foundation

Goal: real authentication and basic hardening.

- [x] Typed `AppConfig` validated with zod (`src/config/app-config.ts`); `@nestjs/config` was not needed. Refuses to start on missing values, secrets under 16 chars (32 in staging/production), or identical access/refresh secrets.
- [x] `helmet`, `@nestjs/throttler` (limits in `src/common/rate-limit/rate-limit.ts`; `RATE_LIMIT_ENABLED=false` turns them off), CORS list required in staging/production, Swagger off by default in production, `TRUST_PROXY` for running behind Caddy.
- [x] `OtpChallenge` table replacing the in-memory map (challenge id, phone, hashed code, expiry, attempts). In dev mode the code is always `AUTH_DEV_OTP` (default `1111`); the real random generator and SMS sending are wired in M6.
- [x] `AUTH_DEV_MODE` (default on outside production), `AUTH_DEV_OTP=1111`, `AUTH_DEV_PASSWORD=12345678`. Production fails to start with dev mode on, and also without it until M6 (no SMS provider yet). Server returns `otpLength` so the app asks for 4 digits.
- [x] Replace the hardcoded `TEMPORARY_USER_PASSWORD` with `AUTH_DEV_PASSWORD`. Add `auth/password/change` now so users can move off the default. `mustSetPassword` on first login and OTP-based reset are added in M6 with real OTP.
- [x] Refresh token rework: SHA-256 hash, session id in JWT, rotate with reuse detection (`SESSION_REVOKED`), `auth/logout-all`, hourly cleanup of expired sessions and OTP rows. Access tokens are checked against their session on every request, so logout takes effect immediately.
- [x] Set `isPhoneVerified=true` after OTP success. Stop logging raw phone numbers (also redacted from request logs).
- [x] Health endpoint checks the DB (503 when unreachable).
- [x] Tests: config rules, OTP flow, password flow, refresh rotation and reuse, logout-all, password change, cleanup, throttling (34 new backend tests, 2 app tests).
- [x] Extra: `npm run dev:reset-passwords` resets existing imam/committee passwords to the dev password (refuses without dev mode). Local `docker-compose.yml` now runs the backend with `NODE_ENV=development`.

Done when: dev auth is explicit and env-driven, challenges survive a restart, and production cannot start with dev auth on.

### M2: Access model and tenancy

Goal: implement the product rule. Power is distributed by permissions, scoped per masjid.

- [ ] Deferred: `MasjidMembership` table. Every user belongs to exactly one masjid today, so roles held globally equal roles in that masjid, and the cross-masjid leaks came from MASJID_ADMIN's global admin rights (fixed below). The table only adds value once one person must belong to two masjids, and it touches every service. Do it when that need is real.
- [x] Permission catalogue and role matrix in one file, `src/access/permissions.ts`. The API derives permissions from it at runtime (no database lookup; a restart applies changes). `npm run prisma:seed` copies it into the Permission tables for reference. Login and `auth/me` return the list. Super admin simply holds every permission.
- [x] Every route uses `@RequirePermissions(...)` (`src/access/require-permissions.ts`). Old `@Roles`, `RolesGuard`, `@Permissions` and the unused users/sessions/settings/permissions stub modules are deleted. MASJID_ADMIN has no permissions. A test fails if any new route forgets a permission.
- [x] Every endpoint audited against the matrix and checked live on the local database as member, imam and committee member.
- [ ] Deferred to M3 with the service refactor: `TenantContext` helper. Services already take the masjid id from the signed-in user (audited, no leak found); M3 replaces the eight copies of that lookup with one helper.
- [x] Admin endpoints need `platform.*` permissions, which only SUPER_ADMIN has. Only IMAM, COMMITTEE_MEMBER and MEMBER can be assigned; assignment is transactional and logged.
- [x] MEMBER keeps today's read access, listed explicitly as `EVERYONE` in the permissions file. Imam salary "my history" now uses `own_contributions.read`, so imams and committee members can see their own payments too.
- [x] Admin masjid list and status update use validated DTOs; user list filters are validated (status enum, known role, UUID).
- [x] Tests: role matrix, route coverage, guard behaviour, admin rules (16 new backend tests); app permission helper tests. Cross-masjid isolation is not covered by automated tests yet (needs a test database; planned with M7 e2e tests).
- [x] App: every show/hide decision reads `user.permissions` (`PermissionHelper` + `AppPermissions`), not role names. The super admin role dialog offers only assignable roles.

Done when: the role matrix in code matches the product rule and the tenancy tests pass.

### M3: Backend data and code structure

Goal: correct money handling and a codebase that is pleasant to extend.

- [x] Money math uses `Prisma.Decimal` through `src/common/money.ts` (`money`, `sumMoney`, `toAmount`). Responses return plain numbers; imam salary amounts used to be strings and are now numbers like everywhere else.
- [x] Typed Prisma client everywhere; delegate types and `as unknown as` casts deleted. `no-unsafe-*` lint rules are errors again for app code (relaxed only in specs).
- [x] Changed approach: no separate ledger table. `FinanceCalculator` (finance module) sums every source of money in (collections, project contributions, imam-salary payments) and expenses, and both the finance screen and the dashboard use it, so they always agree. The response keeps the old field names (`totalCollection` now means all money received) and adds a `breakdown`. The `CollectionContribution` → `Collection` double write is kept on purpose: it is how a contribution shows up in the collections list.
- [x] Legacy `ImamSalary` table dropped (it was empty). The dashboard salary card reads the latest `ImamSalaryMonth` (it was always empty before).
- [x] `AuditLog` table: every create, update and cancel of money records, salary months and payments, member joins, edits, status changes and leaves, masjid approvals and admin changes are recorded with who, what, before and after, in the same transaction. Readable at `GET /audit-log/my-masjid` with `audit.read` (imam and committee). Soft delete already exists as CANCELLED status on collections, expenses and projects; nothing is hard-deleted by the API.
- [x] Shared tenant helpers (`src/common/tenant.ts`) and money helpers. DTO transforms are typed.
- [ ] Deferred to M4/M5: one pagination envelope and the imam salary error codes (salary errors still report `BAD_REQUEST` for 404/409). The app parses today's shapes, so these change together with the app rework. DTO enums duplicating Prisma enums also move then.
- [x] Composite indexes for collection, expense, announcement and contribution lists; index on `MasjidRegistrationRequest.requesterPhone`. Phones are already normalised on write by the services.
- [x] Done in M2: permissions come from code, the per-request query only loads role names and the session.
- [x] Both services shrank by about a third; select objects and response types moved to `*.selects.ts`.
- [x] Salary and contribution DTOs documented. `npm run openapi` writes `docs/openapi.json` (committed) for the app rework.
- [x] Tests: salary ledger math, finance calculator, money helpers, one-masjid rule, audit entries. An end-to-end scenario on a throwaway database (two masjids, every write flow, every read per role) was diffed before and after the refactor: identical except salary amounts turning from strings into numbers.
- [x] Also fixed: approving a masjid request no longer silently moves an imam or committee member out of another masjid (`USER_IN_ANOTHER_MASJID`), and committee members' father name, age and gender from the request form are no longer dropped.

Done when: sums in the finance summary equal the sum of ledger entries and every service compiles against real Prisma types.

### M4: Flutter foundation

Goal: one architecture, one network client, one auth state.

- [x] Added Riverpod (2.6, plain providers, no generator), freezed, json_serializable, flutter_localizations, intl, mocktail. `AppUser` is the reference freezed model; regenerate with `dart run build_runner build --delete-conflicting-outputs` (generated files are committed).
- [ ] Deferred to M5: `go_router_builder` typed routes. They only pay off once each screen loads its own data by id, which is M5 work; until then a few routes still pass models through `extra`.
- [x] One shared `ApiClient` (configured in `main.dart`, `apiClientProvider`; old `ApiClient()` calls get the same instance). The interceptor refreshes once for any number of parallel 401s, and a network failure during refresh no longer logs the user out.
- [x] `ApiException { message, code, statusCode, fieldErrors }` built once from the error envelope; `ApiClient.get/post/...` return the `data` field. New code switches on `code`.
- [ ] Deferred to M5: delete the per-feature error extractors and `error_message_helper.dart` as each feature moves to `ApiClient.get/post`.
- [x] `AuthController` (`features/auth/application`) with `AuthUnknown / AuthSignedOut / AuthSignedIn(user)`, hydrated once at startup and refreshed from `/auth/me` in the background. `currentUserProvider` and `currentPermissionsProvider` for widgets. Android secure storage uses EncryptedSharedPreferences (Android users log in once more after this update).
- [x] Router (`routerProvider`): one `authRedirect` function (unit tested) driven by the auth state; deep links survive the startup check; `StatefulShellRoute` for both shells so tabs keep their state; permission requirements on routes through `PermissionGate`.
- [x] `PermissionGate` widget; `PermissionHelper` reads permissions (done in M2).
- [x] No visual redesign. Visible changes: money shows Indian grouping with paise (₹12,34,567.50), a "session expired" snack bar, and a loading message on the web while the app downloads.
- [x] Localisation scaffold (`l10n.yaml`, `lib/l10n/app_en.arb`, used by splash and dashboard). `AppFormat` (`core/format`) for rupees and dates in `en_IN`.
- [x] `env/dev.json`, `dev-android-emulator.json`, `staging.json`, `prod.json` for `--dart-define-from-file`. The web Docker image takes `APP_ENV` (and optional `API_BASE_URL` override). Staging and prod URLs are placeholders until M6.
- [x] Android release: `key.properties` signing (falls back to the debug key when absent; template in `android/key.properties.example`), `INTERNET` permission in the main manifest, R8 shrinking. App id and name done in M0; a real icon comes with the UI work.
- [x] Web: title, description, manifest, theme colour, landscape allowed (M0), loading message until the first frame.
- [x] Dashboard migrated as the reference screen: `DashboardController` (AsyncNotifier) + `ConsumerWidget`, errors by code (the "not assigned to a masjid" message no longer triggers on any error mentioning "masjid").
- [x] Verified: 38 app tests (redirect rules, auth controller, interceptor refresh lock and offline case, error mapping, dashboard states, formatters); a live run against the local backend logged in with OTP 1111, survived a corrupted access token with a single refresh, and signed out with "session expired" after the server revoked the session.

Done when: login, logout, token refresh, and redirects work end to end through the new stack and one screen (dashboard) is migrated.

### M5: Flutter feature migration

Goal: move each feature to the new stack. Done in one session (2026-10-08) with five parallel agents, each owning separate feature folders, following `docs/APP_ARCHITECTURE.md`.

- [x] Dashboard (M4 reference)
- [x] Namaz times
- [x] Announcements (new backend `GET /announcements/:id` so edit works from a fresh URL)
- [x] Community (members): phone/email hidden for members, USER_IN_ANOTHER_MASJID / MASJID_USER_ALREADY_LINKED shown clearly, leave-masjid menu
- [x] Finance: summary with the new breakdown rows, paged collections and expenses with a type filter, cancel by long-press (committee only)
- [x] Projects and project contributions (detail and edit load by id)
- [x] Collection contributions and "my contributions"
- [x] Imam salary ledger: minified screen rewritten into readable widgets and controllers; payment and amount validation in one place (compared in paise); disposed dialog controllers; errors with retry on every list
- [x] Super admin (requests, masjids, users) on the real contract; key guessing removed; approval shows USER_IN_ANOTHER_MASJID; user detail now includes the masjid (backend)
- [x] Masjid registration request and tracking: the 633-line form split into sections, validation and submission in a controller
- [x] Login screens on `authRepositoryProvider`; errors by code (rate limit, wrong OTP, expired OTP offers a new one)
- [x] Backend: one pagination envelope `{ items, meta: { page, limit, total, totalPages, hasNextPage } }` everywhere; imam salary errors carry real codes
- [x] Deleted: refresh bus, request coordinator, text-matching error helper, old pagination helpers, role helper, per-feature Dio error extractors. `Page` renamed `PageResult` (clashed with Flutter's `Page`).
- [x] 173 app tests (was 38). A live run of every repository against the backend on the scenario database matched the backend numbers and error codes.
- [ ] Moved to M7: strings into ARB files. They are extracted together with the Hindi/Urdu translation and the UI redesign, so screens are not edited twice.
- [ ] Not done on purpose: `go_router_builder`. Every detail route now loads by id from its path, which was the problem typed routes would have solved.

Small UI additions agents made beyond wiring (no redesign): finance type filter and long-press cancel, imam month picker on the salary screen, a "Request new OTP" action, Indian date and money formats everywhere.


### M6: Deployment

Goal: the backend on a VPS, the website live, the app on the Play Store.

- [ ] Real OTP: random 6-digit code per challenge, hashed in `OtpChallenge`, resend cooldown. `SmsProvider` interface with a console implementation for dev and an Indian provider (MSG91 or Fast2SMS) for prod. Decision needed then: which provider.
- [ ] `mustSetPassword` on first login and OTP-verified password reset. Turn `AUTH_DEV_MODE` off and test the full flow on staging with real SMS.
- [ ] Production `docker-compose.prod.yml`: Postgres on the internal network only, API, Caddy with automatic TLS serving the API under `/api` and the Flutter web build at `/`.
- [ ] Secrets in a server-side `.env` not in git. Document the server setup in `docs/DEPLOY.md`.
- [ ] Nightly `pg_dump` to object storage (Backblaze B2 or similar). Test a restore once.
- [ ] GitHub Actions deploy job: on tag, build images, SSH to the VPS, pull, `migrate deploy`, restart.
- [ ] Staging environment (can be the same VPS on a subdomain) for testing with real SMS.
- [ ] Play Store: upload keystore, app bundle build, listing, privacy policy page, data safety form, internal testing track first.
- [ ] Uptime monitoring and error reporting (Sentry for both backend and app).

Done when: a tagged release reaches the VPS without manual steps and the app is on the internal testing track.

### M7: Quality and polish

- [ ] Hindi and Urdu translations (Urdu needs RTL checks on every screen).
- [ ] Backend e2e tests against a disposable Postgres in CI.
- [ ] Performance pass: list query plans, payload sizes, app startup time.
- [ ] Offline tolerance for namaz times and announcements (cache last response).
- [ ] Feature ideas parked until here: push notifications for announcements, PDF or Excel export of ledgers, multi-masjid membership for one user.

## 5. Decisions needed from the owner

Answered on 2026-10-07: dev OTP `1111` and password `12345678` until shipping; members keep today's access; no UI work until the end.

Still open:

1. Can one person be a member of two masjids? The membership table allows it. Recommended: allow, but the app shows one active masjid at a time. Affects M2 and M4.
2. Keep the generated Prisma client in git or generate on install. Recommended: generate. Affects M0.
3. SMS provider for OTP (MSG91, Fast2SMS, or Twilio). Needed only at M6.
4. Domain name and VPS provider. Affects M6.

## 6. Status

| Milestone | Status | Notes |
|---|---|---|
| M0 Hygiene | done 2026-10-07 | commit `301c235`; `no-unsafe-*` lint rules are warnings until M3 |
| M1 Backend security | done 2026-10-07 | migrations applied and login flows verified on the local DB |
| M2 Access model | done 2026-10-07 | membership table and tenant helper deferred (see M2 notes) |
| M3 Backend structure | done 2026-10-08 | pagination envelope and salary error codes deferred to M4/M5 |
| M4 Flutter foundation | done 2026-10-08 | typed routes and per-feature error cleanup move to M5 |
| M5 Flutter features | done 2026-10-08 | ARB string extraction moved to M7 |
| M6 Deployment | deferred | after the product is finished; small VPS; domain and SMS provider decided then |
| M7 Polish | not started | |

# Masjid Management System: Improvement Plan

Written 2026-10-07 after a full audit of `masjid-core` (NestJS + Prisma) and `masjid-core-frontend` (Flutter).
This file is the working plan. Each milestone is done in one or more chat sessions directly on `main`.
Update the checkboxes and the status table as work lands.

## 1. What the app is

A management system for masjids in villages and cities (example: the masjid in Barota village).

- The **imam** sets namaz times and sees what concerns him.
- **Committee members** (core members) run the money side: imam salary collection per family head, projects and their contributions, collections (jumma, donation box, zakat...), expenses, and announcements.
- **Members** (villagers) see times, announcements, and their own contribution history.
- **Super admin** approves masjid registration requests and manages the platform.
- The **masjid admin** role is deliberately NOT used. Power is distributed between the imam and the committee so no single villager controls a masjid. This is a product rule, and the code must reflect it.

Deployment goal: website + Android app on Play Store (iOS maybe later), backend on a VPS.

### Owner's standing rules (2026-10-07)

- **Dev auth:** while developing, the OTP is fixed to `1111` and the default password is `123456`. These are env-driven dev values. The real OTP generator and SMS provider are built, configured, and tested only when shipping (M6). Production refuses to start with dev auth enabled.
- **No UI work now.** Functionality first. Visual polish of the Flutter app happens at the end.
- **Role matrix** (the product rule; implemented in M2):

| Capability | SUPER_ADMIN | IMAM | COMMITTEE_MEMBER | MEMBER |
|---|---|---|---|---|
| Everything, every masjid | yes | | | |
| Update namaz times | yes | yes | | |
| Create, edit, delete announcements | yes | yes | | |
| Imam salary months, assignments, record payments | yes | | yes | |
| Projects and project contributions | yes | | yes | |
| Collections, expenses, finance summary | yes | | yes | |
| Members: add, edit, status | yes | | yes | |
| Everything else the app already provides to committee | yes | | yes | |
| Read namaz times, announcements, own contributions, and whatever members can see today | yes | yes | yes | yes |

MASJID_ADMIN is not assigned to anyone and appears in no guard.

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

- VPS runs `docker compose` with Postgres (internal network only), the API, and Caddy as reverse proxy with automatic TLS. Caddy also serves the Flutter web build.
- Nightly `pg_dump` to off-server storage. Restore tested once.
- GitHub Actions: lint, test, and build on every push to `main`. Deploy to the VPS over SSH on a tag.
- Android App Bundle built with a real upload keystore kept outside the repo.

## 4. Milestones

Order matters. M1 and M2 remove the security holes and must land before anything is exposed to real users. M4 and M5 are the Flutter rewrite. M6 is deployment.

### M0: Hygiene and guardrails

Goal: make the repo honest and give every later milestone a safety net.

- [ ] Delete the 76 dead Flutter files, the dead backend files (`GlobalExceptionFilter`, `sanitizeForLog`, `pagination.util`, `LoginDto`, `RegisterDto`, legacy `ImamSalary` DTOs), and `src/types/class-validator.d.ts`.
- [ ] Rename the Flutter package to `masjid_core_frontend`, fix pubspec, imports, Android app id, label, web title and manifest.
- [ ] Run `dart format` on everything, replace the stock `analysis_options.yaml` with `very_good_analysis` or a tightened `flutter_lints`.
- [ ] Backend: ESLint and Prettier run clean. Remove `prisma`, `ts-node`, `typescript` from prod dependencies. Fix the `.env` load order bug in `app.module.ts`.
- [ ] Delete `docs/architecture.md`, `docs/module-conventions.md`, `docs/api_contracts.md`, `docs/api_sync_audit.md`, `docs/missing_super_admin_apis.md` (they describe dead code) and the tests that test dead code.
- [ ] Rewrite `README.md` for this project (not "Platform Core").
- [ ] GitHub Actions workflow: backend lint + unit tests, Flutter analyze + format check + test.
- [ ] Decide whether to keep `src/generated/prisma` committed or generate on install (recommended: ignore it and run `prisma generate` in `postinstall` and in Docker).

Done when: CI is green on `main`, no dead files, both apps build.

### M1: Backend security foundation

Goal: real authentication and basic hardening.

- [ ] `@nestjs/config` with a zod-validated schema. App refuses to start on missing or short secrets.
- [ ] `helmet`, `@nestjs/throttler` (tight limits on `auth/*` and `masjid-requests/*`), strict CORS from env, Swagger disabled when `NODE_ENV=production`.
- [ ] `OtpChallenge` table replacing the in-memory map (challenge id, phone, hashed code, expiry, attempts). In dev mode the code is always `AUTH_DEV_OTP` (default `1111`); the real random generator and SMS sending are wired in M6.
- [ ] `AuthConfig` with `AUTH_DEV_MODE`, `AUTH_DEV_OTP=1111`, `AUTH_DEV_PASSWORD=123456`. Production startup fails if dev mode is on.
- [ ] Replace the hardcoded `TEMPORARY_USER_PASSWORD` with `AUTH_DEV_PASSWORD`. Add `auth/password/change` now so users can move off the default. `mustSetPassword` on first login and OTP-based reset are added in M6 with real OTP.
- [ ] Refresh token rework: SHA-256 hash, session id in JWT, rotate with reuse detection, `auth/logout-all`, expired session cleanup job.
- [ ] Set `isPhoneVerified=true` after OTP success. Stop logging raw phone numbers.
- [ ] Health endpoint checks the DB.
- [ ] Tests: OTP flow, password flow, refresh rotation, throttling.

Done when: dev auth is explicit and env-driven, challenges survive a restart, and production cannot start with dev auth on.

### M2: Access model and tenancy

Goal: implement the product rule. Power is distributed by permissions, scoped per masjid.

- [ ] Add `MasjidMembership` and migrate existing `User.masjidId` + `UserRole` data into it. Then drop the old columns.
- [ ] Write the permission catalogue and role matrix in one file, `src/access/permissions.ts`, following the table in section 1. Seed from it. Permissions are returned in the login response and in `auth/me`. Super admin bypasses all checks.
- [ ] Replace every `@Roles(...)` on masjid-core controllers with `@RequirePermission(...)`. Remove MASJID_ADMIN from guards and seed.
- [ ] Audit every existing endpoint against the matrix: imam gets namaz times and announcements only, committee gets everything else, member keeps today's read access.
- [ ] `TenantGuard` + `TenantContext`. Services take the masjid id from the context, never from the body or query.
- [ ] Scope admin endpoints: only SUPER_ADMIN can list all users, change masjid status, or assign roles. Role assignment is transactional.
- [ ] MEMBER keeps exactly what the current app gives members. Write that list down in the permissions file so it is explicit.
- [ ] Fix untyped `@Query` and `@Body` in admin controller. All DTOs validated.
- [ ] Tests: a user of masjid A can never read or write masjid B's rows, member cannot call committee endpoints, imam cannot record money.

Done when: the role matrix in code matches the product rule and the tenancy tests pass.

### M3: Backend data and code structure

Goal: correct money handling and a codebase that is pleasant to extend.

- [ ] `Prisma.Decimal` everywhere. Delete all `toNumber` helpers.
- [ ] Typed Prisma client. Delete every `as unknown as` delegate and the hand-written delegate types.
- [ ] `FinanceEntry` ledger table. Salary payments, project contributions, collections, and expenses each write one entry. Finance summary and dashboard read from it. Remove the `CollectionContribution` double write.
- [ ] Drop legacy `ImamSalary` model. Fix the dashboard salary summary to read `ImamSalaryMonth`.
- [ ] Soft delete on financial tables and `AuditLog` (who, what, before, after) for create, update, cancel of money rows.
- [ ] Shared helpers: tenant scoping, one `PaginatedResponse<T>`, one error code enum, `trimString` transformer, Prisma enums reused in DTOs.
- [ ] Add composite indexes for list queries and an index on `MasjidRegistrationRequest.requesterPhone`. Canonical phone format enforced on write.
- [ ] Cache role and permission lookup per request or per short TTL instead of a 4-level include on every call.
- [ ] Split `masjids.service.ts` and `masjid-requests.service.ts`.
- [ ] Swagger complete for every endpoint. Export the OpenAPI JSON as a build artefact for the app.
- [ ] Tests for the salary ledger and finance ledger math.

Done when: sums in the finance summary equal the sum of ledger entries and every service compiles against real Prisma types.

### M4: Flutter foundation

Goal: one architecture, one network client, one auth state.

- [ ] Add Riverpod, freezed, json_serializable, go_router_builder, flutter_localizations, intl, mocktail.
- [ ] Single `Dio` provider and one interceptor with a refresh lock. Port the refresh lock idea from the dead `interceptors/auth_interceptor.dart` before deleting it.
- [ ] `ApiEnvelope<T>`, `ApiException` with `code`, mapped once. Delete all per-feature error extractors and `error_message_helper.dart`.
- [ ] `AuthNotifier` with `AuthState { unknown, signedOut, signedIn(user, permissions) }`, hydrated once at startup. Secure storage with `encryptedSharedPreferences` on Android.
- [ ] Router: global `redirect`, `StatefulShellRoute` for the member shell and the super admin shell, typed routes, role and permission requirements declared per route.
- [ ] `PermissionGate` widget and `hasPermission` helper replacing `PermissionHelper` role checks. Permission names come from the login response. The app never branches on role names except to pick the super admin shell.
- [ ] No visual redesign in this milestone or M5. Keep existing screens and widgets, change only the data and state wiring.
- [ ] Localisation scaffold with `l10n.yaml` and `app_en.arb`. Money and date formatting via `intl` with `en_IN`.
- [ ] Environment files for dev, staging, prod. Docker image takes the URL at build time from the prod file.
- [ ] Android release: upload keystore via `key.properties` (ignored), `INTERNET` permission in main manifest, R8 enabled, real app id, icon, and name.
- [ ] Web: title, description, manifest, theme colour, landscape allowed, loading splash.

Done when: login, logout, token refresh, and redirects work end to end through the new stack and one screen (dashboard) is migrated.

### M5: Flutter feature migration

Goal: move each feature to the new stack. One feature per session, in this order, smallest first so the pattern settles early.

- [ ] Dashboard
- [ ] Namaz times
- [ ] Announcements
- [ ] Community (members)
- [ ] Finance (collections, expenses, summary)
- [ ] Projects and project contributions
- [ ] Collection contributions and "my contributions"
- [ ] Imam salary ledger (rewrite the minified screen, move validation such as "payment must not exceed due" out of dialogs)
- [ ] Super admin (requests, masjids, users) with pinned response contracts, no key guessing
- [ ] Masjid registration request and tracking (split the 633-line form)

For each feature: freezed models, repository provider, AsyncNotifier, strings in ARB, loading, empty, and error states with retry, permission-gated actions, widget test for the main screen. Existing look and feel is kept as is.

Done when: no `setState`-driven data loading remains and `features/` has one pattern.

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

Answered on 2026-10-07: dev OTP `1111` and password `123456` until shipping; members keep today's access; no UI work until the end.

Still open:

1. Can one person be a member of two masjids? The membership table allows it. Recommended: allow, but the app shows one active masjid at a time. Affects M2 and M4.
2. Keep the generated Prisma client in git or generate on install. Recommended: generate. Affects M0.
3. SMS provider for OTP (MSG91, Fast2SMS, or Twilio). Needed only at M6.
4. Domain name and VPS provider. Affects M6.

## 6. Status

| Milestone | Status | Notes |
|---|---|---|
| M0 Hygiene | not started | |
| M1 Backend security | not started | |
| M2 Access model | not started | |
| M3 Backend structure | not started | |
| M4 Flutter foundation | not started | |
| M5 Flutter features | not started | |
| M6 Deployment | not started | |
| M7 Polish | not started | |

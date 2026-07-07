# platform-core-frontend

Frontend foundation for the **Platform Core** ecosystem.

This repository is the **generic platform-layer frontend** (Android, iOS, Web) that aligns with the current `platform-core` backend. It is intentionally designed to be cloned/extended into:

1. `edutech-core-frontend` (domain extension layer), then
2. client-specific product frontends (branding + product customization layer).

---


## Clone Intent

> This project is intended to be cloned and extended (not rewritten in-place) for domain and client layers.

## Current Scope

### In scope now
- App bootstrap and shared services wiring
- Auth/session foundations (login, register, splash restore, logout)
- Protected routing/shell structure
- Admin user management (list/detail/status/roles)
- Shared API/result/pagination/list-query patterns
- Reusable UI patterns for list and state handling

### Intentionally out of scope now
- Edutech domain features (institutes, students, teachers, batches, courses, dashboards)
- Client-specific branding and product-specific UX flows
- Large analytics/reporting systems
- Full permissions-management UI surface

---

## Backend Alignment (Current Truth)

- Backend currently aligned: **`platform-core`**
- Backend contract is source of truth
- Frontend currently aligns with platform modules:
  - auth
  - users
  - roles
  - permissions
  - sessions
  - admin
  - settings/basic platform foundation
  - health/basic status foundation

When backend contracts change, frontend integration must be updated in lockstep.

---

## Tech Targets

- Flutter targets:
  - Android
  - iOS
  - Web

---

## Local Setup

## Prerequisites
- Flutter SDK (stable channel)
- Dart SDK (bundled with Flutter)
- Platform toolchains as needed (Android Studio/Xcode)

## Run locally
```bash
flutter pub get
flutter run -d chrome
```

Examples for device-specific runs:
```bash
flutter run -d android
flutter run -d ios
```

## Tests
```bash
flutter test
```

---

## High-level Structure

```text
lib/
  app/        # App bootstrap and top-level app wiring
  core/       # Infrastructure: config, network, routing, storage, errors
  shared/     # Reusable UI/models/helpers used across features
  features/   # Platform business modules (auth, admin, profile, settings, ...)
```

Feature modules follow layered separation:
- `presentation/` (UI, controllers/state)
- `domain/` (entities + repository contracts)
- `data/` (datasources, API models, repository impl)

---

## Architectural Direction

- Keep the base repo **platform-generic** and backend-aligned
- Avoid introducing edutech/client assumptions into base modules
- Introduce reusable abstractions only where repetition is real
- Prefer explicit API model -> domain entity mapping in repositories

---

## Clone / Extension Direction

- Base (`platform-core-frontend`) stays generic and reusable
- Edutech clone adds only edutech-specific feature modules
- Client product layers add branding and client workflow choices

See detailed strategy in [`docs/clone-strategy.md`](docs/clone-strategy.md).

---

## Documentation Index

- [Architecture](docs/architecture.md)
- [Module Conventions](docs/module-conventions.md)
- [API Sync Rules](docs/api-sync-rules.md)
- [Clone Strategy](docs/clone-strategy.md)
- [Frontend Development Checklist](docs/frontend-development-checklist.md)

# Architecture

## 1) Purpose

This frontend is the generic platform UI layer for `platform-core`. It is built to remain stable and reusable while future domain layers (like `edutech-core-frontend`) extend it without polluting the base.

---

## 2) High-level Design

```text
UI (Pages/Widgets)
  -> Presentation (Controller/State)
  -> Domain (Entities + Repository Contracts)
  -> Data (Repository Impl + Datasource + API Models)
  -> Network (DioClient + Interceptors)
```

### Why this separation
- Keeps UI independent of backend payload details
- Makes backend change impact localized (mostly in data/model layers)
- Keeps feature slices testable and clone-friendly

---

## 3) Folder Roles

## `app/`
Top-level app composition:
- app widget
- bootstrap/services initialization

## `core/`
Technical infrastructure shared across all modules:
- config
- network client/interceptors
- routing
- storage
- errors and result primitives

## `shared/`
Reusable cross-feature building blocks:
- generic models/types (pagination/query)
- shared widgets (list toolbar/state/pagination)

## `features/`
Platform business modules only:
- auth
- admin
- profile
- settings/basic platform sections

Each feature should keep `presentation/domain/data` boundaries.

---

## 4) Layer Responsibilities

| Layer | Responsibility | Must Not Do |
|---|---|---|
| presentation | UI state orchestration and user interactions | Parse raw backend payloads directly |
| domain | Stable business contracts/entities | Depend on Dio or backend JSON shapes |
| data | API calls, DTO parsing, mapping to domain | Leak raw DTO complexity to UI |

---

## 5) Networking + Token Flow (High-level)

1. `DioClient` applies base config and interceptors.
2. Access token is attached for protected calls.
3. On `401`, refresh flow is attempted (once) when applicable.
4. If refresh fails, local session is cleared and auth state is reset.

Rules:
- Bearer token for protected endpoints
- Refresh logic should avoid infinite retry loops
- Backend remains final authority on access decisions

---

## 6) Routing (High-level)

Current routes are centralized in core routing:
- public auth routes (`/login`, `/register`)
- root splash (`/`)
- protected routes (`/home`, `/profile`, admin routes)

Route shaping is frontend convenience; backend access control is still authoritative.

---

## 7) Protected Shell

A protected shell provides common authenticated layout/navigation patterns and keeps protected screens consistent. Feature pages render inside this shell instead of duplicating layout structure.

---

## 8) Generic Base vs Future Layers

### Base (`platform-core-frontend`)
- Generic platform features
- Shared infrastructure
- No domain-specific assumptions

### Future edutech layer
- Adds education domain modules only
- Keeps base architecture intact

### Future client layer
- Branding, feature toggles, client-specific flows
- Avoid back-porting client-specific behavior into base


# Module Conventions

## 1) Standard Feature Shape

```text
features/<feature>/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
  presentation/
    controllers/
    state/
    pages/
    widgets/
```

Use this unless there is a clear reason not to.

---

## 2) Naming Conventions

- Entity: `XxxEntity` only when disambiguation is needed; otherwise `Xxx`
- API model: `XxxModel`
- Contract: `XxxRepository`
- Implementation: `XxxRepositoryImpl`
- Datasource: `XxxRemoteDataSource` / `XxxLocalDataSource`
- Controller/state: `XxxController`, `XxxState`

---

## 3) Domain / Data / Presentation Rules

## Domain
- Defines stable app-facing contracts and entities
- No Dio, no JSON parsing details

## Data
- Handles API payload parsing and transport concerns
- Maps models to domain entities in repository layer

## Presentation
- Uses domain entities and repository contracts
- Must not parse backend payloads directly

---

## 4) Shared vs Feature-local Widgets

Create in `shared/widgets` when:
- reusable by 2+ features
- generic behavior (not business-specific)

Keep in `features/<feature>/presentation/widgets` when:
- tied to one business module
- likely to evolve with that module only

---

## 5) List Screen Pattern

Recommended flow:
- query object (`ListQueryParams`)
- controller load/search/retry/page actions
- state includes loading/error/items/meta
- page renders toolbar + state view + list + pagination

---

## 6) Detail Screen Pattern

- load by ID
- show loading/error/content states
- mutate via explicit actions (status update, assign roles, etc.)
- refresh state after successful mutation

---

## 7) Actions / Forms / Dialogs

- Keep form validation minimal and explicit
- Disable submit during in-flight requests
- Show user-safe errors (no raw stack traces)
- Use dialogs for lightweight actions

---

## 8) Backend Alignment Rules in Modules

- Backend contract is source of truth
- Keep uncertain parsing assumptions isolated in one place
- Add TODO markers for uncertain contract sections
- Avoid scattering guessed fields across UI

---

## 9) What Not To Do

- Don’t call Dio directly from pages
- Don’t use API models directly in widgets
- Don’t hardcode future domain assumptions into base platform modules
- Don’t place client branding logic inside shared platform widgets


# API Sync Rules

## 1) Source of Truth

The backend contract is authoritative. Frontend implementation must follow backend docs/specs (Swagger/OpenAPI or backend team references).

---

## 2) Non-negotiable Integration Rules

1. **Never guess field names globally**.
2. Parse uncertain payload shapes in isolated model/mapper locations.
3. Repositories return domain-oriented results (`ApiResult<DomainEntity>`), not raw transport objects.
4. Protected endpoints use `Authorization: Bearer <access_token>`.
5. Refresh flow should be safe (single retry path, no infinite loops).
6. Pagination mapping assumptions must stay centralized.
7. Error mapping must produce user-safe messages.

---

## 3) DTO / Entity Sync Pattern

- Datasource: fetch raw API payload
- Model: parse API JSON
- Repository: map model -> domain entity
- Presentation: consume domain entities only

This keeps API volatility away from UI.

---

## 4) Pagination Mapping Rules

Use shared types and mapping helpers:
- `PaginatedData<T>`
- `PageMeta`
- `ListQueryParams`
- list response mapper in networking layer

If backend envelope changes, update mapper/model once, not all pages.

---

## 5) Error Handling Rules

- Convert network/server/auth failures into typed app exceptions
- Show user-safe messages in controllers/pages
- Keep low-level diagnostics internal

---

## 6) Current API Areas (High-level)

## Auth
- register/login/refresh/logout/me

## Admin users
- user list
- user detail
- status update
- role assignment

## Settings/basic platform
- keep contracts explicit and backend-aligned as they mature

## Profile/session context
- current user + roles/permissions/session restoration

> Note: this is intentionally a high-level sync map, not a speculative full API catalog.

---

## 7) Change Management

When backend changes:
1. Confirm contract diff with backend team/docs
2. Update API models/mappers first
3. Update repository mappings
4. Validate affected UI flows
5. Update documentation if behavior/rules changed


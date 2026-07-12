# API Contracts

## Masjid requests

- `POST /masjid-requests` public. Body includes requester fields, masjid location fields, flat imam keys, and `committeeMembers: [{ name, phone }]`.
- Location fields are `country`, `state`, `district`, `locality`, and `address`.
- `locality` is the backend/API field for the frontend label `City / Village / Town`.
- `district` is required when `country` is `India` or `IN`; it may be omitted for non-India requests.
- `GET /masjid-requests` admin. Query: `id`, `status`, `search`, `masjidName`, `locality`, `district`, `state`, `country`, `requesterPhone`, `page`, `limit`. Returns paginated request rows.
- `PATCH /masjid-requests/:id/status` admin. Body: `{ status: "APPROVED" }` or `{ status: "REJECTED", reason }`.

## Masjids

Masjid responses use only `country`, `state`, `district`, `locality`, and `address` for location. They do not return separate city, village, or town fields.

## Community member edit/status APIs

- `PATCH /api/v1/masjids/my/users/:userId` edits a sanitized masjid user. Body: `{ "fullName": "...", "phone": "...", "email": "..." }`. The endpoint never accepts role, masjidId, password, or token fields. It returns `{ success, message, data }` where `data` contains `id`, `fullName`, `phone`, `email`, `status`, `roles`, and `masjidId` only.
- `PATCH /api/v1/masjids/my/users/:userId/status` updates user status. Body: `{ "status": "ACTIVE" }` where status is `ACTIVE`, `INACTIVE`, or `SUSPENDED`.
- `SUPER_ADMIN` can edit/status users. `COMMITTEE_MEMBER` can edit/status only same-masjid users whose role is `MEMBER`. `MEMBER`, `IMAM`, and ordinary masjid users cannot use these endpoints.

## Imam salary create/update contract

- `POST /api/v1/imam-salaries/my-masjid` and `PATCH /api/v1/imam-salaries/:id` accept `month`, `year`, `salaryAmount`, optional `paidAmount`, optional `paidDate`, and optional `note`.
- Frontend must not send `status`. Backend calculates `dueAmount = salaryAmount - paidAmount` and status as `UNPAID` when paid amount is zero, `PARTIAL` when paid amount is between zero and salary amount, and `PAID` when paid amount equals salary amount. Paid amount greater than salary amount is rejected with `Paid amount cannot be greater than salary amount`.

## Date format standard

- API date-only fields are sent as `yyyy-MM-dd`.
- Flutter UI displays dates as `dd MMM yyyy` through `formatReadableDate`, for example `15 Jun 2026`.
- Forms use `AppDateField` and Flutter's built-in Material date picker instead of raw manual ISO date entry.

## Lightweight audit fields

Important records now return lightweight audit snapshot fields in their normal list and detail responses. No separate audit endpoint or extra frontend API call is required.

The following response objects include:

```json
{
  "createdById": "8f25c0af-9f1e-4d7d-8a49-2b4b57e2b2b1",
  "createdByName": "Masjid Admin",
  "createdAt": "2026-06-15T10:30:00.000Z",
  "updatedById": "3b4a86d8-5bc3-43e6-b4c6-a9ef90d81b62",
  "updatedByName": "Committee Member",
  "updatedAt": "2026-06-16T12:15:00.000Z"
}
```

Applies to: Imam Salary, Collection, Expense, Project, Announcement, and NamazTime responses.

Community User list/detail responses include the existing timestamps plus updater snapshot fields:

```json
{
  "createdAt": "2026-06-15T10:30:00.000Z",
  "updatedAt": "2026-06-16T12:15:00.000Z",
  "updatedById": "3b4a86d8-5bc3-43e6-b4c6-a9ef90d81b62",
  "updatedByName": "Committee Member"
}
```

Sensitive fields such as `passwordHash` and `refreshTokenHash` are not returned in these responses.

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

## User profile fields

Community user responses include `fatherName`, `age`, `gender`, `isFamilyHead`, and `familyMemberCount` alongside `fullName`, `phone`, `email`, `status`, `masjidId`, and `roles`. `gender` is one of `MALE`, `FEMALE`, or `OTHER`.

### Add community user

`POST /api/v1/masjids/my/users` requires `fullName`, `phone`, `role`, `fatherName`, `age`, and `gender`. When `role` is `MEMBER`, `isFamilyHead` must be provided as `true` or `false`. `email`, `masjidId`, and `familyMemberCount` are optional.

### Update community user

`PATCH /api/v1/masjids/my/users/:userId` requires `fullName`, `phone`, `fatherName`, `age`, and `gender`. If the target user is a `MEMBER`, `isFamilyHead` must be provided. `email` and `familyMemberCount` are optional. Role and masjid changes are not accepted by this API.

### Masjid request imam fields

Masjid registration requests require imam `imamName`, `imamPhone`, `imamAddress`, `imamFatherName`, `imamAge`, and `imamGender`; `imamEmail` is optional.

### Masjid request committee member fields

Each committee member in `committeeMembers` requires `name`, `phone`, `fatherName`, `age`, and `gender`.

## Public masjid request tracking

`POST /api/v1/masjid-requests/track` is a public endpoint for tracking masjid registration applications by the registered requester phone number. It does not use or store any tracking token.

Request body:

```json
{
  "requesterPhone": "+919876543210"
}
```

Response data is intentionally limited for privacy and contains no requester details, committee member data, reviewer details, internal IDs, or created masjid IDs:

```json
{
  "items": [
    {
      "masjidName": "Jama Masjid",
      "status": "PENDING",
      "imamName": "Maulana Ahmed",
      "requestedAt": "2026-07-25T10:30:00.000Z",
      "reviewedAt": null
    }
  ]
}
```

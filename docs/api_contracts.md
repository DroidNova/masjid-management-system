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

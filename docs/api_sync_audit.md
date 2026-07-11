# API Sync Audit

| Area | Endpoint | Frontend uses | Method | Contract | Response | Status |
| --- | --- | --- | --- | --- | --- | --- |
| Masjid Request | `/masjid-requests` | Yes | POST | Uses `country`, `state`, `district`, `locality`, `address`; `locality` is City / Village / Town | Yes | Synced |
| Masjid Request | `/masjid-requests` | Yes | GET | Query uses `status`, `search`, `masjidName`, `country`, `state`, `district`, `locality`, `requesterPhone`, `page`, `limit` | Paginated | Synced |
| Masjid Request | `/masjid-requests/:id/status` | Yes | PATCH | `status`, `reason` | Yes | Synced |

`locality` is the backend/API field for City / Village / Town. Separate `city`, `village`, and `town` fields are not part of the API contract.

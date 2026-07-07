# API Response Handling

## Backend contract

### Success
```json
{
  "success": true,
  "message": "Request completed successfully",
  "data": {}
}
```

### Error
```json
{
  "success": false,
  "message": "Readable message for frontend",
  "errorCode": "MACHINE_READABLE_ERROR_CODE",
  "errors": {}
}
```

`errors` is optional and primarily for field validation details.

## Flutter implementation

- `ApiResponse<T>` (`lib/core/network/api_response.dart`) parses success/error envelopes safely.
- `ApiException` (`lib/core/network/api_exception.dart`) is the single error object passed through app layers.
- `ApiErrorCodes` (`lib/core/constants/api_error_codes.dart`) contains backend-aligned machine codes.
- `DioClient` (`lib/core/network/dio_client.dart`) now parses envelope responses for both HTTP success and error statuses.

## Auth-specific behavior

- `INVALID_CREDENTIALS`: login page shows invalid credentials message, no global logout.
- `SESSION_EXPIRED`: tokens/session cleared and user moved to unauthenticated state.
- `UNAUTHORIZED`: handled by context; protected APIs should force re-auth, login screen should show backend message.
- `FORBIDDEN`: permission denied message; no forced logout.
- `VALIDATION_ERROR`: message plus structured `errors` map is preserved for field-level rendering.

## Why not rely on HTTP 401 only?

Different business errors can share `401` at transport level. We must use `errorCode` to distinguish:
- bad login (`INVALID_CREDENTIALS`)
- expired session (`SESSION_EXPIRED`)
- generic unauthorized (`UNAUTHORIZED`)

## Adding future error codes

1. Add constant in `ApiErrorCodes`.
2. Add convenience getter in `ApiException` if needed.
3. Map code to UI-safe messaging where relevant (controller/state layer).
4. Add/extend checklist scenarios in `docs/API_RESPONSE_TEST_CHECKLIST.md`.

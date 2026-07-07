# API Response Test Checklist

- Login success:
  - Expected: user logs in and tokens are saved.
- Wrong password:
  - Expected: login screen shows invalid username/password.
  - Expected: user is not redirected as session-expired.
- Expired access token:
  - Expected: app clears session and redirects to login.
  - Expected: session-expired message is shown.
- Missing token on protected route:
  - Expected: auth issue handled safely.
- Forbidden API:
  - Expected: permission denied message and no automatic logout.
- Validation error:
  - Expected: validation message and/or field errors available in state.
- No internet:
  - Expected: no internet message shown.
- Server error:
  - Expected: safe generic error shown.

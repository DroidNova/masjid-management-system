# Team testing (staging)

The app is live for the team, running on the owner's PC through a free ngrok
address. It is a **test** setup: use made-up data only, never real money
records or real member lists.

- Website: https://celtic-landscape-exonerate.ngrok-free.dev
  (the first visit shows an ngrok notice: tap **Visit Site**).
- Android: the APK from the owner (`dist/Masjid-1.0.0-test.apk`; for very
  old phones `Masjid-1.0.0-test-old-phones.apk`). iPhone users test in
  Safari with the website link.
- Login code is always `1111`. New imams and committee members get the
  password `12345678`; change it in Profile.

Because the code is fixed, anyone who knows a test account's phone number
can log in to this test server. That is fine for test data and the reason
real data must wait for the launch (real SMS codes).

## Installing the APK

1. Open the APK file from WhatsApp or Files.
2. If Android asks, allow "Install unknown apps" for that app, then tap
   Install. Play Protect may warn because the app is not from the Play
   Store yet: tap "Install anyway".
3. To update later, install the new APK over the old one (data stays).

## What to test

Try each in Hindi, Urdu, and English, on a phone and in a desktop browser.
Note anything wrong, slow, confusing, or badly translated.

**Everyone**
- Choose a language; log in with a phone number and code 1111.
- Home: next namaz and times, latest news (also read aloud).
- Profile: change language and large text; log out; log in again.

**Register a new masjid (no login needed)**
- Start → Register masjid; fill all steps; send; track the request.
- Super admin approves it; the imam and committee can then log in.

**Super admin** (Dashboard, Requests, Masjids, Users)
- Approve and reject requests; suspend a masjid (needs a reason).
- Change a user's status and roles. On a computer, check that details open
  beside the list.

**Imam**
- Change namaz times (including Jumma); add, edit, and delete news.

**Committee**
- Money in (Jumma collection, donation box, zakat…) and money out; cancel
  a wrong entry.
- Imam salary: start a month, record a family's payment, raise the amount.
- Projects: add, edit, add a giver, cancel.
- People: add a member and a family head; edit; turn off and on.

**Member**
- My payments: totals, salary months, project gifts, donations.
- Leave masjid (hold the button), then check you are out.

**Also try**
- Turn off the internet in the middle of something.
- Very long names and big amounts (₹12,34,567).
- Rotate the phone; use the phone's largest text size.

## Reporting a problem

Send in the team group: what you did, what you expected, what happened, a
screenshot, the language, and the phone model (or browser). One message
per problem.

## For the owner: keeping it running

- The PC must stay on, awake, connected, and plugged in (on battery it
  sleeps after 45 minutes). Closing a laptop lid may also sleep it.
- Turn on Docker Desktop → Settings → General → "Start Docker Desktop
  when you sign in", so the app comes back by itself after a restart.
- Start / stop everything: `scripts/start.ps1` / `scripts/stop.ps1`.
- Back up the database: `scripts/backup.ps1` (keeps the last 14 copies in
  `backups/`). Do it before every app update.
- After code changes: `docker compose up -d --build backend frontend`.
- New APK: in `masjid-core-frontend`, raise `version:` in `pubspec.yaml`
  (for example `1.0.1+2`), then
  `flutter build apk --release --split-per-abi --dart-define-from-file=env/tunnel.json`.
  It is signed with the upload key in `C:\Users\ashim\.masjid-keys` (keep a
  copy of that folder somewhere safe: the Play Store launch needs it).
- The free ngrok plan has a monthly data limit (about 1 GB). A first visit
  to the website downloads about 5 MB, the app much less. Usage is on the
  ngrok dashboard.
- The server runs with `BACKEND_NODE_ENV=staging` (strict settings, API
  docs page off, test login code on). See `docs/DOCKER.md`.

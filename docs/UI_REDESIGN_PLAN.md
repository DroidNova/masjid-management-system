# UI Redesign Plan

Written 2026-10-09. This plan replaces the "no UI work now" rule in `IMPROVEMENT_PLAN.md`. The app works. Now it has to look professional and be easy to use for villagers who may read very little or not at all, on **Android, iOS, and the website** alike.

## Checkpoint (read this first in a new session)

- **Status:** U0 to U6 done 2026-10-09. The design system lives in `masjid-core-frontend/lib/shared/ui/` (import `shared/ui/ui.dart`); see it at `/dev/gallery` (dev builds, no login). Old screens still use `lib/shared/widgets/` until their phase moves them over; U7 deletes the old widgets.
- **Next:** U7 (super admin screens, error/empty/not-allowed views, app icon and splash, web loading screen and manifest, delete the old `lib/shared/widgets`).
- **U0 notes for later phases:** strings go in `lib/l10n/app_{en,hi,ur}.arb` (Hindi/Urdu are first drafts, checked in U8). Settings (language, large text, read-aloud) are in `core/settings/app_settings.dart`; read-aloud is `core/settings/speaker.dart`. Widget tests use `test/shared/ui/ui_test_helpers.dart` (`pumpUi`); pages with loading placeholders need animations turned off in tests (see `design_gallery_test.dart`). Docker's Flutter image is pinned to the CI version (3.41.6); bump both together.
- **U1 notes for later phases:** shared pieces added: `NumberKeypad` (phone, code, amounts), `PhoneEntry` (keypad phone with country), `PhoneFormField` / `AppFormField` / `AgeFormField` / `GenderFormField`, `MessageBanner` (errors on the page instead of snack bars), `BusyButton`, `ScreenHeader`, `showCountryPicker`; `StepFlow` steps take `validate`, and `StepFlowState.goTo` jumps to a step. Errors go through `core/errors/error_text.dart` (`errorText(l10n, error)`): no internet and too many tries are translated, other API errors show the server's message. The router sends people without a chosen language to `/language` first (`languageRedirect`), and a signed-out refresh of a public page stays on it. Tests: `testAppOverrides()` and `testLocalizationsDelegates` build localized test apps, `tapKeypad` types on the keypad; `test/features/start_screens_test.dart` checks every U1 screen's layout in 3 languages, 2 widths, and a large font. SMS auto-fill of the code is left for M6 (real SMS); it will feed the OTP screen's code like the keys do.
- **U2 notes for later phases:** tabs come from `mainTabsFor(permissions)` in `features/main_shell/main_tabs.dart`; `MainTab`'s order is the router's shell branch order (home, finance, projects, community, news, times, my-payments, profile), and every branch exists for everyone, only the visible tabs differ. `MainTab.hasOwnAppBar` marks pages that still draw their own top bar (News, My payments) until U3/U6 redesign them; remove the flag then. Home tiles are `homeActions()` in the Home screen. Prayer logic (parsing "05:00 AM", Jumma on Fridays, next prayer) is `features/namaz_time/application/prayer_schedule.dart`; names and icons are `prayer_labels.dart`. Profile (`features/profile`) holds settings, Change password (imam/committee/admin only, `PermissionHelper.hasPassword`), Logout, and Leave masjid (danger dialog calling the repository directly). The old top-bar account menu, logout button, leave controller, and old Home cards are deleted. Number keypads submit on Enter (website). Website builds call the API at their own address (`FRONTEND_API_BASE_URL=/api/v1`, see DOCKER.md), and nginx no longer caches app files as immutable (browsers kept old builds for a year).
- **U3 notes for later phases:** `pumpRouted()` in the test helpers opens a screen above a stand-in Home (pop and back work) with saved values via `prefs`. Times are stored as "05:00 PM" (`formatNamazTime`), shown in the device's style (`prayerTimeText`); `shiftTime` does the −5/+5. News: the list asks for `isActive=true` only (delete hides it from everyone; before, deleted news still showed), "New" marks and the Home News tile count come from `newsLastSeenProvider` (per user, per device). The server has no "important" flag and no time history, so the plan's "important" toggle and "same as last week" were left out (backend tasks if wanted). Leaving a changed form asks first (`PopScope` + `showConfirmSheet`); reuse that for later forms. `EmptyState` buttons take their section's colour.
- **U4 notes for later phases:** `PagedListView` (shared/ui) is the list page: header widgets, skeleton, empty, error with Try again, load more, optional day headings (`dayOf`); use it for projects, people, salary. `dayLabel()` names days. `ActionTile.selected` marks a picked tile; picking a kind moves the `StepFlow` on by itself (`StepFlowState.next()`). Money kinds, pictures, and names are in `features/finance/presentation/money_categories.dart` (also payment modes). Adding a gift is one flow for collections and projects: `/contributions/new` (`?project=<id>` for a project), `ContributionFlowScreen`; the old pop-up form is gone and the project givers page opens the flow. The Money tab keeps both lists loaded while open. Amounts at the end of a row go in a `ConstrainedBox(maxWidth)`, never `Flexible` next to an `Expanded` (that splits the row in half).
- **U5 notes for later phases:** shared `ProgressRing` / `ProgressBar` and `MonthStrip` (months as chips). Salary: committee taps a family that owes (`FamilyDueTile`) and the pay sheet opens with the due amount filled; start month and raise amount are sheets with the amount pad (`salary_sheets.dart`); amount checks (more than due, lowering) are translated in the sheets before the controller's own checks. Projects: one 3-step `ProjectFormScreen` for add and edit; the server's "delete" only cancels a project, so the button says "Cancel project". `GiverTile` moved to `contributions/presentation/widgets/giver_tile.dart` (collections, projects, salary payments). `AmountPad.textOf(double)` turns an amount into pad text.
- **U6 notes for later phases:** People is one list with a masjid card, search, and group chips (All, Committee, Imam, Members); tapping a person opens a details sheet with Edit and Turn off/on (Turn off is a hold danger dialog). `PersonTile`, `personRoleLabel`/`personRoleIcon`, and `showPersonDetails` are public in `community_screen.dart`. Add and edit share one 3-step `PersonFormScreen` (who, details, role and family); edit is a route, `/community/users/:id/edit`, gated like add. A new imam or committee member's temporary password stays on screen with Copy until OK. My payments has a totals card (with what salary is still due) and Salary / Projects / Donations sections; only the open section loads. `MainTab.hasOwnAppBar` is gone: every tab's title comes from the frame. The old community and contribution widgets are deleted.
- **Rule:** one phase per session. Each phase ends with `flutter analyze`, the tests, a web build, and screenshots of the changed screens at phone width (360 dp), tablet width (800 dp), and desktop web width (1280 px), in English and Urdu.

## 1. Who uses the app

| Person | Reads? | What they do most | What they need from the app |
|---|---|---|---|
| Member (villager) | Little or none | Check namaz time, hear announcements, see what they paid | One glance, big numbers, pictures, read-aloud |
| Imam | Usually yes | Change namaz times, post announcements, see own salary | Fast edits, no hunting through menus |
| Committee member | Some | Record money in and out, collect salary from families, run projects | Few taps per entry, no typing mistakes, clear totals |
| Super admin | Yes | Approve masjids, manage users | Clean lists; lowest priority for the redesign |

## 2. What is wrong today

- **Home is one long page.** Seven cards stacked with buttons between them. You must read to find anything.
- **Everything is words.** Buttons say "Add Collection", "Update Namaz Time". Nothing works without reading English.
- **English only.** No Hindi or Urdu yet.
- **Same tabs for everyone.** A member sees "Finance" and "Projects" tabs they cannot act on. The imam has no tab for the times he changes every week.
- **Forms ask everything on one page** with small fields, free typing for amounts, and dates typed by hand.
- **Logout and Leave masjid sit in the top bar**, easy to tap by mistake, and there is no place to see your own profile or account status.
- **Money has no visual language.** Money in and money out look the same apart from text.
- **No clear "it worked".** A small snackbar after saving, easy to miss.
- **App is called "Masjid Core"** in the top bar. It should show the masjid's own name.
- **Phone layout stretched on big screens.** The website and tablets show the phone layout in a narrow column; no side menu, no hover or keyboard support.

## 3. Design rules

These apply to every screen. A screen that breaks one is not done.

1. **One screen, one job.** Each screen answers one question or does one task. If it does two, split it.
2. **Picture first, word second.** Every action and category has an icon and a colour. The word is a short label under it (one or two words), never a sentence.
3. **Same meaning, same look, everywhere.**

   | Meaning | Colour | Icon |
   |---|---|---|
   | Namaz times | Deep blue | Sun/moon position for each prayer |
   | Announcements | Amber | Megaphone |
   | Money in | Green | Arrow down into a wallet, "+" |
   | Money out | Red | Arrow out of a wallet, "−" |
   | Projects | Purple | Building/bricks |
   | People | Teal | Group of people |
   | Imam salary | Brown | Person with turban + rupee |
   | Paid / done | Green | Tick |
   | Waiting / due | Amber | Clock |
   | Late / problem | Red | Exclamation |

4. **Numbers big, words small.** Times and rupee amounts are the largest text on the screen. Indian number format (₹1,25,000).
5. **Big targets.** Every tappable thing is at least 56 × 56 dp. Base text size 18. The layout still works at the phone's largest text setting.
6. **Read aloud.** A speaker button on announcements, namaz times, and money totals. Uses the phone's own text-to-speech (free, works offline with installed voices).
7. **Ask one thing at a time.** Forms become short step-by-step flows: one question per step, a big "Next" button, a progress dots bar.
8. **Pick, don't type.** Amounts use a large number pad plus quick chips (₹100, ₹500, ₹1000). Dates default to today with "Today / Yesterday / Pick" chips. People are picked from a list with initials and a search box.
9. **Show the result.** After saving: a full-screen green tick with the amount or item, read aloud, then back. Before deleting or cancelling: a red sheet with the icon and one "Yes, delete" button.
10. **Empty is friendly.** Empty lists show a picture and one button ("Add first project"), never just "No data".
11. **Masjid identity.** The top bar shows the masjid name, not "Masjid Core".
12. **Language first.** The first screen ever asks the language with large script names: हिन्दी, اردو, English. Changeable later from Profile. Urdu flips the layout right-to-left.
13. **Professional finish.** One consistent look: same corner radius, shadows, and spacing on every screen; smooth 200 ms transitions; skeleton placeholders while loading (no bare spinners); a real app icon and splash on all three platforms; no default Flutter look left anywhere.
14. **Same app, three platforms.** Every screen is designed for Android, iOS, and the website at once (section 5). No screen is "done" until it is checked on all three sizes.

## 4. New navigation

Tabs depend on the person's permissions (still read from `user.permissions`, never from role names). Each tab is a big icon with a one-word label. **Profile is always the last tab, for every logged-in person.** At most five tabs.

| Tab | Member | Imam | Committee | Super admin |
|---|---|---|---|---|
| 1 | Home | Home | Home | Dashboard |
| 2 | News (announcements) | Times | Money | Requests |
| 3 | My payments | News | Projects | Masjids |
| 4 | Profile | Profile | People | Users |
| 5 | | | Profile | Profile |

Committee reaches Announcements and Times from Home tiles; the imam reaches his salary ledger from a Home tile. The top bar no longer holds logout or account menus; everything about the person lives in Profile.

### Profile tab

Top to bottom:

1. **Header:** large avatar with initials, full name, phone number, role badges with icons (Imam, Committee, Member, Family head).
2. **Status card:** account status as a coloured dot and word (green "Active", amber "Pending", red "Inactive"); phone verified tick; masjid name and place; "Member since" date. All of this already comes from the login response and the dashboard; no backend work.
3. **Settings list** (one row each, icon + short label): Language, Text size (normal / large), Read-aloud on/off, Change password.
4. **Logout:** an outlined neutral button. Tap shows a small confirm ("Log out?" with Cancel / Log out).
5. **Leave masjid:** at the very bottom, separated by space, in a red "danger" style (red outline, door-exit icon). Shown only to people with the `masjid.leave` permission who belong to a masjid. This replaces today's app-bar menu item (`shared/widgets/account_menu_button.dart`).

### Leave masjid flow (danger dialog)

1. Tap **Leave masjid** → a danger dialog opens: large red warning icon, the masjid's name in bold, and three short lines, each with an icon:
   - You will no longer see this masjid's times, news, and money.
   - Your payment history stays with the masjid.
   - Another masjid can add you after you leave.
   A speaker button reads it aloud.
2. Buttons: **Cancel** is the big, default, highlighted button. **Leave** is red and must be **pressed and held for 2 seconds** (a ring fills while holding). Holding works for people who cannot read a "type LEAVE to confirm" box and stops accidental taps.
3. While the request runs, the dialog shows progress and cannot be dismissed.
4. Success → a full screen "You left <masjid name>" with a door icon, then the app moves to the no-masjid state. Failure (for example `CANNOT_LEAVE_MASJID`) → the dialog shows the server's reason with a red icon and an OK button; nothing changes.
5. Shape per platform: a bottom sheet on phones (Android and iOS; Apple's own guidelines use action sheets for destructive choices), a centred dialog on tablets and the website. Esc and the back button act as Cancel; swipe-down and tap-outside are off so a running request is never abandoned. Simple yes/no confirms (log out) use the native-looking alert on iOS.

The same `DangerDialog` widget (with hold-to-confirm) is used everywhere something cannot be undone: deactivating a person, cancelling a finance entry, deleting an announcement or project.

### Home, the main screen

Top to bottom:

1. **Next namaz hero card:** prayer name with its icon, the time in very large digits, "in 1 h 20 min" countdown, speaker button. Below it a row of all five prayers plus Jumma, the current one highlighted.
2. **Action tiles:** a 2-column grid of large coloured tiles, only the ones this person may use. Examples: Committee sees "Money in", "Money out", "Salary", "Projects", "News", "Times". Member sees "My payments", "News", "Projects".
3. **Latest announcement:** one card, amber, with speaker button and "See all".
4. **Masjid balance** (everyone may read the finance summary): one big number, green or red, with a small in/out bar.

## 5. Android, iOS, and website

One Flutter codebase, three platforms. The design adapts to screen size first and to the platform second.

### Screen sizes

| Width | Typical device | Navigation | Layout |
|---|---|---|---|
| Under 600 dp | Phones | Bottom navigation bar | One column; Home tiles in 2 columns |
| 600–1024 dp | Tablets, small laptop windows | Navigation rail on the side (icons + labels) | Home tiles in 3 columns; forms centred at 560 dp wide |
| Over 1024 dp | Desktop browsers | Wide side menu with the masjid name at the top and Profile at the bottom | Content max 1100 dp wide; lists open details in a right-hand pane (people, projects, money entries, admin lists); Home tiles in 4 columns |

Built once in U0 as `AdaptiveScaffold` (switches bottom bar / rail / side menu) and `showAppSheet` / `showConfirmSheet` (bottom sheet on phones, centred dialog on wide screens, Cupertino alert for iOS confirms). Screens never check the platform themselves.

### Android

- Material 3 look, edge-to-edge drawing with correct system bar colours.
- System back button closes sheets and dialogs first, then goes back; predictive back animation on Android 14+.
- Number pad and phone keyboard for numeric fields; SMS OTP auto-fill once real SMS arrives (M6).
- Works on cheap phones: test on a 360 dp wide, 2 GB RAM device or emulator; no heavy animations or large images.

### iOS

- Swipe from the left edge to go back on every pushed screen.
- Respect the notch and the home indicator (safe areas everywhere, including bottom buttons).
- iOS-style wheels for time and date pickers; Cupertino alerts for confirmations.
- One-time-code auto-fill hint on the OTP field; a "Done" bar above number keyboards (iOS has no return key on them).
- Light haptic tap on success and on hold-to-confirm.
- Building and testing iOS needs a Mac. Low-cost route: a free CI macOS runner (GitHub Actions or Codemagic free tier) for builds, and a real iPhone for the U8 check. Store publishing is part of M6.

### Website

- Mouse: hover states on every tile, row, and button; pointer cursor on anything clickable.
- Keyboard: Tab moves through fields with a visible focus ring, Enter submits, Esc closes dialogs.
- Browser back/forward and page refresh keep the user on the same screen (routes already live in the URL); each page sets a browser tab title ("Money – Barota Masjid").
- Fast first load: a branded loading screen in `web/index.html` while Flutter starts, fonts loaded per language, images kept small.
- Read-aloud uses the browser's speech voices (`flutter_tts` supports web).
- Installable to the phone home screen (web app manifest with the new icon), for people who will not install the APK.
- No horizontal scrolling from 360 px phones up to wide desktop screens.

### All platforms

- Screen readers (TalkBack, VoiceOver, browser readers) get a label on every icon-only button. This also helps people who cannot read.
- Text scales with the phone's font setting up to 200% without breaking layouts.
- Urdu right-to-left checked on all three.
- App icon and splash generated for Android, iOS, and web from one source (`flutter_launcher_icons`, `flutter_native_splash`, both free, dev-only).

## 6. Shared building blocks (U0)

Built once in `lib/shared/`, used by every screen. A dev-only gallery route shows them all.

- `AppTokens`: colours from the table above, spacing (4/8/12/16/24/32), radius, type scale. Light theme first; dark theme kept in mind but not shipped in this plan.
- `AppTheme` rebuilt on the tokens (Material 3, seed stays green/teal unless the owner picks another).
- Fonts bundled so they work offline: Mukta (English and Hindi in one family, 3 weights) and Noto Nastaliq Urdu, about 2 MB total, SIL OFL (licences registered in the app's licence page). Mukta replaced Noto Sans because Noto Sans alone is 2 MB.
- Icons: Material rounded icons, one per meaning in `AppIcons`. Material already has a mosque and sun-position icons, so no custom SVGs or `flutter_svg` were needed in U0; add them only if a later phase finds a gap.
- Widgets: `ActionTile`, `HeroCard`, `AmountText`, `StatusBadge`, `PersonAvatar`, `SectionHeader`, `EmptyState`, `ReadAloudButton`, `StepFlow` (multi-step form), `AmountPad`, `DateChips`, `PersonPicker`, `ConfirmSheet`, `DangerDialog` (hold-to-confirm), `SuccessScreen`, `SkeletonList` (loading placeholder instead of a spinner), `AdaptiveScaffold`, `AdaptiveDialog`, adaptive time/date pickers (Material on Android and web, Cupertino wheels on iOS).
- Localization: all strings go into ARB files during each phase (the M7 extraction happens here, screen by screen, so no screen is edited twice). `hi` and `ur` ARB files start with English fallbacks and get real translations in U8.
- Adds `flutter_tts` for read-aloud and `shared_preferences` for the chosen language and text size.
- The gallery is checked by tests in English, Hindi, and Urdu at phone, tablet, and desktop widths, plus a large device font; CI also builds the iOS app (unsigned) on every push to prove it compiles.

## 7. Screen-by-screen changes

| Area | Screens | Change |
|---|---|---|
| Start | Splash, auth landing | Splash shows a mosque mark. First launch: language picker. Landing: two big tiles, "Login" and "Register masjid", plus "Track request". |
| Login | Phone, password, OTP | Big phone field with country fixed to +91 by default, on-screen number pad. OTP: four large boxes, auto-advance, auto-fill on Android. Password screen stays for those who set one. |
| Masjid request | Form, submitted, track | Long form becomes a 5-step flow: masjid → place → imam → committee → you. Review page with icons before submit. Track screen: a vertical timeline (sent → checking → approved/rejected) with colours. |
| Home | Dashboard | As in section 4. On wide screens the hero card and latest announcement sit side by side above the tiles. |
| Namaz times | Times card, update screen | Card as in section 4. Update: each prayer is a row with its icon and a big time button that opens a clock wheel; "same as last week" shortcut; Jumma separate. |
| Announcements | List, add, edit | Amber cards, newest first, speaker button on each, "new" dot for unseen ones. Add: title, message, optional "important" toggle (red border). Large text box with a mic button to dictate (keyboard voice input, free). |
| Money | Finance, add collection, add expense | Top: balance hero, this month in/out bars. Two big buttons: green "Money in", red "Money out". Add flow: pick category from icon grid (Jumma, Donation box, Zakat, Other…) → amount pad → date chips → note (optional) → success tick. List grouped by day with category icons, green +/red − amounts. Filter by icon chips, not a dropdown. |
| Collection contributions | Per-collection list | Each giver is a row with avatar, amount, status badge. "Add giver" uses `PersonPicker` + `AmountPad`. |
| Imam salary | Ledger, dialogs, payment history | Month strip at top (swipe). For the month: big progress ring "₹8,000 of ₹12,000 collected". Family list with paid/due badges; tap a due family → amount pad prefilled → done. Dialogs become full screens or bottom sheets with steps. |
| Projects | List, detail, add, edit, contributions | Cards with a picture-style icon, big progress bar, "₹X of ₹Y". Detail: progress ring, givers list, "Add contribution" button. Add/edit: step flow (name → target amount → dates). |
| My payments | My contributions, salary payment history | Two big tiles: "Imam salary" and "Donations". Each shows a month list with tick/clock badges and amounts. Read-aloud of the total. |
| People | Community, add user, edit dialog, status dialog | Search box on top, filter chips by role (icons). Rows with avatar, name, role badge, active/inactive dot. Add user: step flow (phone → name → role → done). Edit is a full screen, not a dialog. |
| Profile | New tab | As in section 4: header, status card, settings, logout, and Leave masjid at the bottom behind the `DangerDialog`. Old `account_menu_button.dart` and `logout_button.dart` are deleted. |
| Errors | All error/empty/not-allowed views | Picture + one sentence + one button ("Try again"). No raw error text for users; details only in debug builds. "No internet" has its own picture. |
| Super admin | Dashboard, requests, masjids, users | Apply tokens and shared widgets only: status badges, search, cleaner detail pages. No step flows needed. |

## 8. Phases

| Phase | Scope | Done when |
|---|---|---|
| U0 Foundation (done 2026-10-09) | Tokens, theme, fonts, icons, shared widgets incl. `AdaptiveScaffold`, `AdaptiveDialog`, `DangerDialog`; gallery route; language setting + ARB setup; `flutter_tts`; iOS build in CI | Gallery renders every widget in English and Urdu (RTL) at phone, tablet, and desktop widths; tests for `AmountText` formatting, `StepFlow`, and hold-to-confirm |
| U1 Start and login (done 2026-10-09) | Language picker, landing, phone, OTP, password, masjid request flow and tracking | Can register a masjid and log in without reading English |
| U2 Shell, Home, Profile (done 2026-10-09) | Role-based tabs (bottom bar / rail / side menu), Home, Profile tab with status card, logout, and the Leave masjid danger flow | Each role sees only its own tabs and tiles; leave masjid works end to end and cannot be triggered by one accidental tap; all checked on Android, iOS, and web |
| U3 Times and news (done 2026-10-09) | Namaz time card and update, announcements list/add/edit, read-aloud | Imam can change Asr time in under 15 seconds |
| U4 Money (done 2026-10-09) | Finance, money in/out flows, collection contributions | Committee can record ₹500 Jumma collection in 4 taps after opening Money |
| U5 Salary and projects (done 2026-10-09) | Imam salary, project screens, project contributions | Mark a family's salary paid in 3 taps |
| U6 People and my payments (done 2026-10-09) | Community screens, my contributions, payment history | |
| U7 Admin and errors | Super admin screens (with list + detail panes on desktop), all error/empty/not-allowed views, app icon and splash on all three platforms, web loading screen and install manifest | No screen still uses the old widgets; old unused widgets deleted |
| U8 Languages and testing | Hindi and Urdu translations, RTL check on every screen, test with 3–5 real villagers on Android phones plus a check on an iPhone and a desktop browser | Each tester finishes the 5 test tasks below without help |

Usability test tasks (U8): find today's Asr time; listen to the latest announcement; check whether you paid this month's imam salary; (committee) record a ₹500 Jumma collection; (imam) change Maghrib time.

## 9. What does not change

- No backend or API changes are expected. If a screen needs new data (for example "unseen" announcements), that gets its own small backend task.
- Permissions stay in `masjid-core/src/access/permissions.ts`; the app keeps gating on permission names.
- Riverpod controllers, repositories, and routing stay; only `presentation/` folders and `lib/shared/` change.
- Cost: every addition is free (open-source packages, Noto fonts, phone and browser TTS, free CI macOS minutes). App size grows by about 2 MB.

## 10. Owner decisions

Defaults are chosen so work can start; change any of them before the phase that uses it.

| Question | Default | Needed by |
|---|---|---|
| Main brand colour | Keep the current green-teal | U0 |
| Languages | Hindi, Urdu, English | U0 (setup), U8 (translations) |
| Read-aloud | Yes, using the phone's voice | U0 |
| App name and icon | Name "Masjid" in the launcher, masjid's own name inside the app; simple mosque icon | U7 |
| Who translates Hindi/Urdu | Draft by Claude, checked by a native speaker from the village | U8 |
| iOS builds | Free CI macOS runner (the repo is public, so macOS minutes cost nothing); a borrowed iPhone for the final check | Done for CI in U0; U8 (device) |

# Frontend Testing Checklist

Use this checklist for final QA before release. Test at least one allowed role and one disallowed role for every role-gated action.

## 1. Auth

- [ ] Splash without token goes to auth.
- [ ] Phone login works.
- [ ] Password step appears for privileged users.
- [ ] OTP `111111` works in the test environment.
- [ ] Access token, refresh token, and current user are saved after login.
- [ ] Restart opens main when session is valid.
- [ ] Logout clears local session and returns to auth.
- [ ] Expired access token refreshes when refresh token is valid.
- [ ] Invalid refresh token clears local session and asks user to login again.

## 2. Masjid Request

- [ ] Public form opens without login.
- [ ] Required validation works.
- [ ] Phone fields use phone keyboard on mobile.
- [ ] Optional email validates only when filled.
- [ ] Submit request works.
- [ ] Success dialog appears.

## 3. Home

- [ ] Dashboard loads.
- [ ] Pull refresh works.
- [ ] Masjid name and welcome message display.
- [ ] Namaz times display or show a friendly missing-state message.
- [ ] Announcements display or show a friendly empty state.
- [ ] Finance summary displays or falls back to zero/friendly values.
- [ ] Project summary displays or falls back to zero/friendly values.
- [ ] Imam salary summary displays or falls back to zero/friendly values.
- [ ] Imam/member count displays or falls back to zero/friendly values.

## 4. Finance

- [ ] Summary loads.
- [ ] Collections load.
- [ ] Expenses load.
- [ ] Pull refresh works.
- [ ] Empty collections/expenses show a friendly empty state.
- [ ] Add collection works for allowed role.
- [ ] Add expense works for allowed role.
- [ ] Amount validation rejects empty, invalid, zero, and negative values.
- [ ] Buttons are hidden for disallowed roles.

## 5. Projects

- [ ] Project list loads.
- [ ] Pull refresh works.
- [ ] Empty project list shows a friendly empty state.
- [ ] Add project works for allowed role.
- [ ] Detail opens.
- [ ] Edit works.
- [ ] Delete works.
- [ ] Buttons are hidden for disallowed roles.

## 6. Community

- [ ] Masjid info loads.
- [ ] Users are grouped correctly into Imam, Committee Members, and Members.
- [ ] Pull refresh works.
- [ ] Empty groups show friendly empty messages.
- [ ] Add user works for allowed role.
- [ ] COMMITTEE_MEMBER can add MEMBER only.
- [ ] MASJID_ADMIN can add IMAM and COMMITTEE_MEMBER only.
- [ ] SUPER_ADMIN can add IMAM and COMMITTEE_MEMBER only.
- [ ] Edit user works for allowed role.
- [ ] Status change works for allowed role.
- [ ] Add/edit/status buttons are hidden for disallowed roles.

## 7. Announcements

- [ ] List loads.
- [ ] Pull refresh works.
- [ ] Empty list shows a friendly empty state.
- [ ] Add works.
- [ ] Edit works.
- [ ] Delete works.
- [ ] Buttons are hidden for disallowed roles.

## 8. Namaz Time

- [ ] Update screen opens for allowed role.
- [ ] Existing times load.
- [ ] Save works.
- [ ] Validation messages are understandable.
- [ ] Button is hidden for disallowed roles.

## 9. Imam Salary

- [ ] List loads.
- [ ] Pull refresh works.
- [ ] Empty list shows a friendly empty state.
- [ ] Add works.
- [ ] Detail opens.
- [ ] Edit works.
- [ ] Delete works.
- [ ] Amount validation rejects empty, invalid, zero, and negative values.
- [ ] Buttons are hidden for disallowed roles.

## 10. Responsive

- [ ] Android screen works.
- [ ] Chrome/web screen works.
- [ ] Small mobile width has no overflow.
- [ ] Forms scroll on small screens.
- [ ] Web/desktop content stays centered and readable.

## 11. Errors

- [ ] Backend off shows friendly error.
- [ ] Unauthorized shows “Session expired. Please login again.”
- [ ] Forbidden shows “You are not allowed to perform this action.”
- [ ] User without masjid shows “You are not assigned to any masjid yet.”
- [ ] Duplicate phone shows “Phone number already exists.”
- [ ] Duplicate email shows “Email already exists.”
- [ ] No token, password, OTP, or full backend response is printed in logs.

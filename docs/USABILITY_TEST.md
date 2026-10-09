# Testing the app with villagers

A short guide for the U8 test (see `UI_REDESIGN_PLAN.md`, section 8). The goal
is to learn where real people get stuck, not to grade them. Each session
takes about 20 minutes.

## Who to test with

Pick 3 to 5 people from the village:

- 2 or 3 ordinary members, including at least one older person who reads
  little or not at all, and at least one woman if possible.
- 1 committee member (the treasurer, if possible).
- 1 imam.

Also check the app once on an iPhone (a borrowed one is fine) and once in a
desktop browser.

## Before the session

1. Start the test server with its public ngrok address and build the test
   APK against it (see `DOCKER.md`). Use test data, never real money
   records.
2. Make one test account for each person, with the role they will play.
   The login code is `1111` while testing.
3. Put the app on the person's own phone if they agree; it is what they
   know. Set the phone's text size the way they normally use it.
4. Let them choose their language on the first screen. Do not choose it
   for them.
5. Have this page (or the score table below) and a pen ready.

## During the session

- Say: "We are testing the app, not you. If something is hard, the app is
  wrong, not you."
- Ask them to say out loud what they are thinking and looking for.
- **Do not help.** Do not point, touch the phone, or hint. If they are
  stuck for 2 minutes, say "Thank you, let's try the next one" and note
  where they got stuck.
- Write down what they tap first, where they hesitate, and any word they
  do not understand.

## The 5 tasks

Give one task at a time, in words, in their language. Do not read the
button names to them.

| # | Who | Say this | Done when |
|---|-----|----------|-----------|
| 1 | Everyone | "What time is Asr today?" | They say the Asr time shown in the app. |
| 2 | Everyone | "Listen to the newest announcement." | The newest announcement is read aloud. |
| 3 | Members | "Have you paid the imam's salary this month?" | They say paid, partly paid, or not paid, matching the app. |
| 4 | Committee | "500 rupees came in the Jumma collection today. Put it in the app." | A ₹500 Jumma money-in entry for today is saved. |
| 5 | Imam | "Change the Maghrib time to 6:45." | Maghrib shows 6:45 PM. |

Goal from the plan: each person finishes their tasks without help.
Committee: the ₹500 entry in 4 taps after opening Money. Imam: a time
change in under 15 seconds.

## Score sheet

Copy one per person.

| Task | Finished? (yes / with help / no) | Time | Where they got stuck | Words they did not understand |
|------|----------------------------------|------|----------------------|-------------------------------|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |

Person: role ____, language ____, age (about) ____, reads easily? yes / a
little / no.

## After the tasks

Ask, and write down the answers:

1. What was easy?
2. What was hard or confusing?
3. Was any word strange? What would you call it?
4. Is the text big enough?
5. Would you use this app? What for?

## Checking the Hindi and Urdu words

`docs/translations_review.csv` lists every sentence in the app in English,
Hindi, and Urdu. Open it in Google Sheets or Excel and ask a native speaker
from the village (one for Hindi, one for Urdu) to read the Hindi or Urdu
column and fill in "Problem?" and "Better wording". Prefer the everyday
words people in the village really use over formal or bookish ones.

When the app's sentences change, make a fresh sheet from
`masjid-core-frontend`:

```
dart run tool/export_translations.dart ../docs/translations_review.csv
```

## After all sessions

Send the score sheets, the answers, and the filled translation sheet back
to the developer. Anything that 2 or more people got stuck on is fixed
first.

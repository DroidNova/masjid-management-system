import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/namaz_time_summary.dart';

/// The daily prayers plus Jumma, which takes Zuhr's place on Fridays.
enum Prayer { fajr, zuhr, asr, maghrib, isha, jumma }

/// One prayer's time as the masjid set it.
@immutable
class PrayerTime {
  const PrayerTime(this.prayer, this.time);

  final Prayer prayer;
  final TimeOfDay time;

  /// This prayer on [day] (only the date part of [day] is used).
  DateTime on(DateTime day) =>
      DateTime(day.year, day.month, day.day, time.hour, time.minute);
}

/// The prayer coming up and how long until it.
@immutable
class NextPrayer {
  const NextPrayer({
    required this.prayer,
    required this.at,
    required this.until,
  });

  final PrayerTime prayer;
  final DateTime at;
  final Duration until;
}

/// Reads a stored time: "05:00 AM", "5:00 pm", or 24-hour "17:00".
/// Returns null for empty or unreadable text.
TimeOfDay? parseNamazTime(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  final match = RegExp(
    r'^(\d{1,2}):(\d{2})(?:\s*([AaPp])\.?\s*[Mm]\.?)?$',
  ).firstMatch(trimmed);
  if (match == null) return null;

  var hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final period = match.group(3)?.toUpperCase();
  if (minute > 59) return null;
  if (period != null) {
    if (hour < 1 || hour > 12) return null;
    if (period == 'A' && hour == 12) hour = 0;
    if (period == 'P' && hour != 12) hour += 12;
  } else if (hour > 23) {
    return null;
  }
  return TimeOfDay(hour: hour, minute: minute);
}

/// The prayers of a day in order, only those with a time set. On Fridays
/// Jumma replaces Zuhr when the masjid set a Jumma time.
List<PrayerTime> prayersOfDay(
  NamazTimeSummary? times, {
  required bool isFriday,
}) {
  if (times == null) return const <PrayerTime>[];
  final jumma = parseNamazTime(times.jumma);
  final entries = <(Prayer, String?)>[
    (Prayer.fajr, times.fajr),
    if (isFriday && jumma != null)
      (Prayer.jumma, times.jumma)
    else
      (Prayer.zuhr, times.zuhr),
    (Prayer.asr, times.asr),
    (Prayer.maghrib, times.maghrib),
    (Prayer.isha, times.isha),
  ];
  return <PrayerTime>[
    for (final (prayer, text) in entries)
      if (parseNamazTime(text) case final time?) PrayerTime(prayer, time),
  ];
}

/// The next prayer after [now]: today's next one, or tomorrow's first.
/// Null when no times are set.
NextPrayer? nextPrayer(NamazTimeSummary? times, DateTime now) {
  final today = prayersOfDay(times, isFriday: now.weekday == DateTime.friday);
  for (final prayer in today) {
    final at = prayer.on(now);
    if (at.isAfter(now)) {
      return NextPrayer(prayer: prayer, at: at, until: at.difference(now));
    }
  }

  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  final tomorrowPrayers = prayersOfDay(
    times,
    isFriday: tomorrow.weekday == DateTime.friday,
  );
  if (tomorrowPrayers.isEmpty) return null;
  final first = tomorrowPrayers.first;
  final at = first.on(tomorrow);
  return NextPrayer(prayer: first, at: at, until: at.difference(now));
}

/// The stored form of a time, as the server's examples show it: "05:00 PM".
/// Always English AM/PM, whatever the app's language, so every device
/// reads it back the same way.
String formatNamazTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '${hour.toString().padLeft(2, '0')}:$minute $period';
}

/// [time] moved by [minutes], wrapping around midnight.
TimeOfDay shiftTime(TimeOfDay time, int minutes) {
  final total = (time.hour * 60 + time.minute + minutes) % (24 * 60);
  final wrapped = total < 0 ? total + 24 * 60 : total;
  return TimeOfDay(hour: wrapped ~/ 60, minute: wrapped % 60);
}

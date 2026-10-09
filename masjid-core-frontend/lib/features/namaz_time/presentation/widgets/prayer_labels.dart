import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/features/namaz_time/application/prayer_schedule.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Names, pictures, and countdown text for prayers, in the app's language.
extension PrayerLabels on Prayer {
  String label(AppLocalizations l10n) => switch (this) {
    Prayer.fajr => l10n.prayerFajr,
    Prayer.zuhr => l10n.prayerZuhr,
    Prayer.asr => l10n.prayerAsr,
    Prayer.maghrib => l10n.prayerMaghrib,
    Prayer.isha => l10n.prayerIsha,
    Prayer.jumma => l10n.prayerJumma,
  };

  /// The sun's position through the day; a mosque for Jumma.
  IconData get icon => switch (this) {
    Prayer.fajr => AppIcons.fajr,
    Prayer.zuhr => AppIcons.dhuhr,
    Prayer.asr => AppIcons.asr,
    Prayer.maghrib => AppIcons.maghrib,
    Prayer.isha => AppIcons.isha,
    Prayer.jumma => AppIcons.jumma,
  };
}

/// "in 1 h 20 min" / "in 5 min", rounded up to the next minute.
String countdownText(AppLocalizations l10n, Duration until) {
  final totalMinutes = (until.inSeconds / 60).ceil().clamp(1, 24 * 60);
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return hours == 0
      ? l10n.inMinutes(minutes)
      : l10n.inHoursMinutes(hours, minutes);
}

/// The time in the device's style (4:45 PM or 16:45), in the app's
/// language.
String prayerTimeText(BuildContext context, TimeOfDay time) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      time,
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

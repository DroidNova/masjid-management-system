import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';

/// "Today", "Yesterday", or the date (7 Oct 2026): how lists name days.
/// [today] overrides "now" in tests.
String dayLabel(AppLocalizations l10n, DateTime date, {DateTime? today}) {
  final now = DateUtils.dateOnly(today ?? DateTime.now());
  final day = DateUtils.dateOnly(date.toLocal());
  final days = now.difference(day).inDays;
  if (days == 0) return l10n.today;
  if (days == 1) return l10n.yesterday;
  return AppFormat.date(date);
}

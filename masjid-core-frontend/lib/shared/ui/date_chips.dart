import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/adaptive_pickers.dart';
import 'package:masjid_core_frontend/shared/ui/app_icons.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// Pick a date without typing: "Today", "Yesterday", or "Pick date"
/// (rule 8). Most entries happen today, so that is one tap.
class DateChips extends StatelessWidget {
  const DateChips({
    super.key,
    required this.value,
    required this.onChanged,
    required this.first,
    this.last,
    this.today,
  });

  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateTime first;

  /// Defaults to today: most entries cannot be in the future.
  final DateTime? last;

  /// Overrides "now" in tests.
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final todayDate = DateUtils.dateOnly(today ?? DateTime.now());
    final yesterday = todayDate.subtract(const Duration(days: 1));
    final lastDate = last ?? todayDate;
    final isToday = DateUtils.isSameDay(value, todayDate);
    final isYesterday = DateUtils.isSameDay(value, yesterday);
    final isOther = !isToday && !isYesterday;

    Widget chip({
      required String label,
      required bool selected,
      required VoidCallback onTap,
      IconData? icon,
    }) => ChoiceChip(
      label: Text(label),
      avatar: icon == null ? null : Icon(icon, size: 20),
      selected: selected,
      onSelected: (_) => onTap(),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );

    return Wrap(
      spacing: AppSpace.s,
      runSpacing: AppSpace.s,
      children: <Widget>[
        if (!todayDate.isAfter(lastDate))
          chip(
            label: l10n.today,
            selected: isToday,
            onTap: () => onChanged(todayDate),
          ),
        if (!yesterday.isBefore(first) && !yesterday.isAfter(lastDate))
          chip(
            label: l10n.yesterday,
            selected: isYesterday,
            onTap: () => onChanged(yesterday),
          ),
        chip(
          label: isOther ? AppFormat.date(value) : l10n.pickDate,
          icon: AppIcons.calendar,
          selected: isOther,
          onTap: () async {
            final picked = await pickDate(
              context,
              initial: value,
              first: first,
              last: lastDate,
            );
            if (picked != null) onChanged(DateUtils.dateOnly(picked));
          },
        ),
      ],
    );
  }
}

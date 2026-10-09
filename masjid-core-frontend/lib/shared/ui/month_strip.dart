import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// Months as a row of chips, this month first, then going back: swipe and
/// tap instead of two dropdowns. The selected month is always shown, even
/// when it is older than [count] months.
class MonthStrip extends StatelessWidget {
  const MonthStrip({
    super.key,
    required this.month,
    required this.year,
    required this.onSelected,
    this.count = 12,
    this.today,
    this.tone = AppTones.salary,
  });

  final int month;
  final int year;
  final void Function(int month, int year) onSelected;
  final int count;
  final AppTone tone;

  /// Overrides "now" in tests.
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final now = today ?? DateTime.now();
    final months = <DateTime>[
      for (var i = 0; i < count; i++) DateTime(now.year, now.month - i),
    ];
    if (!months.any((m) => m.month == month && m.year == year)) {
      months.add(DateTime(year, month));
    }
    final format = DateFormat('MMM y', 'en_IN');

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          for (final date in months) ...<Widget>[
            ChoiceChip(
              label: Text(format.format(date)),
              selected: date.month == month && date.year == year,
              selectedColor: tone.container,
              onSelected: (_) => onSelected(date.month, date.year),
            ),
            const SizedBox(width: AppSpace.s),
          ],
        ],
      ),
    );
  }
}

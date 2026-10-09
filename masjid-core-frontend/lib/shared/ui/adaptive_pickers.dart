import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/responsive.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// Date picker: iOS scroll wheels on iPhones and iPads, the Material
/// calendar on Android and the website.
Future<DateTime?> pickDate(
  BuildContext context, {
  required DateTime initial,
  required DateTime first,
  required DateTime last,
}) {
  final start = _clamp(initial, first, last);
  if (useCupertino(context)) {
    return _showWheel<DateTime>(
      context,
      initial: start,
      picker: (onChanged) => CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: start,
        minimumDate: first,
        maximumDate: last,
        onDateTimeChanged: onChanged,
      ),
      result: DateUtils.dateOnly,
    );
  }
  return showDatePicker(
    context: context,
    initialDate: start,
    firstDate: first,
    lastDate: last,
  );
}

/// Time picker: iOS wheels, or the Material clock dial elsewhere.
Future<TimeOfDay?> pickTime(
  BuildContext context, {
  required TimeOfDay initial,
}) {
  if (useCupertino(context)) {
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
      initial.hour,
      initial.minute,
    );
    return _showWheel<TimeOfDay>(
      context,
      initial: start,
      picker: (onChanged) => CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        initialDateTime: start,
        use24hFormat: MediaQuery.alwaysUse24HourFormatOf(context),
        onDateTimeChanged: onChanged,
      ),
      result: TimeOfDay.fromDateTime,
    );
  }
  return showTimePicker(context: context, initialTime: initial);
}

DateTime _clamp(DateTime value, DateTime first, DateTime last) {
  if (value.isBefore(first)) return first;
  if (value.isAfter(last)) return last;
  return value;
}

Future<T?> _showWheel<T>(
  BuildContext context, {
  required DateTime initial,
  required Widget Function(ValueChanged<DateTime> onChanged) picker,
  required T Function(DateTime value) result,
}) {
  final l10n = AppLocalizations.of(context);
  var selected = initial;
  return showCupertinoModalPopup<T>(
    context: context,
    builder: (popupContext) => Container(
      color: CupertinoColors.systemBackground.resolveFrom(popupContext),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CupertinoButton(
                  onPressed: () => Navigator.of(popupContext).pop(),
                  child: Text(l10n.cancel),
                ),
                CupertinoButton(
                  onPressed: () =>
                      Navigator.of(popupContext).pop(result(selected)),
                  child: Text(
                    l10n.done,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            SizedBox(height: 260, child: picker((value) => selected = value)),
            const SizedBox(height: AppSpace.s),
          ],
        ),
      ),
    ),
  );
}

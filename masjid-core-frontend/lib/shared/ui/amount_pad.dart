import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/number_keypad.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// Enter a rupee amount with big keys instead of the phone keyboard
/// (rule 8). Quick chips set common amounts in one tap. On the website the
/// computer keyboard works too (digits, dot, Backspace).
///
/// [value] is the typed text ("1250", "99.5"); turn it into a number with
/// [AmountPad.parse].
class AmountPad extends StatelessWidget {
  const AmountPad({
    super.key,
    required this.value,
    required this.onChanged,
    this.quickAmounts = const <int>[100, 500, 1000],
    this.allowDecimal = true,
    this.autofocus = true,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final List<int> quickAmounts;
  final bool allowDecimal;
  final bool autofocus;

  static const String backspaceKey = NumberKeypad.backspace;
  static const int maxWholeDigits = 9;

  /// The text after pressing [key] (a digit, '.', or [backspaceKey]).
  /// Keeps at most two decimals and [maxWholeDigits] whole digits, and never
  /// a leading zero.
  static String applyKey(
    String current,
    String key, {
    bool allowDecimal = true,
  }) {
    if (key == backspaceKey) {
      return current.isEmpty ? '' : current.substring(0, current.length - 1);
    }
    if (key == '.') {
      if (!allowDecimal || current.contains('.')) return current;
      return current.isEmpty ? '0.' : '$current.';
    }
    if (!RegExp(r'^[0-9]$').hasMatch(key)) return current;

    final dot = current.indexOf('.');
    if (dot >= 0) {
      return current.length - dot - 1 >= 2 ? current : '$current$key';
    }
    if (current == '0') return key;
    if (current.length >= maxWholeDigits) return current;
    return '$current$key';
  }

  /// [amount] as the pad types it: "500" for 500.0, "500.5" for 500.5, and
  /// empty for zero (so the pad starts blank).
  static String textOf(double amount) {
    if (amount <= 0) return '';
    if (amount.truncateToDouble() == amount) return amount.toStringAsFixed(0);
    return amount.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');
  }

  /// The amount, or null when nothing (or only zero) is entered.
  static num? parse(String value) {
    final cleaned = value.endsWith('.')
        ? value.substring(0, value.length - 1)
        : value;
    final amount = num.tryParse(cleaned);
    return amount == null || amount <= 0 ? null : amount;
  }

  /// "₹1,25,000.5" while typing: Indian grouping on the whole part, the
  /// decimals exactly as typed.
  static String display(String value) {
    if (value.isEmpty) return '₹0';
    final dot = value.indexOf('.');
    final whole = dot >= 0 ? value.substring(0, dot) : value;
    final rest = dot >= 0 ? value.substring(dot) : '';
    final grouped = NumberFormat.decimalPattern(
      'en_IN',
    ).format(int.tryParse(whole) ?? 0);
    return '₹$grouped$rest';
  }

  void _press(String key) =>
      onChanged(applyKey(value, key, allowDecimal: allowDecimal));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final empty = value.isEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          liveRegion: true,
          label: empty ? l10n.amountHint : null,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              display(value),
              textDirection: TextDirection.ltr,
              style: textTheme.displayMedium?.copyWith(
                color: empty ? AppColors.textSecondary : null,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpace.m),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpace.s,
          runSpacing: AppSpace.s,
          children: quickAmounts
              .map(
                (amount) => ActionChip(
                  label: Text(
                    display('$amount'),
                    textDirection: TextDirection.ltr,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onChanged('$amount');
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpace.m),
        NumberKeypad(
          onKey: _press,
          extraKey: allowDecimal ? '.' : null,
          autofocus: autofocus,
        ),
      ],
    );
  }
}

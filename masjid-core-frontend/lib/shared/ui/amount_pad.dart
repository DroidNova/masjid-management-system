import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/app_icons.dart';
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

  static const String backspaceKey = 'backspace';
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

  void _press(String key) {
    HapticFeedback.selectionClick();
    onChanged(applyKey(value, key, allowDecimal: allowDecimal));
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace) {
      _press(backspaceKey);
      return KeyEventResult.handled;
    }
    final character = event.character;
    if (character != null && RegExp(r'^[0-9.]$').hasMatch(character)) {
      _press(character);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final empty = value.isEmpty;

    Widget key(String label, {String? keyValue, IconData? icon}) {
      final pressed = keyValue ?? label;
      return Padding(
        padding: const EdgeInsets.all(AppSpace.xs),
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.m),
            side: const BorderSide(color: AppColors.border),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.m),
            onTap: () => _press(pressed),
            child: SizedBox(
              height: 64,
              child: Center(
                child: icon != null
                    ? Icon(icon, size: 28, semanticLabel: l10n.deleteDigit)
                    : Text(label, style: textTheme.headlineMedium),
              ),
            ),
          ),
        ),
      );
    }

    Widget row(List<Widget> keys) =>
        Row(children: keys.map((k) => Expanded(child: k)).toList());

    return Focus(
      autofocus: autofocus,
      onKeyEvent: _onKey,
      // Number pads keep 1-2-3 left to right in Urdu too.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Semantics(
              liveRegion: true,
              label: empty ? l10n.amountHint : null,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  display(value),
                  style: textTheme.displayMedium?.copyWith(
                    color: empty ? AppColors.textSecondary : null,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
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
                      label: Text(display('$amount')),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onChanged('$amount');
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpace.m),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: <Widget>[
                  row(<Widget>[key('1'), key('2'), key('3')]),
                  row(<Widget>[key('4'), key('5'), key('6')]),
                  row(<Widget>[key('7'), key('8'), key('9')]),
                  row(<Widget>[
                    allowDecimal ? key('.') : const SizedBox.shrink(),
                    key('0'),
                    key('', keyValue: backspaceKey, icon: AppIcons.backspace),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

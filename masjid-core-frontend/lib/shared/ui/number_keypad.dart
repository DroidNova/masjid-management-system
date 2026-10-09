import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/app_icons.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// Big on-screen number keys (1–9, 0, backspace, and an optional extra key
/// such as '.'). Used for phone numbers, OTP codes, and amounts, so typing
/// numbers looks and works the same everywhere (rule 8).
///
/// The computer keyboard works too while it has focus: digits, the extra
/// key's character, and Backspace. Keys keep 1-2-3 left to right in Urdu.
class NumberKeypad extends StatelessWidget {
  const NumberKeypad({
    super.key,
    required this.onKey,
    this.extraKey,
    this.autofocus = true,
    this.enabled = true,
  });

  /// Called with a digit, [extraKey], or [backspace].
  final ValueChanged<String> onKey;

  /// Shown bottom-left, for example '.' for amounts. Null leaves it empty.
  final String? extraKey;
  final bool autofocus;
  final bool enabled;

  static const String backspace = 'backspace';

  void _press(String key) {
    if (!enabled) return;
    HapticFeedback.selectionClick();
    onKey(key);
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _press(backspace);
      return KeyEventResult.handled;
    }
    final character = event.character;
    if (character == null) return KeyEventResult.ignored;
    if (RegExp(r'^[0-9]$').hasMatch(character) || character == extraKey) {
      _press(character);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final extra = extraKey;

    Widget key(String label, {String? value, IconData? icon}) {
      return Padding(
        padding: const EdgeInsets.all(AppSpace.xs),
        child: Material(
          color: enabled ? AppColors.surface : AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.m),
            side: const BorderSide(color: AppColors.border),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.m),
            onTap: enabled ? () => _press(value ?? label) : null,
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
      onKeyEvent: _onKeyEvent,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              row(<Widget>[key('1'), key('2'), key('3')]),
              row(<Widget>[key('4'), key('5'), key('6')]),
              row(<Widget>[key('7'), key('8'), key('9')]),
              row(<Widget>[
                extra == null ? const SizedBox.shrink() : key(extra),
                key('0'),
                key('', value: backspace, icon: AppIcons.backspace),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

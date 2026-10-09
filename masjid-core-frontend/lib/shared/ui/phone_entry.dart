import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/models/country_code.dart';
import 'package:masjid_core_frontend/shared/ui/country_picker.dart';
import 'package:masjid_core_frontend/shared/ui/number_keypad.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// A phone number typed on big on-screen keys, with the country (India by
/// default) as a button in front. Used where the phone number is the whole
/// screen: login and tracking a masjid request.
///
/// [digits] is the national number as digits only; join it with the
/// country using `normalizePhone`.
class PhoneEntry extends StatelessWidget {
  const PhoneEntry({
    super.key,
    required this.country,
    required this.digits,
    required this.onCountryChanged,
    required this.onDigitsChanged,
    this.autofocus = true,
    this.enabled = true,
    this.onSubmit,
  });

  final CountryCode country;
  final String digits;
  final ValueChanged<CountryCode> onCountryChanged;
  final ValueChanged<String> onDigitsChanged;
  final bool autofocus;
  final bool enabled;

  /// Enter on a computer keyboard; see [NumberKeypad.onSubmit].
  final VoidCallback? onSubmit;

  static int maxLengthFor(CountryCode country) => country.maxLength ?? 15;
  static int minLengthFor(CountryCode country) => country.minLength ?? 6;

  static bool isValid(CountryCode country, String digits) =>
      digits.length >= minLengthFor(country) &&
      digits.length <= maxLengthFor(country);

  /// The digits after pressing [key] (a digit or [NumberKeypad.backspace]).
  static String applyKey(String digits, String key, {required int maxLength}) {
    if (key == NumberKeypad.backspace) {
      return digits.isEmpty ? '' : digits.substring(0, digits.length - 1);
    }
    if (!RegExp(r'^[0-9]$').hasMatch(key) || digits.length >= maxLength) {
      return digits;
    }
    return '$digits$key';
  }

  /// "98765 43210": a space after the fifth digit, easy to read back.
  static String format(String digits) => digits.length <= 5
      ? digits
      : '${digits.substring(0, 5)} ${digits.substring(5)}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final empty = digits.isEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(AppSpace.s),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.m),
              border: Border.all(color: AppTones.brand.color, width: 2),
            ),
            child: Row(
              children: <Widget>[
                Tooltip(
                  message: l10n.changeCountry,
                  child: TextButton(
                    onPressed: enabled
                        ? () async {
                            final picked = await showCountryPicker(context);
                            if (picked != null) onCountryChanged(picked);
                          }
                        : null,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.m,
                      ),
                    ),
                    child: Text(
                      '${country.flagEmoji} ${country.dialCode}',
                      style: textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    label: l10n.phoneNumber,
                    value: digits,
                    excludeSemantics: true,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        empty ? '00000 00000' : format(digits),
                        style: textTheme.headlineMedium?.copyWith(
                          color: empty ? AppColors.border : null,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.l),
        NumberKeypad(
          autofocus: autofocus,
          enabled: enabled,
          onSubmit: onSubmit,
          onKey: (key) => onDigitsChanged(
            applyKey(digits, key, maxLength: maxLengthFor(country)),
          ),
        ),
      ],
    );
  }
}

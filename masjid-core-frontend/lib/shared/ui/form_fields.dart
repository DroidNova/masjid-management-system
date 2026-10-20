import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/models/country_code.dart';
import 'package:masjid_core_frontend/shared/ui/app_icons.dart';
import 'package:masjid_core_frontend/shared/ui/app_sheet.dart';
import 'package:masjid_core_frontend/shared/ui/country_picker.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';
import 'package:masjid_core_frontend/shared/utils/country_code_utils.dart';

/// Form fields with the app's look and messages in the app's language.
/// Labels say "(optional)" on optional fields instead of marking required
/// ones with "*", which people who read little may not know.

/// A text field with an icon in front of the label.
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.inputFormatters,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.words,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.l),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: maxLines > 1
            ? TextInputAction.newline
            : textInputAction,
        maxLines: maxLines,
        minLines: 1,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        autofillHints: autofillHints,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          counterText: '',
        ),
      ),
    );
  }
}

/// Age as a whole number; [validator] checks the range. Type it, or scroll
/// the wheel (see [NumberFormField]).
class AgeFormField extends StatelessWidget {
  const AgeFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return NumberFormField(
      controller: controller,
      label: label,
      icon: AppIcons.age,
      validator: validator,
      min: 1,
      max: 120,
      startAt: 30,
    );
  }
}

/// A whole number that can be typed (digits only) or picked: the button at
/// the end opens a scroll wheel from [min] to [max], starting at the
/// current value or [startAt]. Numbers beyond the wheel can still be typed.
class NumberFormField extends StatelessWidget {
  const NumberFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.min,
    required this.max,
    required this.startAt,
    this.validator,
    this.maxLength = 3,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int min;
  final int max;
  final int startAt;
  final FormFieldValidator<String>? validator;
  final int maxLength;

  Future<void> _pick(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final current = int.tryParse(controller.text.trim());
    final picked = await showNumberWheel(
      context,
      title: label,
      min: min,
      max: max,
      initial: (current ?? startAt).clamp(min, max),
    );
    if (picked != null) controller.text = '$picked';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.l),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        maxLength: maxLength,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          counterText: '',
          suffixIcon: IconButton(
            tooltip: l10n.scrollToChoose,
            onPressed: () => _pick(context),
            icon: const Icon(Icons.unfold_more_rounded),
          ),
        ),
      ),
    );
  }
}

/// A sheet with a scroll wheel of numbers; returns the chosen one, or null
/// when closed without Done.
Future<int?> showNumberWheel(
  BuildContext context, {
  required String title,
  required int min,
  required int max,
  required int initial,
}) {
  var chosen = initial;
  final controller = FixedExtentScrollController(initialItem: initial - min);
  return showAppSheet<int>(
    context,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      final textTheme = Theme.of(sheetContext).textTheme;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, textAlign: TextAlign.center, style: textTheme.titleLarge),
          const SizedBox(height: AppSpace.m),
          SizedBox(
            height: 220,
            child: CupertinoPicker(
              scrollController: controller,
              itemExtent: 48,
              onSelectedItemChanged: (index) => chosen = min + index,
              children: <Widget>[
                for (var value = min; value <= max; value++)
                  Center(child: Text('$value', style: textTheme.headlineSmall)),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.l),
          FilledButton(
            onPressed: () => Navigator.of(sheetContext).pop(chosen),
            child: Text(l10n.done),
          ),
        ],
      );
    },
  ).whenComplete(controller.dispose);
}

/// Country button plus phone number. The number is checked against the
/// country's length; [extraValidator] gets the full number (`+919876543210`)
/// for other checks, such as "already used".
class PhoneFormField extends StatelessWidget {
  const PhoneFormField({
    super.key,
    required this.controller,
    required this.country,
    required this.onCountryChanged,
    required this.label,
    this.isRequired = true,
    this.extraValidator,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final CountryCode country;
  final ValueChanged<CountryCode> onCountryChanged;
  final String label;
  final bool isRequired;
  final String? Function(String normalizedPhone)? extraValidator;
  final TextInputAction textInputAction;

  String? _validate(AppLocalizations l10n, String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return isRequired ? l10n.fieldRequired : null;
    final min = country.minLength ?? 6;
    final max = country.maxLength ?? 15;
    if (digits.length < min || digits.length > max) return l10n.invalidPhone;
    return extraValidator?.call(
      normalizePhone(countryCode: country, nationalNumber: digits),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final direction = Directionality.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.l),
      // "+91" then the number, left to right, in every language.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Tooltip(
              message: l10n.changeCountry,
              child: OutlinedButton(
                onPressed: () async {
                  final picked = await showCountryPicker(context);
                  if (picked != null) onCountryChanged(picked);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 58),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.m),
                ),
                child: Text('${country.flagEmoji} ${country.dialCode}'),
              ),
            ),
            const SizedBox(width: AppSpace.s),
            Expanded(
              child: Directionality(
                textDirection: direction,
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  textInputAction: textInputAction,
                  textDirection: TextDirection.ltr,
                  autofillHints: const <String>[
                    AutofillHints.telephoneNumberNational,
                  ],
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(country.maxLength ?? 15),
                  ],
                  validator: (value) => _validate(l10n, value),
                  decoration: InputDecoration(
                    labelText: label,
                    prefixIcon: const Icon(AppIcons.phone),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Male / Female / Other as big chips with pictures, instead of a dropdown.
/// Values are the API's `MALE`, `FEMALE`, `OTHER`.
class GenderFormField extends StatelessWidget {
  const GenderFormField({
    super.key,
    required this.value,
    required this.onChanged,
    this.isRequired = true,
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = <(String, String, IconData)>[
      ('MALE', l10n.genderMale, AppIcons.male),
      ('FEMALE', l10n.genderFemale, AppIcons.female),
      ('OTHER', l10n.genderOther, AppIcons.otherGender),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.l),
      child: FormField<String>(
        // Rebuilt when the value changes from outside.
        key: ValueKey<String?>(value),
        initialValue: value,
        validator: (selected) =>
            isRequired && selected == null ? l10n.fieldRequired : null,
        builder: (field) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.gender, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpace.s),
            Wrap(
              spacing: AppSpace.s,
              runSpacing: AppSpace.s,
              children: options
                  .map(
                    (option) => ChoiceChip(
                      avatar: Icon(option.$3),
                      label: Text(option.$2),
                      selected: field.value == option.$1,
                      onSelected: (_) {
                        field.didChange(option.$1);
                        onChanged(option.$1);
                      },
                    ),
                  )
                  .toList(),
            ),
            if (field.errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpace.xs),
                child: Text(
                  field.errorText!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

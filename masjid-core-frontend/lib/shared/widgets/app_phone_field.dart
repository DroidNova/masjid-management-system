import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_core_frontend/shared/constants/country_codes.dart';
import 'package:platform_core_frontend/shared/models/country_code.dart';
import 'package:platform_core_frontend/shared/utils/country_code_utils.dart';

class AppPhoneField extends StatefulWidget {
  const AppPhoneField({
    super.key,
    required this.phoneController,
    this.initialCountry,
    this.onCountryChanged,
    required this.label,
    this.hint,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.onNormalizedPhoneChanged,
    this.textInputAction,
  });

  final TextEditingController phoneController;
  final CountryCode? initialCountry;
  final ValueChanged<CountryCode>? onCountryChanged;
  final String label;
  final String? hint;
  final bool enabled;
  final bool required;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onNormalizedPhoneChanged;
  final TextInputAction? textInputAction;

  @override
  State<AppPhoneField> createState() => _AppPhoneFieldState();
}

class _AppPhoneFieldState extends State<AppPhoneField> {
  late CountryCode _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry ?? getDefaultCountryCode();
    widget.phoneController.addListener(_notifyNormalizedPhone);
  }

  @override
  void didUpdateWidget(covariant AppPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCountry != null &&
        widget.initialCountry!.isoCode != _selectedCountry.isoCode) {
      _selectedCountry = widget.initialCountry!;
    }
    if (oldWidget.phoneController != widget.phoneController) {
      oldWidget.phoneController.removeListener(_notifyNormalizedPhone);
      widget.phoneController.addListener(_notifyNormalizedPhone);
    }
  }

  @override
  void dispose() {
    widget.phoneController.removeListener(_notifyNormalizedPhone);
    super.dispose();
  }

  void _notifyNormalizedPhone() {
    widget.onNormalizedPhoneChanged?.call(
      normalizePhone(
        countryCode: _selectedCountry,
        nationalNumber: widget.phoneController.text,
      ),
    );
  }

  Future<void> _selectCountry() async {
    if (!widget.enabled) return;
    final selected = await showDialog<CountryCode>(
      context: context,
      builder: (context) => const _CountryCodeDialog(),
    );
    if (selected == null) return;
    setState(() => _selectedCountry = selected);
    widget.onCountryChanged?.call(selected);
    _notifyNormalizedPhone();
  }

  String? _validate(String? value) {
    final custom = widget.validator?.call(value);
    if (custom != null) return custom;
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return widget.required ? 'Phone number is required' : null;
    final min = _selectedCountry.minLength ?? 6;
    final max = _selectedCountry.maxLength ?? 15;
    if (digits.length < min || digits.length > max) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final maxLength = _selectedCountry.maxLength;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 116,
          child: OutlinedButton(
            onPressed: widget.enabled ? _selectCountry : null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
            ),
            child: Text('${_selectedCountry.flagEmoji} ${_selectedCountry.dialCode}'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: widget.phoneController,
            enabled: widget.enabled,
            decoration: InputDecoration(
              labelText: widget.required ? '${widget.label} *' : widget.label,
              hintText: widget.hint,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            textInputAction: widget.textInputAction,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
            ],
            validator: _validate,
          ),
        ),
      ],
    );
  }
}

class _CountryCodeDialog extends StatefulWidget {
  const _CountryCodeDialog();

  @override
  State<_CountryCodeDialog> createState() => _CountryCodeDialogState();
}

class _CountryCodeDialogState extends State<_CountryCodeDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final countries = appCountryCodes.where((country) {
      final q = _query.toLowerCase();
      return country.name.toLowerCase().contains(q) ||
          country.isoCode.toLowerCase().contains(q) ||
          country.dialCode.contains(q);
    }).toList();
    return AlertDialog(
      title: const Text('Select country code'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search country or dial code',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  final country = countries[index];
                  return ListTile(
                    leading: Text(country.flagEmoji),
                    title: Text(country.name),
                    trailing: Text(country.dialCode),
                    onTap: () => Navigator.of(context).pop(country),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

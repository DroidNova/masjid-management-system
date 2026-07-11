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
    this.label = 'Phone number',
    this.hint,
    this.enabled = true,
    this.isRequired = false,
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
  final bool isRequired;
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
    widget.phoneController.addListener(_notifyNormalizedChanged);
  }

  @override
  void didUpdateWidget(covariant AppPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phoneController != widget.phoneController) {
      oldWidget.phoneController.removeListener(_notifyNormalizedChanged);
      widget.phoneController.addListener(_notifyNormalizedChanged);
    }
    if (widget.initialCountry != null && widget.initialCountry != _selectedCountry) {
      _selectedCountry = widget.initialCountry!;
    }
  }

  @override
  void dispose() {
    widget.phoneController.removeListener(_notifyNormalizedChanged);
    super.dispose();
  }

  String get normalizedPhone => normalizePhone(countryCode: _selectedCountry, nationalNumber: widget.phoneController.text);

  void _notifyNormalizedChanged() => widget.onNormalizedPhoneChanged?.call(normalizedPhone);

  Future<void> _selectCountry() async {
    final selected = await showDialog<CountryCode>(
      context: context,
      builder: (context) => const _CountryCodeDialog(),
    );
    if (selected == null) return;
    setState(() => _selectedCountry = selected);
    widget.onCountryChanged?.call(selected);
    _notifyNormalizedChanged();
  }

  String? _validate(String? value) {
    final custom = widget.validator?.call(value);
    if (custom != null) return custom;
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return widget.isRequired ? 'Phone number is required' : null;
    final min = _selectedCountry.minLength ?? 6;
    final max = _selectedCountry.maxLength ?? 15;
    if (digits.length < min || digits.length > max) return 'Enter a valid phone number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 116,
          child: OutlinedButton(
            onPressed: widget.enabled ? _selectCountry : null,
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(0, 56)),
            child: Text('${_selectedCountry.flagEmoji} ${_selectedCountry.dialCode}', overflow: TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: widget.phoneController,
            enabled: widget.enabled,
            decoration: InputDecoration(labelText: widget.label, hintText: widget.hint, border: const OutlineInputBorder()),
            keyboardType: TextInputType.phone,
            textInputAction: widget.textInputAction,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              if (_selectedCountry.maxLength != null) LengthLimitingTextInputFormatter(_selectedCountry.maxLength),
            ],
            validator: _validate,
          ),
        ),
      ],
    );
  }
}

class _CountryCodeDialog extends StatefulWidget { const _CountryCodeDialog(); @override State<_CountryCodeDialog> createState() => _CountryCodeDialogState(); }
class _CountryCodeDialogState extends State<_CountryCodeDialog> {
  String _query = '';
  @override Widget build(BuildContext context) {
    final filtered = countryCodes.where((c) => '${c.name} ${c.isoCode} ${c.dialCode}'.toLowerCase().contains(_query.toLowerCase())).toList();
    return AlertDialog(
      title: const Text('Select country code'),
      content: SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: const InputDecoration(hintText: 'Search country or code'), onChanged: (v) => setState(() => _query = v)),
        const SizedBox(height: 12),
        Flexible(child: ListView.builder(shrinkWrap: true, itemCount: filtered.length, itemBuilder: (context, index) { final c = filtered[index]; return ListTile(leading: Text(c.flagEmoji), title: Text(c.name), trailing: Text(c.dialCode), onTap: () => Navigator.of(context).pop(c)); })),
      ])),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:platform_core_frontend/shared/constants/country_codes.dart';
import 'package:platform_core_frontend/shared/models/country_code.dart';

class AppCountryDropdown extends StatelessWidget {
  const AppCountryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Country *',
    this.enabled = true,
  });

  final CountryCode value;
  final ValueChanged<CountryCode> onChanged;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CountryCode>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: countryCodes
          .map(
            (country) => DropdownMenuItem<CountryCode>(
              value: country,
              child: Text('${country.flagEmoji} ${country.name}'),
            ),
          )
          .toList(),
      onChanged: enabled ? (country) { if (country != null) onChanged(country); } : null,
      validator: (country) => country == null ? 'Country is required.' : null,
    );
  }
}

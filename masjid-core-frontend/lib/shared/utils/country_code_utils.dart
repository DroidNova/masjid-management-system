import 'package:platform_core_frontend/shared/constants/country_codes.dart';
import 'package:platform_core_frontend/shared/models/country_code.dart';

CountryCode getDefaultCountryCode() => indiaCountryCode;

CountryCode? findByIsoCode(String? isoCode) {
  final iso = isoCode?.toUpperCase();
  if (iso == null || iso.isEmpty) return null;
  for (final c in countryCodes) { if (c.isoCode == iso) return c; }
  return null;
}

CountryCode? findByDialCode(String dialCode) {
  for (final c in countryCodes) { if (c.dialCode == dialCode) return c; }
  return null;
}

String normalizePhone({required CountryCode countryCode, required String nationalNumber}) => '${countryCode.dialCode}${nationalNumber.replaceAll(RegExp(r'\D'), '')}';

PhoneNumberParts parsePhoneNumber(String? value) {
  final raw = (value ?? '').trim();
  final compact = raw.replaceAll(RegExp(r'[\s\-()]'), '');
  if (compact.startsWith('+')) {
    final sorted = [...countryCodes]..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));
    for (final c in sorted) {
      if (compact.startsWith(c.dialCode)) {
        return PhoneNumberParts(countryCode: c, nationalNumber: compact.substring(c.dialCode.length).replaceAll(RegExp(r'\D'), ''));
      }
    }
  }
  return PhoneNumberParts(countryCode: indiaCountryCode, nationalNumber: raw.replaceAll(RegExp(r'\D'), ''));
}

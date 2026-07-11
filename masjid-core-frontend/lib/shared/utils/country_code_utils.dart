import 'dart:ui';

import 'package:platform_core_frontend/shared/constants/country_codes.dart';
import 'package:platform_core_frontend/shared/models/country_code.dart';

CountryCode getDefaultCountryCode() {
  final isoCode = PlatformDispatcher.instance.locale.countryCode;
  if (isoCode != null) return findByIsoCode(isoCode) ?? appCountryCodes.first;
  return appCountryCodes.first;
}

CountryCode? findByIsoCode(String isoCode) {
  for (final country in appCountryCodes) {
    if (country.isoCode.toUpperCase() == isoCode.toUpperCase()) return country;
  }
  return null;
}

CountryCode? findByDialCode(String dialCode) {
  for (final country in appCountryCodes) {
    if (country.dialCode == dialCode) return country;
  }
  return null;
}

String normalizePhone({
  required CountryCode countryCode,
  required String nationalNumber,
}) {
  return '${countryCode.dialCode}${nationalNumber.replaceAll(RegExp(r'\D'), '')}';
}

PhoneNumberParts parsePhoneNumber(String? value) {
  final raw = (value ?? '').trim();
  final compact = raw.replaceAll(RegExp(r'[\s\-()]'), '');
  if (compact.startsWith('+')) {
    final countries = List<CountryCode>.from(appCountryCodes)
      ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));
    for (final country in countries) {
      if (compact.startsWith(country.dialCode)) {
        return PhoneNumberParts(
          countryCode: country,
          nationalNumber: compact.substring(country.dialCode.length).replaceAll(RegExp(r'\D'), ''),
        );
      }
    }
  }
  return PhoneNumberParts(
    countryCode: appCountryCodes.first,
    nationalNumber: raw.replaceAll(RegExp(r'\D'), ''),
  );
}

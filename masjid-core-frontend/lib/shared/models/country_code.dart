class CountryCode {
  const CountryCode({
    required this.name,
    required this.isoCode,
    required this.dialCode,
    required this.flagEmoji,
    this.minLength,
    this.maxLength,
  });

  final String name;
  final String isoCode;
  final String dialCode;
  final String flagEmoji;
  final int? minLength;
  final int? maxLength;
}

class PhoneNumberParts {
  const PhoneNumberParts({required this.countryCode, required this.nationalNumber});
  final CountryCode countryCode;
  final String nationalNumber;
}

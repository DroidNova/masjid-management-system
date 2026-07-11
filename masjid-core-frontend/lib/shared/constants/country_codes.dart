import 'package:platform_core_frontend/shared/models/country_code.dart';

const CountryCode indiaCountryCode = CountryCode(name: 'India', isoCode: 'IN', dialCode: '+91', flagEmoji: '🇮🇳', minLength: 10, maxLength: 10);

const List<CountryCode> countryCodes = <CountryCode>[
  indiaCountryCode,
  CountryCode(name: 'Saudi Arabia', isoCode: 'SA', dialCode: '+966', flagEmoji: '🇸🇦', minLength: 8, maxLength: 9),
  CountryCode(name: 'United Arab Emirates', isoCode: 'AE', dialCode: '+971', flagEmoji: '🇦🇪', minLength: 8, maxLength: 9),
  CountryCode(name: 'Qatar', isoCode: 'QA', dialCode: '+974', flagEmoji: '🇶🇦', minLength: 8, maxLength: 8),
  CountryCode(name: 'Kuwait', isoCode: 'KW', dialCode: '+965', flagEmoji: '🇰🇼', minLength: 8, maxLength: 8),
  CountryCode(name: 'Oman', isoCode: 'OM', dialCode: '+968', flagEmoji: '🇴🇲', minLength: 8, maxLength: 8),
  CountryCode(name: 'Bahrain', isoCode: 'BH', dialCode: '+973', flagEmoji: '🇧🇭', minLength: 8, maxLength: 8),
  CountryCode(name: 'United States', isoCode: 'US', dialCode: '+1', flagEmoji: '🇺🇸', minLength: 10, maxLength: 10),
  CountryCode(name: 'Canada', isoCode: 'CA', dialCode: '+1', flagEmoji: '🇨🇦', minLength: 10, maxLength: 10),
  CountryCode(name: 'United Kingdom', isoCode: 'GB', dialCode: '+44', flagEmoji: '🇬🇧', minLength: 10, maxLength: 10),
  CountryCode(name: 'Pakistan', isoCode: 'PK', dialCode: '+92', flagEmoji: '🇵🇰', minLength: 10, maxLength: 10),
  CountryCode(name: 'Bangladesh', isoCode: 'BD', dialCode: '+880', flagEmoji: '🇧🇩', minLength: 10, maxLength: 10),
  CountryCode(name: 'Nepal', isoCode: 'NP', dialCode: '+977', flagEmoji: '🇳🇵', minLength: 10, maxLength: 10),
  CountryCode(name: 'Sri Lanka', isoCode: 'LK', dialCode: '+94', flagEmoji: '🇱🇰', minLength: 9, maxLength: 9),
  CountryCode(name: 'Indonesia', isoCode: 'ID', dialCode: '+62', flagEmoji: '🇮🇩', minLength: 8, maxLength: 12),
  CountryCode(name: 'Malaysia', isoCode: 'MY', dialCode: '+60', flagEmoji: '🇲🇾', minLength: 9, maxLength: 10),
  CountryCode(name: 'Turkey', isoCode: 'TR', dialCode: '+90', flagEmoji: '🇹🇷', minLength: 10, maxLength: 10),
  CountryCode(name: 'Australia', isoCode: 'AU', dialCode: '+61', flagEmoji: '🇦🇺', minLength: 9, maxLength: 9),
  CountryCode(name: 'Germany', isoCode: 'DE', dialCode: '+49', flagEmoji: '🇩🇪', minLength: 6, maxLength: 13),
  CountryCode(name: 'France', isoCode: 'FR', dialCode: '+33', flagEmoji: '🇫🇷', minLength: 9, maxLength: 9),
  CountryCode(name: 'South Africa', isoCode: 'ZA', dialCode: '+27', flagEmoji: '🇿🇦', minLength: 9, maxLength: 9),
];

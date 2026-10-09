import 'package:intl/intl.dart';

/// Shared number and date formatting (Indian conventions).
///
/// Use these instead of hand-written `toStringAsFixed` / string building, so
/// every screen shows money and dates the same way. Money keeps Indian
/// grouping everywhere; month names follow the app language
/// ([Intl.defaultLocale], set by the app).
class AppFormat {
  const AppFormat._();

  static final NumberFormat _rupees = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _wholeRupees = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// ₹12,34,567.50 — paise shown only when there are any (₹500, ₹700.75).
  static String rupees(num amount) {
    final hasPaise = (amount * 100).round() % 100 != 0;
    return (hasPaise ? _rupees : _wholeRupees).format(amount);
  }

  /// Locale for dates: Hindi and Urdu month names, else Indian English.
  static String get dateLocale => switch (Intl.defaultLocale) {
    'hi' => 'hi',
    'ur' => 'ur',
    _ => 'en_IN',
  };

  /// 7 Oct 2026
  static String date(DateTime value) =>
      DateFormat('d MMM y', dateLocale).format(value.toLocal());

  /// 7 Oct 2026, 5:30 PM
  static String dateTime(DateTime value) =>
      DateFormat('d MMM y, h:mm a', dateLocale).format(value.toLocal());

  /// September 2026
  static String monthYear(int month, int year) =>
      DateFormat('MMMM y', dateLocale).format(DateTime(year, month));

  /// A phone number kept left-to-right inside Urdu text (else "+91…"
  /// shows as "…91+").
  static String phone(String value) => '\u2066$value\u2069';

  static String? phoneOrNull(String? value) =>
      value == null || value.isEmpty ? value : phone(value);
}

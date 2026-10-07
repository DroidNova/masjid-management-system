import 'package:intl/intl.dart';

/// Shared number and date formatting (Indian conventions).
///
/// Use these instead of hand-written `toStringAsFixed` / string building, so
/// every screen shows money and dates the same way. When Hindi or Urdu is
/// added, pass the app locale here.
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

  /// 7 Oct 2026
  static String date(DateTime value) =>
      DateFormat('d MMM y', 'en_IN').format(value.toLocal());

  /// 7 Oct 2026, 5:30 PM
  static String dateTime(DateTime value) =>
      DateFormat('d MMM y, h:mm a', 'en_IN').format(value.toLocal());

  /// September 2026
  static String monthYear(int month, int year) =>
      DateFormat('MMMM y', 'en_IN').format(DateTime(year, month));
}

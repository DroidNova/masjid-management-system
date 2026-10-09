import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';

void main() {
  setUpAll(initializeDateFormatting);
  tearDown(() => Intl.defaultLocale = null);

  test('rupees use Indian grouping and show paise only when present', () {
    expect(AppFormat.rupees(1234567), '₹12,34,567');
    expect(AppFormat.rupees(700.75), '₹700.75');
    expect(AppFormat.rupees(6579.17), '₹6,579.17');
    expect(AppFormat.rupees(0), '₹0');
  });

  test('dates are short and readable', () {
    expect(AppFormat.date(DateTime(2026, 10, 7, 12)), '7 Oct 2026');
    expect(AppFormat.monthYear(9, 2026), 'September 2026');
  });

  test('month names follow the app language; money keeps its format', () {
    Intl.defaultLocale = 'hi';
    expect(AppFormat.monthYear(9, 2026), 'सितंबर 2026');
    expect(AppFormat.rupees(1234567), '₹12,34,567');
    Intl.defaultLocale = 'ur';
    expect(AppFormat.monthYear(9, 2026), contains('2026'));
    expect(AppFormat.monthYear(9, 2026), isNot(contains('September')));
  });

  test('a phone number stays left-to-right inside Urdu text', () {
    expect(AppFormat.phone('+919876543210'), '\u2066+919876543210\u2069');
    expect(AppFormat.phoneOrNull(null), isNull);
    expect(AppFormat.phoneOrNull(''), '');
  });
}

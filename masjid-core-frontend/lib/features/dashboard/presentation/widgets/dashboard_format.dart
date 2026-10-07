import 'package:masjid_core_frontend/core/format/formatters.dart';

/// Indian grouping with paise when present, e.g. ₹12,34,567.50.
String formatRupees(double amount) => AppFormat.rupees(amount);

String valueOrDash(String? value) {
  if (value == null || value.trim().isEmpty) return '-';
  return value;
}

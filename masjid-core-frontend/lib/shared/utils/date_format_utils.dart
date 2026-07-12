const List<String> _monthLabels = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatReadableDate(DateTime? date, {String nullText = 'Not set'}) {
  if (date == null) return nullText;
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  return '$day ${_monthLabels[local.month - 1]} ${local.year}';
}

String? formatApiDate(DateTime? date) {
  if (date == null) return null;
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

DateTime? parseApiDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

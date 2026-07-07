int parseInt(Object? value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.round() ?? 0;
  return 0;
}

double parseDouble(Object? value) {
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

String? parseString(Object? value) {
  final parsed = value?.toString();
  if (parsed == null || parsed.isEmpty) return null;
  return parsed;
}

Map<String, dynamic>? parseMap(Object? value) {
  return value is Map<String, dynamic> ? value : null;
}

double parseDouble(Object? value) {
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

String parseRequiredString(Object? value) {
  return value?.toString() ?? '';
}

String? parseOptionalString(Object? value) {
  final parsed = value?.toString();
  if (parsed == null || parsed.trim().isEmpty) return null;
  return parsed;
}

void addStringIfNotEmpty(
  Map<String, dynamic> json,
  String key,
  String? value,
) {
  final trimmedValue = value?.trim();
  if (trimmedValue != null && trimmedValue.isNotEmpty) {
    json[key] = trimmedValue;
  }
}

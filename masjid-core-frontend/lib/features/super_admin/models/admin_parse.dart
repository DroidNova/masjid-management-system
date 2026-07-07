String readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().isNotEmpty) return value.toString();
  }
  return '';
}

String? readNullableString(Map<String, dynamic> json, List<String> keys) {
  final value = readString(json, keys);
  return value.isEmpty ? null : value;
}

int readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return 0;
}

List<String> readRoles(dynamic raw) {
  if (raw is List) {
    return raw.map((role) {
      if (role is Map<String, dynamic>) return (role['name'] ?? role['role'] ?? role['code'] ?? '').toString();
      return role.toString();
    }).where((role) => role.isNotEmpty).toList();
  }
  return const <String>[];
}

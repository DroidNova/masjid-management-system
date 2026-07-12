import 'package:platform_core_frontend/shared/utils/date_format_utils.dart';

class AuditInfo {
  const AuditInfo({
    this.createdById,
    this.createdByName,
    this.createdAt,
    this.updatedById,
    this.updatedByName,
    this.updatedAt,
  });

  factory AuditInfo.fromJson(Map<String, dynamic> json) => AuditInfo(
        createdById: _optionalString(json['createdById']),
        createdByName: _optionalString(json['createdByName']),
        createdAt: parseApiDate(json['createdAt']),
        updatedById: _optionalString(json['updatedById']),
        updatedByName: _optionalString(json['updatedByName']),
        updatedAt: parseApiDate(json['updatedAt']),
      );

  final String? createdById;
  final String? createdByName;
  final DateTime? createdAt;
  final String? updatedById;
  final String? updatedByName;
  final DateTime? updatedAt;

  bool get hasCreatedInfo => createdByName != null || createdAt != null;
  bool get hasUpdatedInfo => updatedByName != null || updatedAt != null;
}

String? _optionalString(Object? value) {
  final parsed = value?.toString().trim();
  if (parsed == null || parsed.isEmpty) return null;
  return parsed;
}

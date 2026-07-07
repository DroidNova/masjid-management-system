import 'package:platform_core_frontend/features/admin/domain/entities/admin_user_summary.dart';
import 'package:platform_core_frontend/shared/types/json_types.dart';

class AdminUserSummaryModel {
  const AdminUserSummaryModel({
    required this.id,
    required this.email,
    required this.status,
    required this.roles,
    this.name,
  });

  final String id;
  final String email;
  final String status;
  final List<String> roles;
  final String? name;

  factory AdminUserSummaryModel.fromJson(JsonMap json) {
    final roles = (json['roles'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];

    return AdminUserSummaryModel(
      // TODO(BACKEND): confirm canonical identifier key for this payload.
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['fullName'] ?? json['name'] ?? json['displayName'])?.toString(),
      status: (json['status'] ?? 'UNKNOWN').toString(),
      roles: roles,
    );
  }

  AdminUserSummary toEntity() {
    return AdminUserSummary(
      id: id,
      email: email,
      status: status,
      roles: List<String>.from(roles),
      name: name,
    );
  }
}

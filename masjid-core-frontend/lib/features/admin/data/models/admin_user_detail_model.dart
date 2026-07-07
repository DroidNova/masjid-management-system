import 'package:platform_core_frontend/core/network/response_mapper.dart';
import 'package:platform_core_frontend/features/admin/domain/entities/admin_user_detail.dart';
import 'package:platform_core_frontend/shared/types/json_types.dart';

class AdminUserDetailModel {
  const AdminUserDetailModel({
    required this.id,
    required this.email,
    required this.status,
    required this.roles,
    required this.permissions,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String status;
  final List<String> roles;
  final List<String> permissions;
  final String? name;
  final String? createdAt;
  final String? updatedAt;

  factory AdminUserDetailModel.fromJson(JsonMap json) {
    final roles = (json['roles'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];
    final permissions =
        (json['permissions'] as List?)?.map((e) => e.toString()).toList() ??
            const <String>[];

    return AdminUserDetailModel(
      // TODO(BACKEND): confirm canonical identifier key for this payload.
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['fullName'] ?? json['name'] ?? json['displayName'])?.toString(),
      status: (json['status'] ?? 'UNKNOWN').toString(),
      roles: roles,
      permissions: permissions,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  factory AdminUserDetailModel.fromResponse(dynamic raw) {
    final json = ResponseMapper.unwrapDataMap(raw);
    return AdminUserDetailModel.fromJson(json);
  }

  AdminUserDetail toEntity() {
    return AdminUserDetail(
      id: id,
      email: email,
      status: status,
      roles: List<String>.from(roles),
      permissions: List<String>.from(permissions),
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

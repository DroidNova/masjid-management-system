import 'package:platform_core_frontend/core/network/response_mapper.dart';
import 'package:platform_core_frontend/features/auth/domain/entities/current_user.dart';
import 'package:platform_core_frontend/shared/types/json_types.dart';

class CurrentUserModel {
  const CurrentUserModel({
    required this.id,
    required this.fullName,
    required this.roles,
    required this.permissions,
    this.email,
    this.phone,
    this.status,
    this.masjidId,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.createdAt,
    this.updatedAt,
    this.displayName,
  });

  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? status;
  final String? masjidId;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? displayName;
  final List<String> roles;
  final List<String> permissions;

  factory CurrentUserModel.fromJson(JsonMap json) {
    final roles = (json['roles'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];
    final permissions =
        (json['permissions'] as List?)?.map((e) => e.toString()).toList() ??
            const <String>[];
    final fullName = (json['fullName'] ?? json['name'] ?? json['displayName'])
            ?.toString() ??
        '';

    return CurrentUserModel(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      fullName: fullName,
      email: json['email']?.toString(),
      phone: (json['phone'] ?? json['phoneNumber'] ?? json['mobile'])?.toString(),
      status: json['status']?.toString(),
      masjidId: json['masjidId']?.toString(),
      isEmailVerified: _readBool(json['isEmailVerified']),
      isPhoneVerified: _readBool(json['isPhoneVerified']),
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readDateTime(json['updatedAt']),
      displayName: fullName.isEmpty ? null : fullName,
      roles: roles,
      permissions: permissions,
    );
  }

  factory CurrentUserModel.fromResponse(dynamic raw) {
    final json = ResponseMapper.unwrapDataMap(raw);
    return CurrentUserModel.fromJson(json);
  }

  CurrentUser toEntity() {
    return CurrentUser(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      status: status,
      masjidId: masjidId,
      isEmailVerified: isEmailVerified,
      isPhoneVerified: isPhoneVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
      displayName: displayName,
      roles: List<String>.from(roles),
      permissions: List<String>.from(permissions),
    );
  }

  JsonMap toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'status': status,
      'masjidId': masjidId,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'displayName': displayName,
      'roles': roles,
      'permissions': permissions,
    };
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase();
    return text == 'true' || text == '1';
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is DateTime) return value;
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  roles:
      (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  permissions:
      (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  status: json['status'] as String?,
  masjidId: json['masjidId'] as String?,
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'roles': instance.roles,
  'permissions': instance.permissions,
  'email': instance.email,
  'phone': instance.phone,
  'status': instance.status,
  'masjidId': instance.masjidId,
  'isEmailVerified': instance.isEmailVerified,
  'isPhoneVerified': instance.isPhoneVerified,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

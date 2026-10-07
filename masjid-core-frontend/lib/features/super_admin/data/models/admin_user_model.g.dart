// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminUserModel _$AdminUserModelFromJson(Map<String, dynamic> json) =>
    _AdminUserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      status: json['status'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      fatherName: json['fatherName'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      masjidId: json['masjidId'] as String?,
      masjidName: json['masjidName'] as String?,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AdminUserModelToJson(_AdminUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'status': instance.status,
      'email': instance.email,
      'phone': instance.phone,
      'fatherName': instance.fatherName,
      'age': instance.age,
      'gender': instance.gender,
      'masjidId': instance.masjidId,
      'masjidName': instance.masjidName,
      'roles': instance.roles,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

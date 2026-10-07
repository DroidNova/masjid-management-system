// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommunityUserModel _$CommunityUserModelFromJson(Map<String, dynamic> json) =>
    _CommunityUserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String?,
      masjidId: json['masjidId'] as String?,
      message: json['message'] as String?,
      temporaryPassword: json['temporaryPassword'] as String?,
      fatherName: json['fatherName'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      isFamilyHead: json['isFamilyHead'] as bool? ?? false,
      familyMemberCount: (json['familyMemberCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CommunityUserModelToJson(_CommunityUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'roles': instance.roles,
      'email': instance.email,
      'phone': instance.phone,
      'status': instance.status,
      'masjidId': instance.masjidId,
      'message': instance.message,
      'temporaryPassword': instance.temporaryPassword,
      'fatherName': instance.fatherName,
      'age': instance.age,
      'gender': instance.gender,
      'isFamilyHead': instance.isFamilyHead,
      'familyMemberCount': instance.familyMemberCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

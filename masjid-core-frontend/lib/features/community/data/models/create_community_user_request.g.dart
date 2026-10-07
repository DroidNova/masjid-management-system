// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_community_user_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateCommunityUserRequest _$CreateCommunityUserRequestFromJson(
  Map<String, dynamic> json,
) => _CreateCommunityUserRequest(
  fullName: json['fullName'] as String,
  phone: json['phone'] as String,
  role: json['role'] as String,
  fatherName: json['fatherName'] as String,
  age: (json['age'] as num).toInt(),
  gender: json['gender'] as String,
  email: json['email'] as String?,
  isFamilyHead: json['isFamilyHead'] as bool?,
  familyMemberCount: (json['familyMemberCount'] as num?)?.toInt(),
  masjidId: json['masjidId'] as String?,
);

Map<String, dynamic> _$CreateCommunityUserRequestToJson(
  _CreateCommunityUserRequest instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'phone': instance.phone,
  'role': instance.role,
  'fatherName': instance.fatherName,
  'age': instance.age,
  'gender': instance.gender,
  'email': ?instance.email,
  'isFamilyHead': ?instance.isFamilyHead,
  'familyMemberCount': ?instance.familyMemberCount,
  'masjidId': ?instance.masjidId,
};

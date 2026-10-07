// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_community_user_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateCommunityUserRequest _$UpdateCommunityUserRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateCommunityUserRequest(
  fullName: json['fullName'] as String,
  phone: json['phone'] as String,
  fatherName: json['fatherName'] as String,
  age: (json['age'] as num).toInt(),
  gender: json['gender'] as String,
  email: json['email'] as String?,
  isFamilyHead: json['isFamilyHead'] as bool?,
  familyMemberCount: (json['familyMemberCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$UpdateCommunityUserRequestToJson(
  _UpdateCommunityUserRequest instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'phone': instance.phone,
  'fatherName': instance.fatherName,
  'age': instance.age,
  'gender': instance.gender,
  'email': ?instance.email,
  'isFamilyHead': ?instance.isFamilyHead,
  'familyMemberCount': ?instance.familyMemberCount,
};

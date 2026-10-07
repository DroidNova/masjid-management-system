// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'committee_member_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommitteeMemberInput _$CommitteeMemberInputFromJson(
  Map<String, dynamic> json,
) => _CommitteeMemberInput(
  name: json['name'] as String,
  phone: json['phone'] as String,
  fatherName: json['fatherName'] as String,
  age: (json['age'] as num).toInt(),
  gender: json['gender'] as String,
);

Map<String, dynamic> _$CommitteeMemberInputToJson(
  _CommitteeMemberInput instance,
) => <String, dynamic>{
  'name': instance.name,
  'phone': instance.phone,
  'fatherName': instance.fatherName,
  'age': instance.age,
  'gender': instance.gender,
};

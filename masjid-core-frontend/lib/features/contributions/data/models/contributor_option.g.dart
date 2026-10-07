// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contributor_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContributorOption _$ContributorOptionFromJson(Map<String, dynamic> json) =>
    _ContributorOption(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$ContributorOptionToJson(_ContributorOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'phone': instance.phone,
    };

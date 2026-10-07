// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_project_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateProjectRequest _$CreateProjectRequestFromJson(
  Map<String, dynamic> json,
) => _CreateProjectRequest(
  title: json['title'] as String,
  description: json['description'] as String?,
  targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
  collectedAmount: (json['collectedAmount'] as num?)?.toDouble() ?? 0,
  spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0,
  status: json['status'] as String? ?? 'ONGOING',
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
);

Map<String, dynamic> _$CreateProjectRequestToJson(
  _CreateProjectRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': ?instance.description,
  'targetAmount': instance.targetAmount,
  'collectedAmount': instance.collectedAmount,
  'spentAmount': instance.spentAmount,
  'status': instance.status,
  'startDate': ?instance.startDate,
  'endDate': ?instance.endDate,
};

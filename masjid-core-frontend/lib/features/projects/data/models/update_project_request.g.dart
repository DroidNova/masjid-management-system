// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_project_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateProjectRequest _$UpdateProjectRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateProjectRequest(
  title: json['title'] as String?,
  description: json['description'] as String?,
  targetAmount: (json['targetAmount'] as num?)?.toDouble(),
  collectedAmount: (json['collectedAmount'] as num?)?.toDouble(),
  spentAmount: (json['spentAmount'] as num?)?.toDouble(),
  status: json['status'] as String?,
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
);

Map<String, dynamic> _$UpdateProjectRequestToJson(
  _UpdateProjectRequest instance,
) => <String, dynamic>{
  'title': ?instance.title,
  'description': ?instance.description,
  'targetAmount': ?instance.targetAmount,
  'collectedAmount': ?instance.collectedAmount,
  'spentAmount': ?instance.spentAmount,
  'status': ?instance.status,
  'startDate': ?instance.startDate,
  'endDate': ?instance.endDate,
};

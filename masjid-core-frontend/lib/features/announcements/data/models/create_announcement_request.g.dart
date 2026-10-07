// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_announcement_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateAnnouncementRequest _$CreateAnnouncementRequestFromJson(
  Map<String, dynamic> json,
) => _CreateAnnouncementRequest(
  title: json['title'] as String,
  message: json['message'] as String,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$CreateAnnouncementRequestToJson(
  _CreateAnnouncementRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'message': instance.message,
  'isActive': instance.isActive,
};

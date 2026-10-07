// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_announcement_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateAnnouncementRequest _$UpdateAnnouncementRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateAnnouncementRequest(
  title: json['title'] as String?,
  message: json['message'] as String?,
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$UpdateAnnouncementRequestToJson(
  _UpdateAnnouncementRequest instance,
) => <String, dynamic>{
  'title': ?instance.title,
  'message': ?instance.message,
  'isActive': ?instance.isActive,
};

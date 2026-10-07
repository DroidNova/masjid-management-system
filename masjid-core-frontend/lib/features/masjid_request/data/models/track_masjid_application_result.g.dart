// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_masjid_application_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrackMasjidApplicationResult _$TrackMasjidApplicationResultFromJson(
  Map<String, dynamic> json,
) => _TrackMasjidApplicationResult(
  masjidName: json['masjidName'] as String,
  status: json['status'] as String? ?? 'PENDING',
  imamName: json['imamName'] as String?,
  requestedAt: json['requestedAt'] == null
      ? null
      : DateTime.parse(json['requestedAt'] as String),
  reviewedAt: json['reviewedAt'] == null
      ? null
      : DateTime.parse(json['reviewedAt'] as String),
);

Map<String, dynamic> _$TrackMasjidApplicationResultToJson(
  _TrackMasjidApplicationResult instance,
) => <String, dynamic>{
  'masjidName': instance.masjidName,
  'status': instance.status,
  'imamName': instance.imamName,
  'requestedAt': instance.requestedAt?.toIso8601String(),
  'reviewedAt': instance.reviewedAt?.toIso8601String(),
};

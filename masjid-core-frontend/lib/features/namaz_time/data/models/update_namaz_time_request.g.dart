// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_namaz_time_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateNamazTimeRequest _$UpdateNamazTimeRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateNamazTimeRequest(
  fajr: json['fajr'] as String?,
  zuhr: json['zuhr'] as String?,
  asr: json['asr'] as String?,
  maghrib: json['maghrib'] as String?,
  isha: json['isha'] as String?,
  jumma: json['jumma'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$UpdateNamazTimeRequestToJson(
  _UpdateNamazTimeRequest instance,
) => <String, dynamic>{
  'fajr': ?instance.fajr,
  'zuhr': ?instance.zuhr,
  'asr': ?instance.asr,
  'maghrib': ?instance.maghrib,
  'isha': ?instance.isha,
  'jumma': ?instance.jumma,
  'note': ?instance.note,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'namaz_time_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NamazTimeModel _$NamazTimeModelFromJson(Map<String, dynamic> json) =>
    _NamazTimeModel(
      id: json['id'] as String?,
      masjidId: json['masjidId'] as String?,
      fajr: json['fajr'] as String?,
      zuhr: json['zuhr'] as String?,
      asr: json['asr'] as String?,
      maghrib: json['maghrib'] as String?,
      isha: json['isha'] as String?,
      jumma: json['jumma'] as String?,
      note: json['note'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$NamazTimeModelToJson(_NamazTimeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'masjidId': instance.masjidId,
      'fajr': instance.fajr,
      'zuhr': instance.zuhr,
      'asr': instance.asr,
      'maghrib': instance.maghrib,
      'isha': instance.isha,
      'jumma': instance.jumma,
      'note': instance.note,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

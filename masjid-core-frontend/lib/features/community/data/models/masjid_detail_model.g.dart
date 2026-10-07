// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'masjid_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MasjidDetailModel _$MasjidDetailModelFromJson(Map<String, dynamic> json) =>
    _MasjidDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      country: json['country'] as String?,
      locality: json['locality'] as String?,
      district: json['district'] as String?,
      state: json['state'] as String?,
      address: json['address'] as String?,
      contactNo: json['contactNo'] as String?,
      description: json['description'] as String?,
      welcomeMsg: json['welcomeMsg'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MasjidDetailModelToJson(_MasjidDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country': instance.country,
      'locality': instance.locality,
      'district': instance.district,
      'state': instance.state,
      'address': instance.address,
      'contactNo': instance.contactNo,
      'description': instance.description,
      'welcomeMsg': instance.welcomeMsg,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

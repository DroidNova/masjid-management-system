// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_masjid_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminMasjidModel _$AdminMasjidModelFromJson(Map<String, dynamic> json) =>
    _AdminMasjidModel(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      country: json['country'] as String?,
      state: json['state'] as String?,
      district: json['district'] as String?,
      locality: json['locality'] as String?,
      address: json['address'] as String?,
      contactNo: json['contactNo'] as String?,
      description: json['description'] as String?,
      welcomeMsg: json['welcomeMsg'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      requestedByName: json['requestedByName'] as String?,
      requestedByPhone: json['requestedByPhone'] as String?,
      requestedByEmail: json['requestedByEmail'] as String?,
      imamUserId: json['imamUserId'] as String?,
      imamName: json['imamName'] as String?,
      usersCount: (json['usersCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AdminMasjidModelToJson(_AdminMasjidModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'country': instance.country,
      'state': instance.state,
      'district': instance.district,
      'locality': instance.locality,
      'address': instance.address,
      'contactNo': instance.contactNo,
      'description': instance.description,
      'welcomeMsg': instance.welcomeMsg,
      'rejectionReason': instance.rejectionReason,
      'requestedByName': instance.requestedByName,
      'requestedByPhone': instance.requestedByPhone,
      'requestedByEmail': instance.requestedByEmail,
      'imamUserId': instance.imamUserId,
      'imamName': instance.imamName,
      'usersCount': instance.usersCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

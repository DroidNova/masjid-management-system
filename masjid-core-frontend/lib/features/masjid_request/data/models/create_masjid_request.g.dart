// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_masjid_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateMasjidRequest _$CreateMasjidRequestFromJson(Map<String, dynamic> json) =>
    _CreateMasjidRequest(
      requesterName: json['requesterName'] as String,
      requesterPhone: json['requesterPhone'] as String,
      requesterEmail: json['requesterEmail'] as String?,
      masjidName: json['masjidName'] as String,
      country: json['country'] as String,
      district: json['district'] as String?,
      locality: json['locality'] as String,
      state: json['state'] as String,
      address: json['address'] as String,
      contactNo: json['contactNo'] as String?,
      description: json['description'] as String?,
      welcomeMsg: json['welcomeMsg'] as String?,
      imamName: json['imamName'] as String,
      imamPhone: json['imamPhone'] as String,
      imamEmail: json['imamEmail'] as String?,
      imamAddress: json['imamAddress'] as String,
      imamFatherName: json['imamFatherName'] as String,
      imamAge: (json['imamAge'] as num).toInt(),
      imamGender: json['imamGender'] as String,
      committeeMembers: (json['committeeMembers'] as List<dynamic>)
          .map((e) => CommitteeMemberInput.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreateMasjidRequestToJson(
  _CreateMasjidRequest instance,
) => <String, dynamic>{
  'requesterName': instance.requesterName,
  'requesterPhone': instance.requesterPhone,
  'requesterEmail': ?instance.requesterEmail,
  'masjidName': instance.masjidName,
  'country': instance.country,
  'district': ?instance.district,
  'locality': instance.locality,
  'state': instance.state,
  'address': instance.address,
  'contactNo': ?instance.contactNo,
  'description': ?instance.description,
  'welcomeMsg': ?instance.welcomeMsg,
  'imamName': instance.imamName,
  'imamPhone': instance.imamPhone,
  'imamEmail': ?instance.imamEmail,
  'imamAddress': instance.imamAddress,
  'imamFatherName': instance.imamFatherName,
  'imamAge': instance.imamAge,
  'imamGender': instance.imamGender,
  'committeeMembers': instance.committeeMembers.map((e) => e.toJson()).toList(),
};

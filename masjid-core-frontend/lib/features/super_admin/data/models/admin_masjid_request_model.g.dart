// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_masjid_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommitteeMember _$CommitteeMemberFromJson(Map<String, dynamic> json) =>
    _CommitteeMember(
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      fatherName: json['fatherName'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
    );

Map<String, dynamic> _$CommitteeMemberToJson(_CommitteeMember instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'fatherName': instance.fatherName,
      'age': instance.age,
      'gender': instance.gender,
    };

_AdminMasjidRequestModel _$AdminMasjidRequestModelFromJson(
  Map<String, dynamic> json,
) => _AdminMasjidRequestModel(
  id: json['id'] as String,
  masjidName: json['masjidName'] as String,
  status: json['status'] as String,
  requesterName: json['requesterName'] as String?,
  requesterPhone: json['requesterPhone'] as String?,
  requesterEmail: json['requesterEmail'] as String?,
  country: json['country'] as String?,
  state: json['state'] as String?,
  district: json['district'] as String?,
  locality: json['locality'] as String?,
  address: json['address'] as String?,
  contactNo: json['contactNo'] as String?,
  description: json['description'] as String?,
  welcomeMsg: json['welcomeMsg'] as String?,
  imamName: json['imamName'] as String?,
  imamEmail: json['imamEmail'] as String?,
  imamPhone: json['imamPhone'] as String?,
  imamAddress: json['imamAddress'] as String?,
  imamFatherName: json['imamFatherName'] as String?,
  imamAge: (json['imamAge'] as num?)?.toInt(),
  imamGender: json['imamGender'] as String?,
  committeeMembers:
      (json['committeeMembers'] as List<dynamic>?)
          ?.map((e) => CommitteeMember.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CommitteeMember>[],
  rejectionReason: json['rejectionReason'] as String?,
  createdMasjidId: json['createdMasjidId'] as String?,
  reviewedAt: json['reviewedAt'] == null
      ? null
      : DateTime.parse(json['reviewedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AdminMasjidRequestModelToJson(
  _AdminMasjidRequestModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'masjidName': instance.masjidName,
  'status': instance.status,
  'requesterName': instance.requesterName,
  'requesterPhone': instance.requesterPhone,
  'requesterEmail': instance.requesterEmail,
  'country': instance.country,
  'state': instance.state,
  'district': instance.district,
  'locality': instance.locality,
  'address': instance.address,
  'contactNo': instance.contactNo,
  'description': instance.description,
  'welcomeMsg': instance.welcomeMsg,
  'imamName': instance.imamName,
  'imamEmail': instance.imamEmail,
  'imamPhone': instance.imamPhone,
  'imamAddress': instance.imamAddress,
  'imamFatherName': instance.imamFatherName,
  'imamAge': instance.imamAge,
  'imamGender': instance.imamGender,
  'committeeMembers': instance.committeeMembers.map((e) => e.toJson()).toList(),
  'rejectionReason': instance.rejectionReason,
  'createdMasjidId': instance.createdMasjidId,
  'reviewedAt': instance.reviewedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

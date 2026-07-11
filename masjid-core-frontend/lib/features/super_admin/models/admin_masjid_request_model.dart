import 'package:platform_core_frontend/features/super_admin/models/admin_parse.dart';

class AdminMasjidRequestModel {
  const AdminMasjidRequestModel({
    required this.id,
    this.requesterName,
    this.requesterPhone,
    this.requesterEmail,
    this.status,
    this.masjidName,
    this.village,
    this.city,
    this.district,
    this.state,
    this.country,
    this.address,
    this.contactNo,
    this.description,
    this.welcomeMsg,
    this.imamName,
    this.imamEmail,
    this.imamPhone,
    this.imamAddress,
    this.committeeMembers = const <dynamic>[],
    this.rejectionReason,
    this.createdMasjidId,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminMasjidRequestModel.fromJson(Map<String, dynamic> json) =>
      AdminMasjidRequestModel(
        id: readString(json, ['id', '_id']),
        requesterName: readNullableString(json, ['requesterName', 'createdByName', 'name']),
        requesterPhone: readNullableString(json, ['requesterPhone', 'phone']),
        requesterEmail: readNullableString(json, ['requesterEmail', 'email']),
        status: readNullableString(json, ['status']) ?? 'PENDING',
        masjidName: readNullableString(json, ['masjidName', 'name']),
        village: readNullableString(json, ['village']),
        city: readNullableString(json, ['city']),
        district: readNullableString(json, ['district']),
        state: readNullableString(json, ['state']),
        country: readNullableString(json, ['country']),
        address: readNullableString(json, ['address']),
        contactNo: readNullableString(json, ['contactNo', 'contactNumber']),
        description: readNullableString(json, ['description']),
        welcomeMsg: readNullableString(json, ['welcomeMsg', 'welcomeMessage']),
        imamName: readNullableString(json, ['imamName']),
        imamEmail: readNullableString(json, ['imamEmail']),
        imamPhone: readNullableString(json, ['imamPhone']),
        imamAddress: readNullableString(json, ['imamAddress']),
        committeeMembers: json['committeeMembers'] is List
            ? json['committeeMembers'] as List<dynamic>
            : const <dynamic>[],
        rejectionReason: readNullableString(json, ['rejectionReason', 'reason']),
        createdMasjidId: readNullableString(json, ['createdMasjidId', 'masjidId']),
        createdAt: readNullableString(json, ['createdAt']),
        updatedAt: readNullableString(json, ['updatedAt']),
      );

  final String id;
  final String? requesterName;
  final String? requesterPhone;
  final String? requesterEmail;
  final String? status;
  final String? masjidName;
  final String? village;
  final String? city;
  final String? district;
  final String? state;
  final String? country;
  final String? address;
  final String? contactNo;
  final String? description;
  final String? welcomeMsg;
  final String? imamName;
  final String? imamEmail;
  final String? imamPhone;
  final String? imamAddress;
  final String? rejectionReason;
  final String? createdMasjidId;
  final String? createdAt;
  final String? updatedAt;
  final List<dynamic> committeeMembers;
}

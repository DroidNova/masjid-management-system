import 'package:platform_core_frontend/features/super_admin/models/admin_parse.dart';

class AdminMasjidModel {
  const AdminMasjidModel({
    required this.id,
    this.name,
    this.village,
    this.city,
    this.district,
    this.state,
    this.country,
    this.address,
    this.contactNo,
    this.description,
    this.welcomeMsg,
    this.status,
    this.imamUserId,
    this.imamName,
    this.requestedByName,
    this.requestedByPhone,
    this.requestedByEmail,
    this.usersCount,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminMasjidModel.fromJson(Map<String, dynamic> json) => AdminMasjidModel(
        id: readString(json, ['id', '_id', 'masjidId']),
        name: readNullableString(json, ['name', 'masjidName']),
        village: readNullableString(json, ['village']),
        city: readNullableString(json, ['city']),
        district: readNullableString(json, ['district']),
        state: readNullableString(json, ['state']),
        country: readNullableString(json, ['country']),
        address: readNullableString(json, ['address']),
        contactNo: readNullableString(json, ['contactNo', 'contactNumber']),
        description: readNullableString(json, ['description']),
        welcomeMsg: readNullableString(json, ['welcomeMsg', 'welcomeMessage']),
        status: readNullableString(json, ['status']) ?? 'APPROVED',
        imamUserId: readNullableString(json, ['imamUserId']),
        imamName: readNullableString(json, ['imamName']) ??
            (json['imam'] is Map<String, dynamic>
                ? readNullableString(json['imam'] as Map<String, dynamic>, ['fullName', 'name'])
                : null),
        requestedByName: readNullableString(json, ['requestedByName']),
        requestedByPhone: readNullableString(json, ['requestedByPhone']),
        requestedByEmail: readNullableString(json, ['requestedByEmail']),
        usersCount: readInt(json, ['usersCount', 'userCount', 'membersCount']),
        createdAt: readNullableString(json, ['createdAt']),
        updatedAt: readNullableString(json, ['updatedAt']),
      );

  final String id;
  final String? name;
  final String? village;
  final String? city;
  final String? district;
  final String? state;
  final String? country;
  final String? address;
  final String? contactNo;
  final String? description;
  final String? welcomeMsg;
  final String? status;
  final String? imamUserId;
  final String? imamName;
  final String? requestedByName;
  final String? requestedByPhone;
  final String? requestedByEmail;
  final int? usersCount;
  final String? createdAt;
  final String? updatedAt;
}

import 'package:platform_core_frontend/features/masjid_request/data/models/committee_member_input.dart';
import 'package:platform_core_frontend/features/masjid_request/data/models/imam_input.dart';

class CreateMasjidRequest {
  const CreateMasjidRequest({
    required this.requesterName,
    required this.requesterPhone,
    required this.requesterEmail,
    required this.masjidName,
    required this.country,
    required this.district,
    required this.locality,
    required this.state,
    required this.address,
    required this.contactNo,
    required this.description,
    required this.welcomeMsg,
    required this.imam,
    required this.committeeMembers,
  });

  final String requesterName;
  final String requesterPhone;
  final String requesterEmail;
  final String masjidName;
  final String country;
  final String district;
  final String locality;
  final String state;
  final String address;
  final String contactNo;
  final String description;
  final String welcomeMsg;
  final ImamInput imam;
  final List<CommitteeMemberInput> committeeMembers;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    _addIfNotEmpty(json, 'requesterName', requesterName);
    _addIfNotEmpty(json, 'requesterPhone', requesterPhone);
    _addIfNotEmpty(json, 'requesterEmail', requesterEmail);
    _addIfNotEmpty(json, 'masjidName', masjidName);
    _addIfNotEmpty(json, 'country', country);
    _addIfNotEmpty(json, 'district', district);
    _addIfNotEmpty(json, 'locality', locality);
    _addIfNotEmpty(json, 'state', state);
    _addIfNotEmpty(json, 'address', address);
    _addIfNotEmpty(json, 'contactNo', contactNo);
    _addIfNotEmpty(json, 'description', description);
    _addIfNotEmpty(json, 'welcomeMsg', welcomeMsg);

    _addIfNotEmpty(json, 'imamName', imam.name);
    _addIfNotEmpty(json, 'imamPhone', imam.phone);
    _addIfNotEmpty(json, 'imamEmail', imam.email);
    _addIfNotEmpty(json, 'imamAddress', imam.address);
    _addIfNotEmpty(json, 'imamFatherName', imam.fatherName);
    json['imamAge'] = imam.age;
    _addIfNotEmpty(json, 'imamGender', imam.gender);

    final nonEmptyMembers = committeeMembers
        .where((member) => !member.isEmpty)
        .map((member) => member.toJson())
        .where((memberJson) => memberJson.isNotEmpty)
        .toList();

    if (nonEmptyMembers.isNotEmpty) {
      json['committeeMembers'] = nonEmptyMembers;
    }

    return json;
  }

  void _addIfNotEmpty(Map<String, dynamic> json, String key, String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty) {
      json[key] = trimmedValue;
    }
  }
}

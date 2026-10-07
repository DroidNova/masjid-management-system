import 'package:masjid_core_frontend/features/masjid_request/data/models/committee_member_input.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/models/create_masjid_request.dart';
import 'package:masjid_core_frontend/shared/models/country_code.dart';
import 'package:masjid_core_frontend/shared/utils/country_code_utils.dart';

/// A phone field's value: country plus the number as typed.
class PhoneInput {
  const PhoneInput({required this.country, required this.number});

  final CountryCode country;
  final String number;

  bool get isEmpty => number.trim().isEmpty;

  /// `+919876543210`.
  String get normalized =>
      normalizePhone(countryCode: country, nationalNumber: number);
}

class CommitteeMemberDraft {
  const CommitteeMemberDraft({
    required this.name,
    required this.phone,
    required this.fatherName,
    required this.age,
    required this.gender,
  });

  final String name;
  final PhoneInput phone;
  final String fatherName;
  final String age;
  final String? gender;
}

/// Everything typed into the masjid registration form, before cleaning.
class MasjidRequestDraft {
  const MasjidRequestDraft({
    required this.masjidName,
    required this.masjidCountry,
    required this.state,
    required this.district,
    required this.locality,
    required this.address,
    required this.contactNo,
    required this.welcomeMsg,
    required this.description,
    required this.requesterName,
    required this.requesterPhone,
    required this.requesterEmail,
    required this.imamName,
    required this.imamPhone,
    required this.imamEmail,
    required this.imamFatherName,
    required this.imamAge,
    required this.imamGender,
    required this.imamAddress,
    required this.committeeMembers,
  });

  final String masjidName;
  final CountryCode masjidCountry;
  final String state;
  final String district;
  final String locality;
  final String address;
  final PhoneInput contactNo;
  final String welcomeMsg;
  final String description;
  final String requesterName;
  final PhoneInput requesterPhone;
  final String requesterEmail;
  final String imamName;
  final PhoneInput imamPhone;
  final String imamEmail;
  final String imamFatherName;
  final String imamAge;
  final String? imamGender;
  final String imamAddress;
  final List<CommitteeMemberDraft> committeeMembers;

  /// India asks for state from a list and a district.
  static bool isIndia(CountryCode country) => country.isoCode == 'IN';

  /// The API body: trimmed, phones normalized, empty optional fields left
  /// out. Call only after the form validated (ages and genders are set).
  CreateMasjidRequest toRequest() {
    return CreateMasjidRequest(
      requesterName: requesterName.trim(),
      requesterPhone: requesterPhone.normalized,
      requesterEmail: _optional(requesterEmail),
      masjidName: masjidName.trim(),
      country: masjidCountry.name,
      district: isIndia(masjidCountry) ? _optional(district) : null,
      locality: locality.trim(),
      state: state.trim(),
      address: address.trim(),
      contactNo: contactNo.isEmpty ? null : contactNo.normalized,
      description: _optional(description),
      welcomeMsg: _optional(welcomeMsg),
      imamName: imamName.trim(),
      imamPhone: imamPhone.normalized,
      imamEmail: _optional(imamEmail),
      imamAddress: imamAddress.trim(),
      imamFatherName: imamFatherName.trim(),
      imamAge: int.parse(imamAge.trim()),
      imamGender: imamGender!,
      committeeMembers: committeeMembers
          .map(
            (member) => CommitteeMemberInput(
              name: member.name.trim(),
              phone: member.phone.normalized,
              fatherName: member.fatherName.trim(),
              age: int.parse(member.age.trim()),
              gender: member.gender!,
            ),
          )
          .toList(),
    );
  }

  static String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

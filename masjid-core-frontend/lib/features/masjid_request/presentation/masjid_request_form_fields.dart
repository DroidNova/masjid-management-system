import 'package:flutter/widgets.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_draft.dart';
import 'package:masjid_core_frontend/shared/models/country_code.dart';
import 'package:masjid_core_frontend/shared/utils/country_code_utils.dart';

/// Text controllers and picked values of one committee member's fields.
class CommitteeMemberFields {
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController fatherName = TextEditingController();
  final TextEditingController age = TextEditingController();
  String? gender;
  CountryCode country = getDefaultCountryCode();

  CommitteeMemberDraft toDraft() => CommitteeMemberDraft(
    name: name.text,
    phone: PhoneInput(country: country, number: phone.text),
    fatherName: fatherName.text,
    age: age.text,
    gender: gender,
  );

  void dispose() {
    name.dispose();
    phone.dispose();
    fatherName.dispose();
    age.dispose();
  }
}

/// All local input state of the masjid registration form. Owned and disposed
/// by the form screen; the section widgets edit it.
class MasjidRequestFormFields {
  MasjidRequestFormFields() {
    committeeMembers.add(CommitteeMemberFields());
  }

  // Masjid
  final TextEditingController masjidName = TextEditingController();
  CountryCode masjidCountry = getDefaultCountryCode();
  final TextEditingController state = TextEditingController();
  final TextEditingController district = TextEditingController();
  final TextEditingController locality = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController contactNo = TextEditingController();
  CountryCode contactCountry = getDefaultCountryCode();
  final TextEditingController welcomeMsg = TextEditingController();
  final TextEditingController description = TextEditingController();

  // Requester
  final TextEditingController requesterName = TextEditingController();
  final TextEditingController requesterPhone = TextEditingController();
  CountryCode requesterCountry = getDefaultCountryCode();
  final TextEditingController requesterEmail = TextEditingController();

  // Imam
  final TextEditingController imamName = TextEditingController();
  final TextEditingController imamPhone = TextEditingController();
  CountryCode imamCountry = getDefaultCountryCode();
  final TextEditingController imamEmail = TextEditingController();
  final TextEditingController imamFatherName = TextEditingController();
  final TextEditingController imamAge = TextEditingController();
  String? imamGender;
  final TextEditingController imamAddress = TextEditingController();

  final List<CommitteeMemberFields> committeeMembers =
      <CommitteeMemberFields>[];

  bool get isIndia => MasjidRequestDraft.isIndia(masjidCountry);

  /// State and district depend on the country, so they reset with it.
  void changeMasjidCountry(CountryCode country) {
    masjidCountry = country;
    state.clear();
    district.clear();
  }

  MasjidRequestDraft toDraft() => MasjidRequestDraft(
    masjidName: masjidName.text,
    masjidCountry: masjidCountry,
    state: state.text,
    district: district.text,
    locality: locality.text,
    address: address.text,
    contactNo: PhoneInput(country: contactCountry, number: contactNo.text),
    welcomeMsg: welcomeMsg.text,
    description: description.text,
    requesterName: requesterName.text,
    requesterPhone: PhoneInput(
      country: requesterCountry,
      number: requesterPhone.text,
    ),
    requesterEmail: requesterEmail.text,
    imamName: imamName.text,
    imamPhone: PhoneInput(country: imamCountry, number: imamPhone.text),
    imamEmail: imamEmail.text,
    imamFatherName: imamFatherName.text,
    imamAge: imamAge.text,
    imamGender: imamGender,
    imamAddress: imamAddress.text,
    committeeMembers: committeeMembers
        .map((member) => member.toDraft())
        .toList(),
  );

  void dispose() {
    for (final controller in <TextEditingController>[
      masjidName,
      state,
      district,
      locality,
      address,
      contactNo,
      welcomeMsg,
      description,
      requesterName,
      requesterPhone,
      requesterEmail,
      imamName,
      imamPhone,
      imamEmail,
      imamFatherName,
      imamAge,
      imamAddress,
    ]) {
      controller.dispose();
    }
    for (final member in committeeMembers) {
      member.dispose();
    }
  }
}

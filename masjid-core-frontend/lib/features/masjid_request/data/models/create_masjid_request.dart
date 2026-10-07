// Freezed forwards @JsonSerializable on the factory to the generated class.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/models/committee_member_input.dart';

part 'create_masjid_request.freezed.dart';
part 'create_masjid_request.g.dart';

/// Body of the public `POST /masjid-requests` (CreateMasjidRequestDto).
/// Null fields are left out.
@freezed
abstract class CreateMasjidRequest with _$CreateMasjidRequest {
  @JsonSerializable(includeIfNull: false)
  const factory CreateMasjidRequest({
    required String requesterName,
    required String requesterPhone,
    String? requesterEmail,
    required String masjidName,
    required String country,
    String? district,
    required String locality,
    required String state,
    required String address,
    String? contactNo,
    String? description,
    String? welcomeMsg,
    required String imamName,
    required String imamPhone,
    String? imamEmail,
    required String imamAddress,
    required String imamFatherName,
    required int imamAge,
    required String imamGender,
    required List<CommitteeMemberInput> committeeMembers,
  }) = _CreateMasjidRequest;

  factory CreateMasjidRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMasjidRequestFromJson(json);
}

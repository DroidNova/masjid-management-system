import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_masjid_request_model.freezed.dart';
part 'admin_masjid_request_model.g.dart';

/// One committee member stored on a masjid registration request.
@freezed
abstract class CommitteeMember with _$CommitteeMember {
  const factory CommitteeMember({
    String? name,
    String? phone,
    String? fatherName,
    int? age,
    String? gender,
  }) = _CommitteeMember;

  factory CommitteeMember.fromJson(Map<String, dynamic> json) =>
      _$CommitteeMemberFromJson(json);
}

/// A masjid registration request as `GET /masjid-requests` returns it.
@freezed
abstract class AdminMasjidRequestModel with _$AdminMasjidRequestModel {
  const factory AdminMasjidRequestModel({
    required String id,
    required String masjidName,

    /// `PENDING`, `APPROVED` or `REJECTED`.
    required String status,
    String? requesterName,
    String? requesterPhone,
    String? requesterEmail,
    String? country,
    String? state,
    String? district,
    String? locality,
    String? address,
    String? contactNo,
    String? description,
    String? welcomeMsg,
    String? imamName,
    String? imamEmail,
    String? imamPhone,
    String? imamAddress,
    String? imamFatherName,
    int? imamAge,
    String? imamGender,
    @Default(<CommitteeMember>[]) List<CommitteeMember> committeeMembers,
    String? rejectionReason,
    String? createdMasjidId,
    DateTime? reviewedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AdminMasjidRequestModel;

  const AdminMasjidRequestModel._();

  factory AdminMasjidRequestModel.fromJson(Map<String, dynamic> json) =>
      _$AdminMasjidRequestModelFromJson(json);

  bool get isPending => status == 'PENDING';
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_user_model.freezed.dart';
part 'community_user_model.g.dart';

/// A user of the signed-in user's masjid (`GET /masjids/my/users`), also
/// returned when a user is created or updated.
///
/// `phone` and `email` are null for viewers without `members.contact.read`.
/// `message` and `temporaryPassword` are only sent on create.
@freezed
abstract class CommunityUserModel with _$CommunityUserModel {
  const factory CommunityUserModel({
    required String id,
    required String fullName,
    @Default(<String>[]) List<String> roles,
    String? email,
    String? phone,
    String? status,
    String? masjidId,
    String? message,
    String? temporaryPassword,
    String? fatherName,
    int? age,
    String? gender,
    @Default(false) bool isFamilyHead,
    int? familyMemberCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CommunityUserModel;

  const CommunityUserModel._();

  factory CommunityUserModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityUserModelFromJson(json);

  bool get isImam => roles.contains('IMAM');
  bool get isCommitteeMember => roles.contains('COMMITTEE_MEMBER');
  bool get isMember => roles.contains('MEMBER');
  bool get isMasjidAdmin => roles.contains('MASJID_ADMIN');

  String get primaryRoleLabel {
    if (isMasjidAdmin) return 'Masjid Admin';
    if (isImam) return 'Imam';
    if (isCommitteeMember) return 'Committee Member';
    if (isMember) return 'Member';
    if (roles.contains('SUPER_ADMIN')) return 'Super Admin';
    return 'Member';
  }
}

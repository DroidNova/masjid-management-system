// Freezed forwards @JsonSerializable on the factory to the generated class.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_community_user_request.freezed.dart';
part 'update_community_user_request.g.dart';

/// Body of `PATCH /masjids/my/users/:userId`. Null fields are left out.
@freezed
abstract class UpdateCommunityUserRequest with _$UpdateCommunityUserRequest {
  @JsonSerializable(includeIfNull: false)
  const factory UpdateCommunityUserRequest({
    required String fullName,
    required String phone,
    required String fatherName,
    required int age,
    required String gender,
    String? email,
    bool? isFamilyHead,
    int? familyMemberCount,
  }) = _UpdateCommunityUserRequest;

  factory UpdateCommunityUserRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCommunityUserRequestFromJson(json);
}

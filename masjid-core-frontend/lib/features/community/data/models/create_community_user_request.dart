// Freezed forwards @JsonSerializable on the factory to the generated class.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_community_user_request.freezed.dart';
part 'create_community_user_request.g.dart';

/// Body of `POST /masjids/my/users`. Null fields are left out.
@freezed
abstract class CreateCommunityUserRequest with _$CreateCommunityUserRequest {
  @JsonSerializable(includeIfNull: false)
  const factory CreateCommunityUserRequest({
    required String fullName,
    required String phone,
    required String role,
    required String fatherName,
    required int age,
    required String gender,
    String? email,
    bool? isFamilyHead,
    int? familyMemberCount,
    String? masjidId,
  }) = _CreateCommunityUserRequest;

  factory CreateCommunityUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCommunityUserRequestFromJson(json);
}

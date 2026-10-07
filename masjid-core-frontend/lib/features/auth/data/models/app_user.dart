import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// The signed-in user, as returned by login and `/auth/me`.
///
/// This is the reference pattern for models (M4): `freezed` gives immutability,
/// `==` and `copyWith`; `json_serializable` writes `fromJson`/`toJson`.
/// Regenerate after edits with:
///   dart run build_runner build --delete-conflicting-outputs
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String fullName,
    @Default(<String>[]) List<String> roles,

    /// Permission names from `masjid-core/src/access/permissions.ts`.
    @Default(<String>[]) List<String> permissions,
    String? email,
    String? phone,
    String? status,
    String? masjidId,
    @Default(false) bool isEmailVerified,
    @Default(false) bool isPhoneVerified,

    /// Members only; missing in older stored sessions.
    @Default(false) bool isFamilyHead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_user_model.freezed.dart';
part 'admin_user_model.g.dart';

/// A user as `GET /admin/users` (list) and `GET /admin/users/:id` return it.
/// The detail response has no `masjidId` / `masjidName`.
@freezed
abstract class AdminUserModel with _$AdminUserModel {
  const factory AdminUserModel({
    required String id,
    required String fullName,
    required String status,
    String? email,
    String? phone,
    String? fatherName,
    int? age,
    String? gender,
    String? masjidId,
    String? masjidName,
    @Default(<String>[]) List<String> roles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AdminUserModel;

  factory AdminUserModel.fromJson(Map<String, dynamic> json) =>
      _$AdminUserModelFromJson(json);
}

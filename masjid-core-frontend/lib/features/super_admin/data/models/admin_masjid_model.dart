import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_masjid_model.freezed.dart';
part 'admin_masjid_model.g.dart';

/// A masjid as `GET /admin/masjids` and `GET /admin/masjids/:id` return it.
@freezed
abstract class AdminMasjidModel with _$AdminMasjidModel {
  const factory AdminMasjidModel({
    required String id,
    required String name,
    required String status,
    String? country,
    String? state,
    String? district,
    String? locality,
    String? address,
    String? contactNo,
    String? description,
    String? welcomeMsg,
    String? rejectionReason,
    String? requestedByName,
    String? requestedByPhone,
    String? requestedByEmail,
    String? imamUserId,
    String? imamName,
    @Default(0) int usersCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AdminMasjidModel;

  factory AdminMasjidModel.fromJson(Map<String, dynamic> json) =>
      _$AdminMasjidModelFromJson(json);
}

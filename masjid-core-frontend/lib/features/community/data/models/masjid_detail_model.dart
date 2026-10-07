import 'package:freezed_annotation/freezed_annotation.dart';

part 'masjid_detail_model.freezed.dart';
part 'masjid_detail_model.g.dart';

/// The signed-in user's masjid profile (`GET /masjids/my`).
@freezed
abstract class MasjidDetailModel with _$MasjidDetailModel {
  const factory MasjidDetailModel({
    required String id,
    required String name,
    String? country,
    String? locality,
    String? district,
    String? state,
    String? address,
    String? contactNo,
    String? description,
    String? welcomeMsg,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MasjidDetailModel;

  factory MasjidDetailModel.fromJson(Map<String, dynamic> json) =>
      _$MasjidDetailModelFromJson(json);
}

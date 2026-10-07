import 'package:freezed_annotation/freezed_annotation.dart';

part 'namaz_time_model.freezed.dart';
part 'namaz_time_model.g.dart';

/// Prayer timings of one masjid (`GET/PUT /namaz-times/:masjidId`).
///
/// A masjid that has not saved its times yet comes back with only
/// `masjidId` and null times (no `id`, `createdAt`, `updatedAt`).
@freezed
abstract class NamazTimeModel with _$NamazTimeModel {
  const factory NamazTimeModel({
    String? id,
    String? masjidId,
    String? fajr,
    String? zuhr,
    String? asr,
    String? maghrib,
    String? isha,
    String? jumma,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _NamazTimeModel;

  factory NamazTimeModel.fromJson(Map<String, dynamic> json) =>
      _$NamazTimeModelFromJson(json);
}

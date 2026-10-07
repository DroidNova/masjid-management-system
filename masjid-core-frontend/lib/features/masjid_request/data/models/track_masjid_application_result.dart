import 'package:freezed_annotation/freezed_annotation.dart';

part 'track_masjid_application_result.freezed.dart';
part 'track_masjid_application_result.g.dart';

/// One application from the public `POST /masjid-requests/track`.
@freezed
abstract class TrackMasjidApplicationResult
    with _$TrackMasjidApplicationResult {
  const factory TrackMasjidApplicationResult({
    required String masjidName,
    @Default('PENDING') String status,
    String? imamName,
    DateTime? requestedAt,
    DateTime? reviewedAt,
  }) = _TrackMasjidApplicationResult;

  factory TrackMasjidApplicationResult.fromJson(Map<String, dynamic> json) =>
      _$TrackMasjidApplicationResultFromJson(json);
}

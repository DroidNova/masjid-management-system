// freezed: @JsonSerializable on the factory configures the generated class.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_namaz_time_request.freezed.dart';
part 'update_namaz_time_request.g.dart';

/// Body of `PUT /namaz-times/:masjidId` (UpsertNamazTimeDto).
///
/// Null fields are left out of the JSON, so the server keeps their values.
@freezed
abstract class UpdateNamazTimeRequest with _$UpdateNamazTimeRequest {
  @JsonSerializable(includeIfNull: false)
  const factory UpdateNamazTimeRequest({
    String? fajr,
    String? zuhr,
    String? asr,
    String? maghrib,
    String? isha,
    String? jumma,
    String? note,
  }) = _UpdateNamazTimeRequest;

  /// From raw form text: values are trimmed and empty fields are omitted.
  factory UpdateNamazTimeRequest.fromForm({
    String? fajr,
    String? zuhr,
    String? asr,
    String? maghrib,
    String? isha,
    String? jumma,
    String? note,
  }) => UpdateNamazTimeRequest(
    fajr: _clean(fajr),
    zuhr: _clean(zuhr),
    asr: _clean(asr),
    maghrib: _clean(maghrib),
    isha: _clean(isha),
    jumma: _clean(jumma),
    note: _clean(note),
  );

  factory UpdateNamazTimeRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateNamazTimeRequestFromJson(json);
}

String? _clean(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

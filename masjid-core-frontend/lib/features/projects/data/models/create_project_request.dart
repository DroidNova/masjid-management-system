// freezed: @JsonSerializable on the factory configures the generated class.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_project_request.freezed.dart';
part 'create_project_request.g.dart';

/// Body of `POST /projects/my-masjid`. Null fields are left out. Collected
/// and spent amounts are computed by the server, never sent.
@freezed
abstract class CreateProjectRequest with _$CreateProjectRequest {
  @JsonSerializable(includeIfNull: false)
  const factory CreateProjectRequest({
    required String title,
    String? description,
    @Default(0) double targetAmount,
    @Default('ONGOING') String status,

    /// `yyyy-MM-dd`.
    String? startDate,

    /// `yyyy-MM-dd`.
    String? endDate,
  }) = _CreateProjectRequest;

  factory CreateProjectRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProjectRequestFromJson(json);
}

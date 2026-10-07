// freezed: @JsonSerializable on the factory configures the generated class.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_project_request.freezed.dart';
part 'create_project_request.g.dart';

/// Body of `POST /projects/my-masjid`. Null fields are left out.
@freezed
abstract class CreateProjectRequest with _$CreateProjectRequest {
  @JsonSerializable(includeIfNull: false)
  const factory CreateProjectRequest({
    required String title,
    String? description,
    @Default(0) double targetAmount,
    @Default(0) double collectedAmount,
    @Default(0) double spentAmount,
    @Default('ONGOING') String status,

    /// `yyyy-MM-dd`.
    String? startDate,

    /// `yyyy-MM-dd`.
    String? endDate,
  }) = _CreateProjectRequest;

  factory CreateProjectRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProjectRequestFromJson(json);
}

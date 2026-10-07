// freezed: @JsonSerializable on the factory configures the generated class.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_project_request.freezed.dart';
part 'update_project_request.g.dart';

/// Body of `PATCH /projects/{id}`. Null fields are left out (unchanged).
@freezed
abstract class UpdateProjectRequest with _$UpdateProjectRequest {
  @JsonSerializable(includeIfNull: false)
  const factory UpdateProjectRequest({
    String? title,
    String? description,
    double? targetAmount,
    double? collectedAmount,
    double? spentAmount,
    String? status,

    /// `yyyy-MM-dd`.
    String? startDate,

    /// `yyyy-MM-dd`.
    String? endDate,
  }) = _UpdateProjectRequest;

  factory UpdateProjectRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProjectRequestFromJson(json);
}

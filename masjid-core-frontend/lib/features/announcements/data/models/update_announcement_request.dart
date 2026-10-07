// freezed: @JsonSerializable on the factory configures the generated class.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_announcement_request.freezed.dart';
part 'update_announcement_request.g.dart';

/// Body of `PATCH /announcements/:id` (UpdateAnnouncementDto).
///
/// Null fields are left out of the JSON, so the server keeps their values.
@freezed
abstract class UpdateAnnouncementRequest with _$UpdateAnnouncementRequest {
  @JsonSerializable(includeIfNull: false)
  const factory UpdateAnnouncementRequest({
    String? title,
    String? message,
    bool? isActive,
  }) = _UpdateAnnouncementRequest;

  /// From raw form text (trimmed).
  factory UpdateAnnouncementRequest.fromForm({
    required String title,
    required String message,
    required bool isActive,
  }) => UpdateAnnouncementRequest(
    title: title.trim(),
    message: message.trim(),
    isActive: isActive,
  );

  factory UpdateAnnouncementRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateAnnouncementRequestFromJson(json);
}

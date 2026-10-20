import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_announcement_request.freezed.dart';
part 'create_announcement_request.g.dart';

/// Body of `POST /announcements/my-masjid` (CreateAnnouncementDto).
@freezed
abstract class CreateAnnouncementRequest with _$CreateAnnouncementRequest {
  const factory CreateAnnouncementRequest({
    required String title,
    required String message,
    @Default(true) bool isActive,

    /// Members only unless the poster chose "Everyone".
    @Default(false) bool isPublic,
  }) = _CreateAnnouncementRequest;

  /// From raw form text (trimmed).
  factory CreateAnnouncementRequest.fromForm({
    required String title,
    required String message,
    required bool isActive,
    required bool isPublic,
  }) => CreateAnnouncementRequest(
    title: title.trim(),
    message: message.trim(),
    isActive: isActive,
    isPublic: isPublic,
  );

  factory CreateAnnouncementRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAnnouncementRequestFromJson(json);
}

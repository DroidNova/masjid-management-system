import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/create_announcement_request.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/update_announcement_request.dart';

/// Announcement endpoints. Errors surface as ApiException (with `code`).
class AnnouncementsApi {
  AnnouncementsApi(this._apiClient);

  final ApiClient _apiClient;

  Future<PageResult<AnnouncementModel>> getAnnouncements({
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/announcements/my-masjid',
      // Only visible news: "delete" marks an announcement inactive, and it
      // must disappear for everyone (the Home screen filters the same way).
      query: <String, dynamic>{'page': page, 'limit': limit, 'isActive': true},
    );
    return PageResult.fromJson(data, AnnouncementModel.fromJson);
  }

  Future<AnnouncementModel> getAnnouncement(String id) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/announcements/$id',
    );
    return AnnouncementModel.fromJson(data);
  }

  Future<AnnouncementModel> createAnnouncement(
    CreateAnnouncementRequest request,
  ) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/announcements/my-masjid',
      body: request.toJson(),
    );
    return AnnouncementModel.fromJson(data);
  }

  Future<AnnouncementModel> updateAnnouncement(
    String id,
    UpdateAnnouncementRequest request,
  ) async {
    final data = await _apiClient.patch<Map<String, dynamic>>(
      '/announcements/$id',
      body: request.toJson(),
    );
    return AnnouncementModel.fromJson(data);
  }

  /// The server keeps the announcement and marks it inactive.
  Future<AnnouncementModel> deactivateAnnouncement(String id) async {
    final data = await _apiClient.delete<Map<String, dynamic>>(
      '/announcements/$id',
    );
    return AnnouncementModel.fromJson(data);
  }
}

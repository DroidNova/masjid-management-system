import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/announcements/data/announcements_api.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/create_announcement_request.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/update_announcement_request.dart';

final announcementsRepositoryProvider = Provider<AnnouncementsRepository>(
  (ref) =>
      AnnouncementsRepository(AnnouncementsApi(ref.watch(apiClientProvider))),
);

/// `errorCode` the server uses for a missing announcement.

class AnnouncementsRepository {
  AnnouncementsRepository(this._api);

  final AnnouncementsApi _api;

  /// Page size used when looking one announcement up by id.

  Future<PageResult<AnnouncementModel>> getAnnouncements({
    int page = 1,
    int limit = 20,
  }) => _api.getAnnouncements(page: page, limit: limit);

  /// One announcement of the current masjid (GET /announcements/:id).
  /// Throws ApiException ANNOUNCEMENT_NOT_FOUND (also for another masjid's id).
  Future<AnnouncementModel> getAnnouncement(String id) =>
      _api.getAnnouncement(id);

  Future<AnnouncementModel> createAnnouncement(
    CreateAnnouncementRequest request,
  ) => _api.createAnnouncement(request);

  Future<AnnouncementModel> updateAnnouncement(
    String id,
    UpdateAnnouncementRequest request,
  ) => _api.updateAnnouncement(id, request);

  Future<AnnouncementModel> deactivateAnnouncement(String id) =>
      _api.deactivateAnnouncement(id);
}

import 'package:platform_core_frontend/core/network/api_request_coordinator.dart';
import 'package:platform_core_frontend/core/refresh/app_data_refresh_bus.dart';
import 'package:platform_core_frontend/features/announcements/data/announcements_api.dart';
import 'package:platform_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:platform_core_frontend/features/announcements/data/models/create_announcement_request.dart';
import 'package:platform_core_frontend/features/announcements/data/models/update_announcement_request.dart';

class AnnouncementsRepository {
  AnnouncementsRepository({AnnouncementsApi? announcementsApi})
      : _announcementsApi = announcementsApi ?? AnnouncementsApi();

  final AnnouncementsApi _announcementsApi;

  Future<List<AnnouncementModel>> getAnnouncements() {
    return ApiRequestCoordinator.instance.run<List<AnnouncementModel>>(
      key: 'GET:/announcements',
      request: _announcementsApi.getAnnouncements,
    );
  }

  Future<AnnouncementModel> createAnnouncement(
    CreateAnnouncementRequest request,
  ) async {
    final announcement = await _announcementsApi.createAnnouncement(request);
    AppDataRefreshBus.instance.notifyMany(<AppDataScope>[
      AppDataScope.announcements,
      AppDataScope.dashboard,
    ]);
    return announcement;
  }

  Future<AnnouncementModel> updateAnnouncement(
    String id,
    UpdateAnnouncementRequest request,
  ) async {
    final announcement = await _announcementsApi.updateAnnouncement(id, request);
    AppDataRefreshBus.instance.notifyMany(<AppDataScope>[
      AppDataScope.announcements,
      AppDataScope.dashboard,
    ]);
    return announcement;
  }

  Future<void> deleteAnnouncement(String id) async {
    await _announcementsApi.deleteAnnouncement(id);
    AppDataRefreshBus.instance.notifyMany(<AppDataScope>[
      AppDataScope.announcements,
      AppDataScope.dashboard,
    ]);
  }
}

import 'package:platform_core_frontend/core/network/api_request_coordinator.dart';
import 'package:platform_core_frontend/core/refresh/app_data_refresh_bus.dart';
import 'package:platform_core_frontend/features/community/data/community_api.dart';
import 'package:platform_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:platform_core_frontend/features/community/data/models/create_community_user_request.dart';
import 'package:platform_core_frontend/features/community/data/models/masjid_detail_model.dart';

class CommunityRepository {
  CommunityRepository({CommunityApi? communityApi})
      : _communityApi = communityApi ?? CommunityApi();

  final CommunityApi _communityApi;

  Future<MasjidDetailModel> getMyMasjid() {
    return ApiRequestCoordinator.instance.run<MasjidDetailModel>(
      key: 'GET:/masjids/my',
      request: _communityApi.getMyMasjid,
    );
  }

  Future<List<CommunityUserModel>> getMyMasjidUsers() {
    return ApiRequestCoordinator.instance.run<List<CommunityUserModel>>(
      key: 'GET:/masjids/my/users',
      request: _communityApi.getMyMasjidUsers,
    );
  }

  Future<CommunityUserModel> createMasjidUser(
    CreateCommunityUserRequest request,
  ) async {
    final user = await _communityApi.createMasjidUser(request);
    AppDataRefreshBus.instance.notifyMany(<AppDataScope>[
      AppDataScope.community,
      AppDataScope.dashboard,
    ]);
    return user;
  }
}

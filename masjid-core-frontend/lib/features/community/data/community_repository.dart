import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/community/data/community_api.dart';
import 'package:masjid_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:masjid_core_frontend/features/community/data/models/create_community_user_request.dart';
import 'package:masjid_core_frontend/features/community/data/models/masjid_detail_model.dart';
import 'package:masjid_core_frontend/features/community/data/models/update_community_user_request.dart';

final communityRepositoryProvider = Provider<CommunityRepository>(
  (ref) => CommunityRepository(CommunityApi(ref.watch(apiClientProvider))),
);

class CommunityRepository {
  /// Use [communityRepositoryProvider]. Calling it without an api is only for
  /// screens not migrated yet (contributions); it uses the shared ApiClient.
  CommunityRepository([CommunityApi? api])
    : _api = api ?? CommunityApi(ApiClient());

  final CommunityApi _api;

  Future<MasjidDetailModel> getMyMasjid() => _api.getMyMasjid();

  Future<void> leaveMyMasjid() => _api.leaveMyMasjid();

  Future<List<CommunityUserModel>> getMyMasjidUsers() =>
      _api.getMyMasjidUsers();

  Future<CommunityUserModel> createMasjidUser(
    CreateCommunityUserRequest request,
  ) => _api.createMasjidUser(request);

  Future<CommunityUserModel> updateMasjidUser(
    String userId,
    UpdateCommunityUserRequest request,
  ) => _api.updateMasjidUser(userId, request);

  Future<CommunityUserModel> updateMasjidUserStatus(
    String userId,
    String status,
  ) => _api.updateMasjidUserStatus(userId, status);
}

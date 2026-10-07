import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:masjid_core_frontend/features/community/data/models/create_community_user_request.dart';
import 'package:masjid_core_frontend/features/community/data/models/masjid_detail_model.dart';
import 'package:masjid_core_frontend/features/community/data/models/update_community_user_request.dart';

/// Masjid profile and member endpoints. Errors surface as ApiException.
class CommunityApi {
  CommunityApi(this._apiClient);

  final ApiClient _apiClient;

  Future<MasjidDetailModel> getMyMasjid() async {
    final data = await _apiClient.get<Map<String, dynamic>>('/masjids/my');
    return MasjidDetailModel.fromJson(data);
  }

  /// Leaves the signed-in user's masjid.
  Future<void> leaveMyMasjid() async {
    await _apiClient.post<Object?>('/masjids/my/leave');
  }

  Future<List<CommunityUserModel>> getMyMasjidUsers() async {
    final data = await _apiClient.get<List<dynamic>>('/masjids/my/users');
    return data
        .cast<Map<String, dynamic>>()
        .map(CommunityUserModel.fromJson)
        .toList();
  }

  Future<CommunityUserModel> createMasjidUser(
    CreateCommunityUserRequest request,
  ) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/masjids/my/users',
      body: request.toJson(),
    );
    return CommunityUserModel.fromJson(data);
  }

  Future<CommunityUserModel> updateMasjidUser(
    String userId,
    UpdateCommunityUserRequest request,
  ) async {
    final data = await _apiClient.patch<Map<String, dynamic>>(
      '/masjids/my/users/$userId',
      body: request.toJson(),
    );
    return CommunityUserModel.fromJson(data);
  }

  Future<CommunityUserModel> updateMasjidUserStatus(
    String userId,
    String status,
  ) async {
    final data = await _apiClient.patch<Map<String, dynamic>>(
      '/masjids/my/users/$userId/status',
      body: <String, dynamic>{'status': status},
    );
    return CommunityUserModel.fromJson(data);
  }
}

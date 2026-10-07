import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_dashboard_summary.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_list_filter.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_request_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_user_model.dart';

/// Super admin endpoints. Errors surface as ApiException (with `code`).
class SuperAdminApi {
  SuperAdminApi(this._apiClient);

  final ApiClient _apiClient;

  static const int pageSize = 20;

  Future<AdminDashboardSummary> getDashboardSummary() async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/admin/dashboard/summary',
    );
    return AdminDashboardSummary.fromJson(data);
  }

  // ------------------------------------------------------------------ users

  Future<PageResult<AdminUserModel>> getUsers(
    AdminListFilter filter,
    int page,
  ) => _getPage('/admin/users', filter, page, AdminUserModel.fromJson);

  Future<AdminUserModel> getUser(String id) async {
    final data = await _apiClient.get<Map<String, dynamic>>('/admin/users/$id');
    return AdminUserModel.fromJson(data);
  }

  Future<void> updateUserStatus(String id, String status) async {
    await _apiClient.patch<Object?>(
      '/admin/users/$id/status',
      body: <String, dynamic>{'status': status},
    );
  }

  /// Replaces the user's roles; returns the updated user.
  Future<AdminUserModel> assignUserRoles(String id, List<String> roles) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/admin/users/$id/roles',
      body: <String, dynamic>{'roleNames': roles},
    );
    return AdminUserModel.fromJson(data);
  }

  // ---------------------------------------------------------------- masjids

  Future<PageResult<AdminMasjidModel>> getMasjids(
    AdminListFilter filter,
    int page,
  ) => _getPage('/admin/masjids', filter, page, AdminMasjidModel.fromJson);

  Future<AdminMasjidModel> getMasjid(String id) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/admin/masjids/$id',
    );
    return AdminMasjidModel.fromJson(data);
  }

  Future<void> updateMasjidStatus(
    String id,
    String status, {
    String? reason,
  }) async {
    await _apiClient.patch<Object?>(
      '/admin/masjids/$id/status',
      body: <String, dynamic>{'status': status, 'reason': ?reason},
    );
  }

  // -------------------------------------------------------- masjid requests

  Future<PageResult<AdminMasjidRequestModel>> getMasjidRequests(
    AdminListFilter filter,
    int page,
  ) => _getPage(
    '/masjid-requests',
    filter,
    page,
    AdminMasjidRequestModel.fromJson,
  );

  /// There is no `GET /masjid-requests/:id`; the list filters by `id`.
  Future<PageResult<AdminMasjidRequestModel>> findMasjidRequestById(
    String id,
  ) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/masjid-requests',
      query: <String, dynamic>{'id': id, 'limit': 1},
    );
    return PageResult<AdminMasjidRequestModel>.fromJson(
      data,
      AdminMasjidRequestModel.fromJson,
    );
  }

  /// `status` is `APPROVED` or `REJECTED`. Approving fails with
  /// USER_IN_ANOTHER_MASJID (409) when the imam or a committee member
  /// already belongs to another masjid.
  Future<void> updateMasjidRequestStatus(
    String id,
    String status, {
    String? reason,
  }) async {
    await _apiClient.patch<Object?>(
      '/masjid-requests/$id/status',
      body: <String, dynamic>{'status': status, 'reason': ?reason},
    );
  }

  Future<PageResult<T>> _getPage<T>(
    String path,
    AdminListFilter filter,
    int page,
    T Function(Map<String, dynamic> json) parseItem,
  ) async {
    final search = filter.search.trim();
    final data = await _apiClient.get<Map<String, dynamic>>(
      path,
      query: <String, dynamic>{
        'page': page,
        'limit': pageSize,
        if (search.isNotEmpty) 'search': search,
        'status': ?filter.status,
        'role': ?filter.role,
      },
    );
    return PageResult<T>.fromJson(data, parseItem);
  }
}

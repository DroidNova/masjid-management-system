import 'package:platform_core_frontend/core/refresh/app_data_refresh_bus.dart';
import 'package:platform_core_frontend/features/super_admin/data/super_admin_api.dart';
import 'package:platform_core_frontend/features/super_admin/models/admin_dashboard_summary.dart';
import 'package:platform_core_frontend/features/super_admin/models/admin_masjid_model.dart';
import 'package:platform_core_frontend/features/super_admin/models/admin_masjid_request_model.dart';
import 'package:platform_core_frontend/features/super_admin/models/admin_user_detail_model.dart';
import 'package:platform_core_frontend/features/super_admin/models/admin_user_model.dart';

class AdminPage<T> {
  const AdminPage(this.items, this.total);

  final List<T> items;
  final int total;
}

class SuperAdminRepository {
  SuperAdminRepository({SuperAdminApi? api}) : _api = api ?? SuperAdminApi();

  final SuperAdminApi _api;

  Future<AdminPage<AdminUserModel>> getUsers({
    String? search,
    String? status,
    String? role,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await _api.getUsers(
      search: search,
      status: status,
      role: role,
      page: page,
      limit: limit,
    );
    return AdminPage<AdminUserModel>(
      result.items.map(AdminUserModel.fromJson).toList(),
      result.total,
    );
  }

  Future<AdminUserDetailModel> getUser(String id) async {
    return AdminUserDetailModel.fromJson(await _api.getUser(id));
  }

  Future<AdminUserModel> updateUserStatus(String id, String status) async {
    final updated = AdminUserModel.fromJson(
      await _api.updateUserStatus(id, <String, dynamic>{'status': status}),
    );
    AppDataRefreshBus.instance.notifyMany(<AppDataScope>[
      AppDataScope.adminUsers,
      AppDataScope.adminDashboard,
    ]);
    return updated;
  }

  Future<AdminUserModel> updateUserRoles(String id, List<String> roles) async {
    final updated = AdminUserModel.fromJson(
      await _api.updateUserRoles(id, <String, dynamic>{'roleNames': roles}),
    );
    AppDataRefreshBus.instance.notifyMany(<AppDataScope>[
      AppDataScope.adminUsers,
      AppDataScope.adminDashboard,
    ]);
    return updated;
  }

  Future<AdminPage<AdminMasjidRequestModel>> getMasjidRequests({
    String? search,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await _api.getMasjidRequests(
      search: search,
      status: status,
      page: page,
      limit: limit,
    );
    return AdminPage<AdminMasjidRequestModel>(
      result.items.map(AdminMasjidRequestModel.fromJson).toList(),
      result.total,
    );
  }

  Future<AdminMasjidRequestModel> getMasjidRequest(String id) async {
    return AdminMasjidRequestModel.fromJson(await _api.getMasjidRequest(id));
  }

  Future<AdminMasjidRequestModel> updateMasjidRequestStatus(
    String id,
    String status, {
    String? reason,
  }) async {
    final updated = AdminMasjidRequestModel.fromJson(
      await _api.updateMasjidRequestStatus(id, <String, dynamic>{
        'status': status,
        if (reason != null) 'reason': reason,
        if (reason != null) 'rejectionReason': reason,
      }),
    );
    AppDataRefreshBus.instance.notifyMany(<AppDataScope>[
      AppDataScope.adminMasjidRequests,
      AppDataScope.adminMasjids,
      AppDataScope.adminDashboard,
    ]);
    return updated;
  }

  Future<AdminPage<AdminMasjidModel>> getMasjids({
    String? search,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await _api.getMasjids(
      search: search,
      status: status,
      page: page,
      limit: limit,
    );
    return AdminPage<AdminMasjidModel>(
      result.items.map(AdminMasjidModel.fromJson).toList(),
      result.total,
    );
  }

  Future<AdminMasjidModel> getMasjid(String id) async {
    return AdminMasjidModel.fromJson(await _api.getMasjid(id));
  }

  Future<AdminMasjidModel> updateMasjidStatus(
    String id,
    String status, {
    String? reason,
  }) async {
    final updated = AdminMasjidModel.fromJson(
      await _api.updateMasjidStatus(id, <String, dynamic>{
        'status': status,
        if (reason != null) 'reason': reason,
      }),
    );
    AppDataRefreshBus.instance.notifyMany(<AppDataScope>[
      AppDataScope.adminMasjids,
      AppDataScope.adminDashboard,
    ]);
    return updated;
  }

  Future<AdminDashboardSummary> getDashboardSummary() async {
    return AdminDashboardSummary.fromJson(await _api.getDashboardSummary());
  }
}

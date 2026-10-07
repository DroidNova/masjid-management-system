import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_dashboard_summary.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_list_filter.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_request_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_user_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/super_admin_api.dart';

final superAdminRepositoryProvider = Provider<SuperAdminRepository>(
  (ref) => SuperAdminRepository(SuperAdminApi(ref.watch(apiClientProvider))),
);

/// Platform administration (super admin only). Screens change data through
/// `superAdminActionsProvider`, which also refreshes the admin screens.
class SuperAdminRepository {
  SuperAdminRepository(this._api);

  final SuperAdminApi _api;

  Future<AdminDashboardSummary> getDashboardSummary() =>
      _api.getDashboardSummary();

  Future<PageResult<AdminUserModel>> getUsers(
    AdminListFilter filter, {
    int page = 1,
  }) => _api.getUsers(filter, page);

  Future<AdminUserModel> getUser(String id) => _api.getUser(id);

  Future<void> updateUserStatus(String id, String status) =>
      _api.updateUserStatus(id, status);

  Future<AdminUserModel> assignUserRoles(String id, List<String> roles) =>
      _api.assignUserRoles(id, roles);

  Future<PageResult<AdminMasjidModel>> getMasjids(
    AdminListFilter filter, {
    int page = 1,
  }) => _api.getMasjids(filter, page);

  Future<AdminMasjidModel> getMasjid(String id) => _api.getMasjid(id);

  Future<void> updateMasjidStatus(String id, String status, {String? reason}) =>
      _api.updateMasjidStatus(id, status, reason: reason);

  Future<PageResult<AdminMasjidRequestModel>> getMasjidRequests(
    AdminListFilter filter, {
    int page = 1,
  }) => _api.getMasjidRequests(filter, page);

  Future<AdminMasjidRequestModel> getMasjidRequest(String id) =>
      _api.getMasjidRequest(id);

  Future<void> approveMasjidRequest(String id) =>
      _api.updateMasjidRequestStatus(id, 'APPROVED');

  Future<void> rejectMasjidRequest(String id, {String? reason}) =>
      _api.updateMasjidRequestStatus(id, 'REJECTED', reason: reason);
}

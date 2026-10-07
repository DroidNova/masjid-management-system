import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/super_admin/data/super_admin_repository.dart';

final superAdminActionsProvider = Provider<SuperAdminActions>(
  SuperAdminActions.new,
);

/// Admin changes. Each one refreshes every admin screen afterwards; errors
/// are rethrown as ApiException for the screen to show.
class SuperAdminActions {
  SuperAdminActions(this._ref);

  final Ref _ref;

  SuperAdminRepository get _repository =>
      _ref.read(superAdminRepositoryProvider);

  Future<void> updateUserStatus(String id, String status) =>
      _changed(_repository.updateUserStatus(id, status));

  Future<void> assignUserRoles(String id, List<String> roles) =>
      _changed(_repository.assignUserRoles(id, roles));

  Future<void> updateMasjidStatus(String id, String status) =>
      _changed(_repository.updateMasjidStatus(id, status));

  /// Throws ApiException USER_IN_ANOTHER_MASJID when the imam or a committee
  /// member already belongs to another masjid.
  Future<void> approveMasjidRequest(String id) =>
      _changed(_repository.approveMasjidRequest(id));

  Future<void> rejectMasjidRequest(String id, {String? reason}) =>
      _changed(_repository.rejectMasjidRequest(id, reason: reason));

  Future<void> _changed(Future<Object?> change) async {
    await change;
    _ref.markChanged(const <DataScope>[DataScope.admin]);
  }
}

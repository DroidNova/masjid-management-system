import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_controllers.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_user_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/super_admin_repository.dart';

final superAdminActionsProvider = Provider<SuperAdminActions>(
  SuperAdminActions.new,
);

/// Ids (user, masjid or request) with an admin change in flight. Screens
/// disable that item's buttons meanwhile so a change is not sent twice.
final adminBusyIdsProvider = StateProvider<Set<String>>(
  (ref) => const <String>{},
);

/// Admin changes. Each one reloads only the admin data it affects (plus the
/// summary); errors are rethrown as ApiException for the screen to show.
class SuperAdminActions {
  SuperAdminActions(this._ref);

  final Ref _ref;

  SuperAdminRepository get _repository =>
      _ref.read(superAdminRepositoryProvider);

  /// INACTIVE / SUSPENDED also signs that user out (server side).
  Future<void> updateUserStatus(String id, String status) => _run(
    id,
    () => _repository.updateUserStatus(id, status),
    const <DataScope>[DataScope.adminUsers, DataScope.adminSummary],
  );

  /// Shows the user the server returns instead of loading it again.
  Future<void> assignUserRoles(String id, List<String> roles) => _run(
    id,
    () async => _showUser(await _repository.assignUserRoles(id, roles)),
    const <DataScope>[DataScope.adminSummary],
  );

  /// REJECTED and SUSPENDED need a [reason].
  Future<void> updateMasjidStatus(String id, String status, {String? reason}) =>
      _run(
        id,
        () => _repository.updateMasjidStatus(id, status, reason: reason),
        const <DataScope>[DataScope.adminMasjids, DataScope.adminSummary],
      );

  /// Creates the masjid and its users. Throws ApiException
  /// USER_IN_ANOTHER_MASJID when the imam or a committee member already
  /// belongs to another masjid.
  Future<void> approveMasjidRequest(String id) =>
      _run(id, () => _repository.approveMasjidRequest(id), const <DataScope>[
        DataScope.adminRequests,
        DataScope.adminMasjids,
        DataScope.adminUsers,
        DataScope.adminSummary,
      ]);

  Future<void> rejectMasjidRequest(String id, {String? reason}) => _run(
    id,
    () => _repository.rejectMasjidRequest(id, reason: reason),
    const <DataScope>[
      DataScope.adminRequests,
      DataScope.adminMasjids,
      DataScope.adminSummary,
    ],
  );

  Future<void> _run(
    String id,
    Future<Object?> Function() change,
    List<DataScope> scopes,
  ) async {
    final busy = _ref.read(adminBusyIdsProvider.notifier);
    if (busy.state.contains(id)) return;
    busy.state = <String>{...busy.state, id};
    try {
      await change();
      _ref.markChanged(scopes);
    } finally {
      busy.state = <String>{...busy.state}..remove(id);
    }
  }

  void _showUser(AdminUserModel updated) {
    final detail = adminUserProvider(updated.id);
    if (_ref.exists(detail)) _ref.read(detail.notifier).show(updated);
    if (_ref.exists(adminUsersProvider)) {
      _ref.read(adminUsersProvider.notifier).replace(updated);
    }
  }
}

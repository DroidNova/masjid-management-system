import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_dashboard_summary.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_list_filter.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_request_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_user_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/super_admin_repository.dart';

// Every admin screen watches DataScope.admin; SuperAdminActions marks it
// after each change, so lists, details and the summary reload together.

// ---------------------------------------------------------------- dashboard

final adminDashboardProvider =
    AsyncNotifierProvider.autoDispose<
      AdminDashboardController,
      AdminDashboardSummary
    >(AdminDashboardController.new);

class AdminDashboardController
    extends AutoDisposeAsyncNotifier<AdminDashboardSummary> {
  @override
  Future<AdminDashboardSummary> build() {
    ref.watch(dataVersionProvider(DataScope.admin));
    return ref.watch(superAdminRepositoryProvider).getDashboardSummary();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

// -------------------------------------------------------------------- users

final adminUsersFilterProvider = StateProvider.autoDispose<AdminListFilter>(
  (ref) => const AdminListFilter(),
);

final adminUsersProvider =
    AsyncNotifierProvider.autoDispose<
      AdminUsersController,
      PagedState<AdminUserModel>
    >(AdminUsersController.new);

class AdminUsersController extends PagedController<AdminUserModel> {
  @override
  Future<PagedState<AdminUserModel>> build() {
    ref.watch(adminUsersFilterProvider);
    ref.watch(dataVersionProvider(DataScope.admin));
    return super.build();
  }

  @override
  Future<PageResult<AdminUserModel>> fetchPage(int page) => ref
      .read(superAdminRepositoryProvider)
      .getUsers(ref.read(adminUsersFilterProvider), page: page);
}

final adminUserProvider = AsyncNotifierProvider.autoDispose
    .family<AdminUserController, AdminUserModel, String>(
      AdminUserController.new,
    );

class AdminUserController
    extends AutoDisposeFamilyAsyncNotifier<AdminUserModel, String> {
  @override
  Future<AdminUserModel> build(String id) {
    ref.watch(dataVersionProvider(DataScope.admin));
    return ref.watch(superAdminRepositoryProvider).getUser(id);
  }
}

// ------------------------------------------------------------------ masjids

final adminMasjidsFilterProvider = StateProvider.autoDispose<AdminListFilter>(
  (ref) => const AdminListFilter(),
);

final adminMasjidsProvider =
    AsyncNotifierProvider.autoDispose<
      AdminMasjidsController,
      PagedState<AdminMasjidModel>
    >(AdminMasjidsController.new);

class AdminMasjidsController extends PagedController<AdminMasjidModel> {
  @override
  Future<PagedState<AdminMasjidModel>> build() {
    ref.watch(adminMasjidsFilterProvider);
    ref.watch(dataVersionProvider(DataScope.admin));
    return super.build();
  }

  @override
  Future<PageResult<AdminMasjidModel>> fetchPage(int page) => ref
      .read(superAdminRepositoryProvider)
      .getMasjids(ref.read(adminMasjidsFilterProvider), page: page);
}

final adminMasjidProvider = AsyncNotifierProvider.autoDispose
    .family<AdminMasjidController, AdminMasjidModel, String>(
      AdminMasjidController.new,
    );

class AdminMasjidController
    extends AutoDisposeFamilyAsyncNotifier<AdminMasjidModel, String> {
  @override
  Future<AdminMasjidModel> build(String id) {
    ref.watch(dataVersionProvider(DataScope.admin));
    return ref.watch(superAdminRepositoryProvider).getMasjid(id);
  }
}

// ---------------------------------------------------------- masjid requests

final adminRequestsFilterProvider = StateProvider.autoDispose<AdminListFilter>(
  (ref) => const AdminListFilter(),
);

final adminRequestsProvider =
    AsyncNotifierProvider.autoDispose<
      AdminRequestsController,
      PagedState<AdminMasjidRequestModel>
    >(AdminRequestsController.new);

class AdminRequestsController extends PagedController<AdminMasjidRequestModel> {
  @override
  Future<PagedState<AdminMasjidRequestModel>> build() {
    ref.watch(adminRequestsFilterProvider);
    ref.watch(dataVersionProvider(DataScope.admin));
    return super.build();
  }

  @override
  Future<PageResult<AdminMasjidRequestModel>> fetchPage(int page) => ref
      .read(superAdminRepositoryProvider)
      .getMasjidRequests(ref.read(adminRequestsFilterProvider), page: page);
}

final adminRequestProvider = AsyncNotifierProvider.autoDispose
    .family<AdminRequestController, AdminMasjidRequestModel, String>(
      AdminRequestController.new,
    );

class AdminRequestController
    extends AutoDisposeFamilyAsyncNotifier<AdminMasjidRequestModel, String> {
  @override
  Future<AdminMasjidRequestModel> build(String id) {
    ref.watch(dataVersionProvider(DataScope.admin));
    return ref.watch(superAdminRepositoryProvider).getMasjidRequest(id);
  }
}

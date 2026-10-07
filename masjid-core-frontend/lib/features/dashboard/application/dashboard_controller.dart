import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/dashboard_response.dart';

/// Home dashboard data for the signed-in user's masjid.
///
/// This is the reference pattern for screens (M4): an AsyncNotifier holds
/// loading / error / data; the screen only renders it. Riverpod removes the
/// per-screen `_isLoading`, `_errorMessage` and duplicate-request bookkeeping.
final dashboardControllerProvider =
    AsyncNotifierProvider.autoDispose<DashboardController, DashboardResponse>(
      DashboardController.new,
    );

class DashboardController extends AutoDisposeAsyncNotifier<DashboardResponse> {
  @override
  Future<DashboardResponse> build() {
    // Reload when a different user signs in.
    ref.watch(currentUserProvider.select((user) => user?.id));

    // Reload when other screens change data shown here.
    ref.watch(dataVersionProvider(DataScope.dashboard));

    return ref.watch(dashboardRepositoryProvider).getMyMasjidDashboard();
  }

  /// Pull-to-refresh: keeps showing the current data while reloading.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

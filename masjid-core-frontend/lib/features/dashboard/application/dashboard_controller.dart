import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/refresh/app_data_refresh_bus.dart';
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

    // Screens not yet migrated still announce changes on the refresh bus
    // (e.g. after adding a collection); reload when they do.
    final bus = AppDataRefreshBus.instance.notifierFor(AppDataScope.dashboard);
    void onChanged() => ref.invalidateSelf();
    bus.addListener(onChanged);
    ref.onDispose(() => bus.removeListener(onChanged));

    return ref.watch(dashboardRepositoryProvider).getMyMasjidDashboard();
  }

  /// Pull-to-refresh: keeps showing the current data while reloading.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

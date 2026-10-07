import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/dashboard/data/dashboard_api.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/dashboard_response.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(DashboardApi(ref.watch(apiClientProvider))),
);

class DashboardRepository {
  DashboardRepository(this._api);

  final DashboardApi _api;

  Future<DashboardResponse> getMyMasjidDashboard() =>
      _api.getMyMasjidDashboard();
}

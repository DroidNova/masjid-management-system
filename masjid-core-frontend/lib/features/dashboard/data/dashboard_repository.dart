import 'package:platform_core_frontend/core/network/api_request_coordinator.dart';
import 'package:platform_core_frontend/features/dashboard/data/dashboard_api.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/dashboard_response.dart';

class DashboardRepository {
  DashboardRepository({DashboardApi? dashboardApi})
      : _dashboardApi = dashboardApi ?? DashboardApi();

  final DashboardApi _dashboardApi;

  Future<DashboardResponse> getMyMasjidDashboard() {
    return ApiRequestCoordinator.instance.run<DashboardResponse>(
      key: 'GET:/dashboard/my-masjid',
      request: _dashboardApi.getMyMasjidDashboard,
    );
  }
}

import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/dashboard_response.dart';

/// Dashboard endpoints. Errors surface as ApiException (with `code`).
class DashboardApi {
  DashboardApi(this._apiClient);

  final ApiClient _apiClient;

  Future<DashboardResponse> getMyMasjidDashboard() async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/dashboard/my-masjid',
    );
    return DashboardResponse.fromJson(data);
  }
}

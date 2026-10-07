import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/models/create_masjid_request.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/models/track_masjid_application_result.dart';

/// Public masjid registration endpoints (no login). Errors: ApiException.
class MasjidRequestApi {
  MasjidRequestApi(this._apiClient);

  final ApiClient _apiClient;

  Future<void> submitMasjidRequest(CreateMasjidRequest request) async {
    await _apiClient.post<Object?>('/masjid-requests', body: request.toJson());
  }

  /// Applications made with this phone number, newest first.
  Future<List<TrackMasjidApplicationResult>> trackApplicationByPhone(
    String requesterPhone,
  ) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/masjid-requests/track',
      body: <String, dynamic>{'requesterPhone': requesterPhone},
    );
    final items = data['items'] as List<dynamic>? ?? const <dynamic>[];
    return items
        .cast<Map<String, dynamic>>()
        .map(TrackMasjidApplicationResult.fromJson)
        .toList();
  }
}

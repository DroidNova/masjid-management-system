import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/namaz_time_model.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/update_namaz_time_request.dart';

/// Namaz time endpoints. Errors surface as ApiException (with `code`).
class NamazTimeApi {
  NamazTimeApi(this._apiClient);

  final ApiClient _apiClient;

  /// The signed-in user's masjid (taken from the token).
  Future<NamazTimeModel> getMyNamazTime() async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/namaz-times/my-masjid',
    );
    return NamazTimeModel.fromJson(data);
  }

  Future<NamazTimeModel> updateMyNamazTime(
    UpdateNamazTimeRequest request,
  ) async {
    final data = await _apiClient.put<Map<String, dynamic>>(
      '/namaz-times/my-masjid',
      body: request.toJson(),
    );
    return NamazTimeModel.fromJson(data);
  }
}

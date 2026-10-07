import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/namaz_time_model.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/update_namaz_time_request.dart';

/// Namaz time endpoints. Errors surface as ApiException (with `code`).
class NamazTimeApi {
  NamazTimeApi(this._apiClient);

  final ApiClient _apiClient;

  Future<NamazTimeModel> getNamazTime(String masjidId) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/namaz-times/$masjidId',
    );
    return NamazTimeModel.fromJson(data);
  }

  Future<NamazTimeModel> updateNamazTime({
    required String masjidId,
    required UpdateNamazTimeRequest request,
  }) async {
    final data = await _apiClient.put<Map<String, dynamic>>(
      '/namaz-times/$masjidId',
      body: request.toJson(),
    );
    return NamazTimeModel.fromJson(data);
  }
}

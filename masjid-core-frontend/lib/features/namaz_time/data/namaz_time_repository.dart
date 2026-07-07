import 'package:platform_core_frontend/core/network/api_request_coordinator.dart';
import 'package:platform_core_frontend/core/refresh/app_data_refresh_bus.dart';
import 'package:platform_core_frontend/features/namaz_time/data/models/namaz_time_model.dart';
import 'package:platform_core_frontend/features/namaz_time/data/models/update_namaz_time_request.dart';
import 'package:platform_core_frontend/features/namaz_time/data/namaz_time_api.dart';

class NamazTimeRepository {
  NamazTimeRepository({NamazTimeApi? namazTimeApi})
      : _namazTimeApi = namazTimeApi ?? NamazTimeApi();

  final NamazTimeApi _namazTimeApi;

  Future<NamazTimeModel?> getNamazTime(String masjidId) {
    return ApiRequestCoordinator.instance.run<NamazTimeModel?>(
      key: 'GET:/namaz-times/$masjidId',
      request: () => _namazTimeApi.getNamazTime(masjidId),
    );
  }

  Future<NamazTimeModel> updateNamazTime({
    required String masjidId,
    required UpdateNamazTimeRequest request,
  }) async {
    final namazTime = await _namazTimeApi.updateNamazTime(
      masjidId: masjidId,
      request: request,
    );
    AppDataRefreshBus.instance.notifyMany(<AppDataScope>[
      AppDataScope.namazTime,
      AppDataScope.dashboard,
    ]);
    return namazTime;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/namaz_time_model.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/update_namaz_time_request.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/namaz_time_api.dart';

final namazTimeRepositoryProvider = Provider<NamazTimeRepository>(
  (ref) => NamazTimeRepository(NamazTimeApi(ref.watch(apiClientProvider))),
);

class NamazTimeRepository {
  NamazTimeRepository(this._api);

  final NamazTimeApi _api;

  /// Namaz times of the signed-in user's masjid.
  Future<NamazTimeModel> getMyNamazTime() => _api.getMyNamazTime();

  Future<NamazTimeModel> updateMyNamazTime(UpdateNamazTimeRequest request) =>
      _api.updateMyNamazTime(request);
}

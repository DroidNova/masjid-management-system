import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/masjid_request_api.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/models/create_masjid_request.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/models/track_masjid_application_result.dart';

final masjidRequestRepositoryProvider = Provider<MasjidRequestRepository>(
  (ref) =>
      MasjidRequestRepository(MasjidRequestApi(ref.watch(apiClientProvider))),
);

class MasjidRequestRepository {
  MasjidRequestRepository(this._api);

  final MasjidRequestApi _api;

  Future<void> submitMasjidRequest(CreateMasjidRequest request) =>
      _api.submitMasjidRequest(request);

  Future<List<TrackMasjidApplicationResult>> trackApplicationByPhone(
    String requesterPhone,
  ) => _api.trackApplicationByPhone(requesterPhone);
}

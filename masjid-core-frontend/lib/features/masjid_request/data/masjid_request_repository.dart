import 'package:platform_core_frontend/features/masjid_request/data/masjid_request_api.dart';
import 'package:platform_core_frontend/features/masjid_request/data/models/create_masjid_request.dart';
import 'package:platform_core_frontend/features/masjid_request/data/models/track_masjid_application_result.dart';

class MasjidRequestRepository {
  MasjidRequestRepository({MasjidRequestApi? masjidRequestApi})
      : _masjidRequestApi = masjidRequestApi ?? MasjidRequestApi();

  final MasjidRequestApi _masjidRequestApi;

  Future<void> submitMasjidRequest(CreateMasjidRequest request) {
    return _masjidRequestApi.submitMasjidRequest(request);
  }

  Future<List<TrackMasjidApplicationResult>> trackApplicationByPhone(
    String requesterPhone,
  ) {
    return _masjidRequestApi.trackApplicationByPhone(requesterPhone);
  }
}

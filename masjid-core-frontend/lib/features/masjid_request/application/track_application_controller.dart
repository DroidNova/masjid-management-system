import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/masjid_request_repository.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/models/track_masjid_application_result.dart';

final trackApplicationControllerProvider =
    NotifierProvider.autoDispose<
      TrackApplicationController,
      AsyncValue<List<TrackMasjidApplicationResult>>?
    >(TrackApplicationController.new);

/// Public application tracking by phone. State is null before the first
/// search, then loading / error / the applications found.
class TrackApplicationController
    extends
        AutoDisposeNotifier<AsyncValue<List<TrackMasjidApplicationResult>>?> {
  @override
  AsyncValue<List<TrackMasjidApplicationResult>>? build() => null;

  /// [phone] is normalized (`+919876543210`).
  Future<void> track(String phone) async {
    if (state?.isLoading ?? false) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(masjidRequestRepositoryProvider)
          .trackApplicationByPhone(phone),
    );
  }
}

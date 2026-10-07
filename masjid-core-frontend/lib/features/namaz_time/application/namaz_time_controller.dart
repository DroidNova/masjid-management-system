import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/namaz_time_model.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/update_namaz_time_request.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/namaz_time_repository.dart';

/// Scopes that change when a masjid's namaz times are saved.
const List<DataScope> namazTimeChanges = <DataScope>[
  DataScope.namazTimes,
  DataScope.dashboard,
];

/// Namaz times of one masjid, by masjid id.
final namazTimeControllerProvider = AsyncNotifierProvider.autoDispose
    .family<NamazTimeController, NamazTimeModel, String>(
      NamazTimeController.new,
    );

class NamazTimeController
    extends AutoDisposeFamilyAsyncNotifier<NamazTimeModel, String> {
  @override
  Future<NamazTimeModel> build(String masjidId) {
    ref.watch(dataVersionProvider(DataScope.namazTimes));
    return ref.watch(namazTimeRepositoryProvider).getNamazTime(masjidId);
  }
}

/// Saving namaz times. State: loading while saving, error of the last save.
final namazTimeSaveControllerProvider =
    AsyncNotifierProvider.autoDispose<NamazTimeSaveController, void>(
      NamazTimeSaveController.new,
    );

class NamazTimeSaveController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Returns true when saved; on failure the error is in [state].
  Future<bool> save({
    required String masjidId,
    required UpdateNamazTimeRequest request,
  }) async {
    if (state.isLoading) return false;
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard<void>(
      () => ref
          .read(namazTimeRepositoryProvider)
          .updateNamazTime(masjidId: masjidId, request: request),
    );
    if (state.hasError) return false;
    ref.markChanged(namazTimeChanges);
    return true;
  }
}

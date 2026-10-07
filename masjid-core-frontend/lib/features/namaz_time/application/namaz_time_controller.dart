import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/namaz_time_model.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/update_namaz_time_request.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/namaz_time_repository.dart';

/// Scopes that change when a masjid's namaz times are saved.
const List<DataScope> namazTimeChanges = <DataScope>[
  DataScope.namazTimes,
  DataScope.dashboard,
];

/// Namaz times of the signed-in user's masjid (`/namaz-times/my-masjid`).
final myNamazTimeProvider =
    AsyncNotifierProvider.autoDispose<MyNamazTimeController, NamazTimeModel>(
      MyNamazTimeController.new,
    );

class MyNamazTimeController extends AutoDisposeAsyncNotifier<NamazTimeModel> {
  @override
  Future<NamazTimeModel> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    ref.watch(dataVersionProvider(DataScope.namazTimes));
    return ref.watch(namazTimeRepositoryProvider).getMyNamazTime();
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
  Future<bool> save(UpdateNamazTimeRequest request) async {
    if (state.isLoading) return false;
    // Finish (and mark changes) even if the screen closes meanwhile.
    final keepAlive = ref.keepAlive();
    try {
      state = const AsyncLoading<void>();
      state = await AsyncValue.guard<void>(
        () => ref.read(namazTimeRepositoryProvider).updateMyNamazTime(request),
      );
      if (state.hasError) return false;
      ref.markChanged(namazTimeChanges);
      return true;
    } finally {
      keepAlive.close();
    }
  }
}

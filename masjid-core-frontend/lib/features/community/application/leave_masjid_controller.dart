import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/features/community/data/community_repository.dart';

final leaveMasjidControllerProvider =
    NotifierProvider.autoDispose<LeaveMasjidController, AsyncValue<void>>(
      LeaveMasjidController.new,
    );

/// Leaves the signed-in user's masjid. The caller signs out afterwards.
class LeaveMasjidController extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// True when the user left; on failure [state] holds the error.
  Future<bool> leave() async {
    if (state.isLoading) return false;
    // Finish even if the screen closes meanwhile.
    final keepAlive = ref.keepAlive();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(communityRepositoryProvider).leaveMyMasjid(),
    );
    keepAlive.close();
    // No markChanged: the caller signs out next, and every screen reloads
    // for the next user anyway.
    return !state.hasError;
  }
}

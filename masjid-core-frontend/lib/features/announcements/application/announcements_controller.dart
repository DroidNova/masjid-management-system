import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/announcements/data/announcements_repository.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/create_announcement_request.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/update_announcement_request.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';

/// Scopes that change when an announcement is created, edited or removed.
const List<DataScope> announcementChanges = <DataScope>[
  DataScope.announcements,
  DataScope.dashboard,
];

/// The current masjid's announcements, newest first (infinite scroll).
final announcementsControllerProvider =
    AsyncNotifierProvider.autoDispose<
      AnnouncementsController,
      PagedState<AnnouncementModel>
    >(AnnouncementsController.new);

class AnnouncementsController extends PagedController<AnnouncementModel> {
  @override
  Future<PagedState<AnnouncementModel>> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    ref.watch(dataVersionProvider(DataScope.announcements));
    return super.build();
  }

  @override
  Future<PageResult<AnnouncementModel>> fetchPage(int page) =>
      ref.read(announcementsRepositoryProvider).getAnnouncements(page: page);

  /// "Delete": the server marks the announcement inactive. Throws on error.
  Future<void> deactivate(String id) async {
    await ref.read(announcementsRepositoryProvider).deactivateAnnouncement(id);
    // This controller watches DataScope.announcements: bumping it makes `ref`
    // outdated, so it must be the last scope markChanged touches.
    ref.markChanged(<DataScope>[DataScope.dashboard, DataScope.announcements]);
  }
}

/// One announcement by id (edit screen opened from a fresh URL).
final announcementByIdProvider = FutureProvider.autoDispose
    .family<AnnouncementModel, String>((ref, id) {
      ref.watch(dataVersionProvider(DataScope.announcements));
      return ref.watch(announcementsRepositoryProvider).getAnnouncement(id);
    });

/// Create / update from the add and edit screens. State: loading while
/// saving, error of the last save (use `fieldError` for form fields).
final announcementFormControllerProvider =
    AsyncNotifierProvider.autoDispose<AnnouncementFormController, void>(
      AnnouncementFormController.new,
    );

class AnnouncementFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Returns true when saved; on failure the error is in [state].
  Future<bool> create(CreateAnnouncementRequest request) => _save(
    () => ref.read(announcementsRepositoryProvider).createAnnouncement(request),
  );

  Future<bool> updateAnnouncement(
    String id,
    UpdateAnnouncementRequest request,
  ) => _save(
    () => ref
        .read(announcementsRepositoryProvider)
        .updateAnnouncement(id, request),
  );

  Future<bool> _save(Future<Object?> Function() action) async {
    if (state.isLoading) return false;
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard<void>(action);
    if (state.hasError) return false;
    ref.markChanged(announcementChanges);
    return true;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/notifications/data/notifications_api.dart';

/// How many notices are unread: the number on the bell. Reloads for a new
/// user; [refreshCount] keeps the old number on a network error.
final unreadNotificationsProvider =
    AsyncNotifierProvider<UnreadNotificationsController, int>(
      UnreadNotificationsController.new,
    );

class UnreadNotificationsController extends AsyncNotifier<int> {
  @override
  Future<int> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    final allowed = PermissionHelper.canViewNotifications(
      ref.watch(currentPermissionsProvider),
    );
    if (!allowed) return Future<int>.value(0);
    return ref.read(notificationsApiProvider).unreadCount();
  }

  /// Quietly reloads the number (app back in front, timer).
  Future<void> refreshCount() async {
    if (!PermissionHelper.canViewNotifications(
      ref.read(currentPermissionsProvider),
    )) {
      return;
    }
    try {
      state = AsyncData(await ref.read(notificationsApiProvider).unreadCount());
    } catch (_) {
      // Keep showing the last number; the next refresh tries again.
    }
  }

  /// Everything was just marked read.
  void clear() => state = const AsyncData(0);
}

final notificationsProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationsController,
      PagedState<AppNotification>
    >(NotificationsController.new);

class NotificationsController extends PagedController<AppNotification> {
  @override
  Future<PagedState<AppNotification>> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    return super.build();
  }

  @override
  Future<PageResult<AppNotification>> fetchPage(int page) =>
      ref.read(notificationsApiProvider).list(page: page);
}

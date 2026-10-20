import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/notifications/application/notifications_controllers.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// The bell in the top bar, with the number of unread notices. The number
/// reloads when the app comes back to the front and every two minutes
/// while it is open (one small request).
class NotificationBell extends ConsumerStatefulWidget {
  const NotificationBell({super.key});

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell> {
  Timer? _timer;
  AppLifecycleListener? _lifecycle;

  void _refresh() =>
      ref.read(unreadNotificationsProvider.notifier).refreshCount();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 2), (_) => _refresh());
    _lifecycle = AppLifecycleListener(onResume: _refresh);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!PermissionHelper.canViewNotifications(
      ref.watch(currentPermissionsProvider),
    )) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final unread = ref.watch(unreadNotificationsProvider).valueOrNull ?? 0;
    return IconButton(
      tooltip: l10n.notificationsTitle,
      onPressed: () => context.push('/notifications'),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 9 ? '9+' : '$unread'),
        child: Icon(
          unread > 0 ? AppIcons.notificationsNew : AppIcons.notifications,
        ),
      ),
    );
  }
}

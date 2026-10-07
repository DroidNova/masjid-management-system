import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/announcements/application/announcements_controller.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/widgets/announcement_card.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/widgets/announcement_empty_view.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/shared/widgets/app_button.dart';
import 'package:masjid_core_frontend/shared/widgets/loading_view.dart';

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsState = ref.watch(announcementsControllerProvider);

    return announcementsState.when(
      // Keep showing the list while it reloads after a change.
      skipLoadingOnReload: true,
      loading: () => const LoadingView(),
      error: (error, _) {
        if (error is ApiException && error.isUnauthorized) {
          return _AnnouncementErrorView(
            message: 'Session expired. Please login again.',
            buttonLabel: 'Back to Login',
            // The router sends the user to the login page.
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          );
        }
        final noMasjid =
            error is ApiException &&
            error.code == ApiErrorCodes.userMasjidNotAssigned;
        return _AnnouncementErrorView(
          message: noMasjid
              ? 'You are not assigned to any masjid yet.'
              : 'Unable to load announcements.',
          detail: noMasjid ? null : userMessage(error),
          onPressed: () => ref.invalidate(announcementsControllerProvider),
        );
      },
      data: (state) => _AnnouncementsList(state: state),
    );
  }
}

class _AnnouncementsList extends ConsumerWidget {
  const _AnnouncementsList({required this.state});

  final PagedState<AnnouncementModel> state;

  Future<void> _deleteAnnouncement(
    BuildContext context,
    WidgetRef ref,
    AnnouncementModel announcement,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: const Text(
          'Are you sure you want to delete this announcement?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(announcementsControllerProvider.notifier)
          .deactivate(announcement.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Announcement deleted successfully.')),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(userMessage(error))));
    }
  }

  /// Infinite scroll: fetch the next page near the end of the list.
  bool _onScroll(ScrollNotification notification, WidgetRef ref) {
    if (notification.metrics.extentAfter < 300) {
      ref.read(announcementsControllerProvider.notifier).loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManageAnnouncements = PermissionHelper.canManageAnnouncements(
      ref.watch(currentPermissionsProvider),
    );
    final announcements = state.items;
    final controller = ref.read(announcementsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) => _onScroll(notification, ref),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Announcements',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Important updates for your masjid community',
                        ),
                        const SizedBox(height: 16),
                        if (canManageAnnouncements) ...<Widget>[
                          AppButton(
                            label: 'Add Announcement',
                            onPressed: () => context.push('/announcements/add'),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (announcements.isEmpty)
                          const AnnouncementEmptyView()
                        else
                          ...announcements.map(
                            (announcement) => AnnouncementCard(
                              announcement: announcement,
                              onEdit: canManageAnnouncements
                                  ? () => context.push(
                                      '/announcements/${announcement.id}/edit',
                                      extra: announcement,
                                    )
                                  : null,
                              onDelete: canManageAnnouncements
                                  ? () => _deleteAnnouncement(
                                      context,
                                      ref,
                                      announcement,
                                    )
                                  : null,
                            ),
                          ),
                        if (state.loadingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        if (state.loadMoreError != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  userMessage(state.loadMoreError!),
                                  textAlign: TextAlign.center,
                                ),
                                TextButton(
                                  onPressed: controller.loadMore,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnnouncementErrorView extends StatelessWidget {
  const _AnnouncementErrorView({
    required this.message,
    required this.onPressed,
    this.detail,
    this.buttonLabel = 'Retry',
  });

  final String message;
  final String? detail;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.campaign_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (detail != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(detail!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 20),
                AppButton(label: buttonLabel, onPressed: onPressed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

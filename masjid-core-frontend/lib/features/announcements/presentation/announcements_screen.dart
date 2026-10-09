import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/announcements/application/announcements_controller.dart';
import 'package:masjid_core_frontend/features/announcements/application/news_seen.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/widgets/announcement_card.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// News (announcements), newest first: amber cards with a speaker button
/// and a "New" mark for what this person has not seen yet. People who may
/// manage news get an Add button and edit / delete on each card.
///
/// The News tab shows it inside the app frame; [showAppBar] is for the
/// stand-alone page (`/announcements`).
class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key, this.showAppBar = false});

  final bool showAppBar;

  @override
  ConsumerState<AnnouncementsScreen> createState() =>
      _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  /// What was "seen" when the screen opened: the marks stay for this visit
  /// even though opening the list counts as seeing it.
  late final DateTime? _seenBefore;

  @override
  void initState() {
    super.initState();
    // Read before this visit is recorded below.
    _seenBefore = ref.read(newsLastSeenProvider);
    // Opening the list (and every reload while open) counts as seeing it,
    // including a list that was already loaded before.
    ref.listenManual(announcementsControllerProvider, (_, next) {
      final items = next.valueOrNull?.items;
      if (items != null) _markSeen(items);
    }, fireImmediately: true);
  }

  void _markSeen(List<AnnouncementModel> items) {
    final newest = items
        .map((item) => item.createdAt)
        .whereType<DateTime>()
        .fold<DateTime?>(
          null,
          (latest, date) =>
              latest == null || date.isAfter(latest) ? date : latest,
        );
    if (newest != null) {
      ref.read(newsLastSeenProvider.notifier).markSeen(newest);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canManage = PermissionHelper.canManageAnnouncements(
      ref.watch(currentPermissionsProvider),
    );
    final news = ref.watch(announcementsControllerProvider);

    final body = news.when(
      // Keep showing the list while it reloads after a change.
      skipLoadingOnReload: true,
      loading: () => const SingleChildScrollView(
        child: PageBody.form(child: SkeletonList()),
      ),
      error: (error, _) {
        final noMasjid =
            error is ApiException &&
            error.code == ApiErrorCodes.userMasjidNotAssigned;
        return EmptyState(
          icon: noMasjid ? AppIcons.mosque : AppIcons.problem,
          tone: noMasjid ? AppTones.neutral : AppTones.problem,
          title: noMasjid ? l10n.noMasjidAssigned : l10n.newsLoadFailed,
          actionLabel: noMasjid ? null : l10n.tryAgain,
          onAction: () => ref.invalidate(announcementsControllerProvider),
        );
      },
      data: (state) => _NewsList(
        state: state,
        canManage: canManage,
        seenBefore: _seenBefore,
      ),
    );

    return Scaffold(
      appBar: widget.showAppBar ? AppBar(title: Text(l10n.tabNews)) : null,
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              backgroundColor: AppTones.news.color,
              foregroundColor: Colors.white,
              onPressed: () => context.push('/announcements/add'),
              icon: const Icon(AppIcons.add),
              label: Text(l10n.addNews),
            )
          : null,
      body: body,
    );
  }
}

class _NewsList extends ConsumerWidget {
  const _NewsList({
    required this.state,
    required this.canManage,
    required this.seenBefore,
  });

  final PagedState<AnnouncementModel> state;
  final bool canManage;
  final DateTime? seenBefore;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AnnouncementModel item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final deleted = await showDangerDialog(
      context,
      title: l10n.deleteNewsQuestion,
      subject: item.title,
      confirmLabel: l10n.delete,
      confirmIcon: AppIcons.delete,
      points: <DangerPoint>[
        DangerPoint(icon: AppIcons.people, text: l10n.deleteNewsPoint),
      ],
      onConfirm: () => ref
          .read(announcementsControllerProvider.notifier)
          .deactivate(item.id),
    );
    if (deleted && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.newsDeleted)));
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
    final l10n = AppLocalizations.of(context);
    final items = state.items;
    final controller = ref.read(announcementsControllerProvider.notifier);

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: EmptyState(
                icon: AppIcons.announcements,
                tone: AppTones.news,
                title: l10n.noNewsYet,
                actionLabel: canManage ? l10n.addFirstNews : null,
                actionIcon: AppIcons.add,
                onAction: () => context.push('/announcements/add'),
              ),
            ),
          ),
        ),
      );
    }

    final loadMoreError = state.loadMoreError;
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _onScroll(notification, ref),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          // Room for the Add button at the bottom.
          padding: EdgeInsets.only(bottom: canManage ? 96 : AppSpace.xl),
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == items.length) {
              if (state.loadingMore) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpace.l),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (loadMoreError != null) {
                return PageBody.form(
                  child: MessageBanner(
                    text: errorText(l10n, loadMoreError),
                    action: TextButton(
                      onPressed: controller.loadMore,
                      child: Text(l10n.tryAgain),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }
            final item = items[index];
            return PageBody.form(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.l,
                AppSpace.s,
                AppSpace.l,
                AppSpace.s,
              ),
              child: AnnouncementCard(
                announcement: item,
                isNew: isNewNews(item.createdAt, seenBefore),
                onEdit: canManage
                    ? () => context.push(
                        '/announcements/${item.id}/edit',
                        extra: item,
                      )
                    : null,
                onDelete: canManage ? () => _delete(context, ref, item) : null,
              ),
            );
          },
        ),
      ),
    );
  }
}

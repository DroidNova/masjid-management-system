import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/finance/presentation/money_categories.dart';
import 'package:masjid_core_frontend/features/notifications/application/notifications_controllers.dart';
import 'package:masjid_core_frontend/features/notifications/data/notifications_api.dart';
import 'package:masjid_core_frontend/features/record_history/presentation/record_history_button.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// My notices, newest first: money recorded, changed or cancelled in my
/// name and by whom. Opening the page marks them read; the ones that were
/// new keep a "New" badge until the page is left. Tapping one shows the
/// record's history.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _markRead();
  }

  Future<void> _markRead() async {
    final unread = ref.read(unreadNotificationsProvider.notifier);
    try {
      await ref.read(notificationsApiProvider).markAllRead();
      unread.clear();
    } catch (_) {
      // Stays unread; the next visit tries again.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(notificationsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: PagedListView<AppNotification>(
        value: ref.watch(notificationsProvider),
        dayOf: (notice) => notice.createdAt,
        onRefresh: controller.refresh,
        onLoadMore: controller.loadMore,
        onRetry: () => ref.invalidate(notificationsProvider),
        empty: EmptyState(
          icon: AppIcons.notifications,
          tone: AppTones.people,
          title: l10n.notificationsEmpty,
          message: l10n.notificationsEmptyHint,
        ),
        itemBuilder: (context, notice) => NoticeTile(notice: notice),
      ),
    );
  }
}

/// One notice: what happened in one sentence, the new amount after an
/// edit, and when.
class NoticeTile extends StatelessWidget {
  const NoticeTile({super.key, required this.notice});

  final AppNotification notice;

  /// What the money was for, in the reader's language.
  String _what(AppLocalizations l10n) => switch (notice.purpose) {
    'SALARY' when notice.month != null && notice.year != null =>
      '${l10n.catImamSalary} (${AppFormat.monthYear(notice.month!, notice.year!)})',
    'SALARY' => l10n.catImamSalary,
    'PROJECT' => notice.projectTitle ?? l10n.tabProjects,
    'DONATION' => moneyCategoryLabel(l10n, notice.collectionType ?? 'OTHER'),
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final name = notice.actorName;
    final amount = AppFormat.rupees(notice.amount);
    final what = _what(l10n);
    final (icon, tone, text) = switch (notice.kind) {
      'PAYMENT_CANCELLED' => (
        Icons.block_rounded,
        AppTones.danger,
        l10n.noticeCancelled(name, amount, what),
      ),
      'PAYMENT_CHANGED' => (
        AppIcons.edit,
        AppTones.namaz,
        l10n.noticeChanged(name, amount, what),
      ),
      _ => (
        AppIcons.moneyIn,
        AppTones.moneyIn,
        l10n.noticeRecorded(name, amount, what),
      ),
    };
    final newAmount = notice.newAmount;
    final history = notice.history;

    return Card(
      child: InkWell(
        onTap: history == null
            ? null
            : () => showRecordHistory(context, history),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.m),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ToneIcon(icon: icon, tone: tone),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(text, style: textTheme.titleMedium),
                    if (newAmount != null)
                      Text(
                        l10n.noticeChangedNow(AppFormat.rupees(newAmount)),
                        style: textTheme.titleMedium?.copyWith(
                          color: tone.color,
                        ),
                      ),
                    Text(
                      AppFormat.dateTime(notice.createdAt),
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (notice.isUnread) ...<Widget>[
                      const SizedBox(height: AppSpace.xs),
                      StatusBadge(
                        kind: StatusKind.waiting,
                        label: l10n.noticeNew,
                      ),
                    ],
                  ],
                ),
              ),
              if (history != null)
                const Padding(
                  padding: EdgeInsetsDirectional.only(start: AppSpace.s),
                  child: Icon(AppIcons.history, color: AppColors.textSecondary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

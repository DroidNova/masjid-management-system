import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/app_icons.dart';
import 'package:masjid_core_frontend/shared/ui/day_label.dart';
import 'package:masjid_core_frontend/shared/ui/empty_state.dart';
import 'package:masjid_core_frontend/shared/ui/message_banner.dart';
import 'package:masjid_core_frontend/shared/ui/motion.dart';
import 'package:masjid_core_frontend/shared/ui/skeleton.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// A scrolling page with [header] widgets on top and a paged list below:
/// loading placeholders, a friendly empty page, an error with Try again,
/// pull-to-refresh, and the next page loaded near the end. With [dayOf],
/// rows are grouped under "Today" / "Yesterday" / date headings.
///
/// Content stays at [maxWidth] in the middle of wide screens.
class PagedListView<T> extends StatelessWidget {
  const PagedListView({
    super.key,
    required this.value,
    required this.itemBuilder,
    required this.empty,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onRetry,
    this.header = const <Widget>[],
    this.dayOf,
    this.maxWidth = AppSizes.maxFormWidth,
    this.bottomPadding = AppSpace.xl,
  });

  final AsyncValue<PagedState<T>> value;
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Shown instead of rows when the list has none.
  final Widget empty;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;
  final List<Widget> header;
  final DateTime? Function(T item)? dayOf;
  final double maxWidth;

  /// Room at the end, for example above a floating button.
  final double bottomPadding;

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.extentAfter < 300) onLoadMore();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget centered(Widget child) => Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.l),
          child: child,
        ),
      ),
    );

    final rows = <Widget>[];
    value.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      loading: () => rows.add(centered(const SkeletonList())),
      error: (error, _) => rows.add(
        centered(
          MessageBanner(
            text: errorText(l10n, error),
            action: TextButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
          ),
        ),
      ),
      data: (state) {
        if (state.items.isEmpty) {
          rows.add(
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.xl),
              child: empty,
            ),
          );
          return;
        }
        DateTime? lastDay;
        var index = 0;
        for (final item in state.items) {
          final day = dayOf?.call(item);
          if (day != null) {
            final date = DateUtils.dateOnly(day.toLocal());
            if (lastDay == null || !DateUtils.isSameDay(lastDay, date)) {
              lastDay = date;
              rows.add(
                centered(
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpace.l,
                      bottom: AppSpace.xs,
                    ),
                    child: Semantics(
                      header: true,
                      child: Text(
                        dayLabel(l10n, date),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }
          rows.add(
            centered(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
                child: _Entrance(
                  index: index++,
                  child: itemBuilder(context, item),
                ),
              ),
            ),
          );
        }
        final moreError = state.loadMoreError;
        if (state.loadingMore) {
          rows.add(
            const Padding(
              padding: EdgeInsets.all(AppSpace.l),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (moreError != null) {
          rows.add(
            centered(
              MessageBanner(
                text: errorText(l10n, moreError),
                action: TextButton(
                  onPressed: onLoadMore,
                  child: Text(l10n.tryAgain),
                ),
              ),
            ),
          );
        }
      },
    );

    return _EntranceWindow(
      hasRows: value.valueOrNull?.items.isNotEmpty ?? false,
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: AppSpace.l, bottom: bottomPadding),
            children: <Widget>[
              for (final widget in header) centered(widget),
              ...rows,
            ],
          ),
        ),
      ),
    );
  }
}

/// The usual empty page for a list that can be filtered: a different line
/// when a filter hides everything.
EmptyState listEmptyState({
  required IconData icon,
  required AppTone tone,
  required String title,
  required bool filtered,
  required AppLocalizations l10n,
  String? actionLabel,
  VoidCallback? onAction,
}) => EmptyState(
  icon: filtered ? AppIcons.search : icon,
  tone: tone,
  title: filtered ? l10n.nothingMatches : title,
  actionLabel: filtered ? null : actionLabel,
  actionIcon: AppIcons.add,
  onAction: onAction,
);

/// Remembers when the list first showed rows. Only rows built in the first
/// moments after that ease in; rows that appear later because of scrolling
/// show at once, so a fast scroll never shows empty space.
class _EntranceWindow extends StatefulWidget {
  const _EntranceWindow({required this.hasRows, required this.child});

  final bool hasRows;
  final Widget child;

  @override
  State<_EntranceWindow> createState() => _EntranceWindowState();
}

class _EntranceWindowState extends State<_EntranceWindow> {
  DateTime? _firstRows;

  @override
  Widget build(BuildContext context) {
    if (widget.hasRows) _firstRows ??= DateTime.now();
    return _EntranceScope(firstRows: _firstRows, child: widget.child);
  }
}

class _EntranceScope extends InheritedWidget {
  const _EntranceScope({required this.firstRows, required super.child});

  final DateTime? firstRows;

  static const Duration window = Duration(milliseconds: 600);

  /// True while the first rows are being shown.
  bool get opening {
    final first = firstRows;
    return first != null && DateTime.now().difference(first) < window;
  }

  @override
  bool updateShouldNotify(_EntranceScope oldWidget) =>
      firstRows != oldWidget.firstRows;
}

/// One row: eases in only as part of the first screenful.
class _Entrance extends StatelessWidget {
  const _Entrance({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_EntranceScope>();
    if (index >= 8 || scope == null || !scope.opening) return child;
    return FadeSlideIn.stagger(index: index, child: child);
  }
}

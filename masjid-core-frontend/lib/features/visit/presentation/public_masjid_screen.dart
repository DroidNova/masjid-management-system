import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/widgets/announcement_card.dart';
import 'package:masjid_core_frontend/features/dashboard/presentation/widgets/next_namaz_card.dart';
import 'package:masjid_core_frontend/features/namaz_time/application/prayer_schedule.dart';
import 'package:masjid_core_frontend/features/namaz_time/presentation/namaz_times_screen.dart';
import 'package:masjid_core_frontend/features/visit/application/followed_masjids.dart';
import 'package:masjid_core_frontend/features/visit/data/public_masjid_api.dart';
import 'package:masjid_core_frontend/features/visit/presentation/find_masjid_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// A masjid's public page, for anyone with its code (no login): where it
/// is, the next namaz, all namaz times, and the news its imam or committee
/// posted for Everyone. Follow keeps it on this phone's Home.
class PublicMasjidScreen extends ConsumerWidget {
  const PublicMasjidScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref
        .watch(publicMasjidPageProvider(code))
        .valueOrNull
        ?.masjid
        .name;
    return Scaffold(
      appBar: AppBar(title: Text(name ?? l10n.findMasjid)),
      body: SafeArea(top: false, child: PublicMasjidView(code: code)),
    );
  }
}

/// The public page's content (loading, not found, or the masjid), without
/// a frame: [PublicMasjidScreen] and the Masjid times screen show it.
class PublicMasjidView extends ConsumerWidget {
  const PublicMasjidView({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final page = ref.watch(publicMasjidPageProvider(code));
    final data = page.valueOrNull;

    if (data != null) {
      return _PageContent(
        page: data,
        onRefresh: () => ref.refresh(publicMasjidPageProvider(code).future),
      );
    }
    if (page.hasError) {
      final error = page.error;
      return error is ApiException && error.code == ApiErrorCodes.masjidNotFound
          ? EmptyState(
              icon: AppIcons.mosque,
              title: l10n.masjidCodeNotFound,
              actionLabel: l10n.findMasjid,
              actionIcon: AppIcons.search,
              onAction: () => context.pushReplacement(findMasjidLocation),
            )
          : ErrorState(
              error: error!,
              onRetry: () => ref.invalidate(publicMasjidPageProvider(code)),
            );
    }
    return const SingleChildScrollView(
      child: PageBody.form(child: SkeletonList(itemCount: 4)),
    );
  }
}

class _PageContent extends ConsumerWidget {
  const _PageContent({required this.page, required this.onRefresh});

  final PublicMasjidPage page;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final masjid = page.masjid;
    final times = page.times;
    final following = ref
        .watch(followedMasjidsProvider)
        .any((followed) => followed.code == masjid.code);
    final followed = ref.read(followedMasjidsProvider.notifier);
    final now = DateTime.now();
    final next = nextPrayer(times, now);
    final nextToday = next != null && DateUtils.isSameDay(next.at, now)
        ? next.prayer.prayer
        : null;
    final rows = <(Prayer, String?)>[
      (Prayer.fajr, times?.fajr),
      (Prayer.zuhr, times?.zuhr),
      (Prayer.asr, times?.asr),
      (Prayer.maghrib, times?.maghrib),
      (Prayer.isha, times?.isha),
      (Prayer.jumma, times?.jumma),
    ];
    final address = masjid.address?.trim() ?? '';
    final hasTimes = rows.any((row) => parseNamazTime(row.$2) != null);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          PageBody.form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                HeroCard(
                  tone: AppTones.namaz,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(AppIcons.mosque, size: 40),
                          const SizedBox(width: AppSpace.m),
                          Expanded(
                            child: Text(
                              masjid.name,
                              style: textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (masjid.place.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppSpace.s),
                        Text(
                          masjid.place,
                          style: textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                      if (address.isNotEmpty)
                        Text(
                          address,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      const SizedBox(height: AppSpace.s),
                      Text(
                        l10n.masjidCodeIs(displayMasjidCode(masjid.code)),
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.m),
                if (following)
                  OutlinedButton.icon(
                    onPressed: () => followed.unfollow(masjid.code),
                    icon: const Icon(AppIcons.done),
                    label: Text(l10n.followingMasjid),
                  )
                else
                  FilledButton.icon(
                    onPressed: () => followed.follow(masjid),
                    icon: const Icon(AppIcons.add),
                    label: Text(l10n.followMasjid),
                  ),
                if (following)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpace.xs),
                    child: Text(
                      l10n.followingMasjidHint,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpace.l),
                NextNamazCard(times: times, onOpen: () {}),
                if (hasTimes) ...<Widget>[
                  SectionHeader(title: l10n.tabTimes, icon: AppIcons.time),
                  for (final (prayer, text) in rows)
                    PrayerTimeRow(
                      prayer: prayer,
                      time: parseNamazTime(text),
                      isNext: prayer == nextToday,
                    ),
                ],
                SectionHeader(
                  title: l10n.tabNews,
                  icon: AppIcons.announcements,
                  actionLabel:
                      page.latestNews.length >= PublicMasjidPage.latestCount
                      ? l10n.seeAll
                      : null,
                  onAction: () => context.push('/visit/${masjid.code}/news'),
                ),
                if (page.latestNews.isEmpty)
                  MessageBanner(
                    kind: StatusKind.neutral,
                    text: l10n.noPublicNews,
                  )
                else
                  for (final AnnouncementModel item in page.latestNews)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.m),
                      child: AnnouncementCard(
                        announcement: item,
                        showAudience: false,
                      ),
                    ),
                const SizedBox(height: AppSpace.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// All public news of one masjid, newest first.
class PublicNewsScreen extends ConsumerWidget {
  const PublicNewsScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = publicNewsProvider(code);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabNews)),
      body: PagedListView<AnnouncementModel>(
        value: ref.watch(provider),
        onRefresh: () => ref.read(provider.notifier).refresh(),
        onLoadMore: ref.read(provider.notifier).loadMore,
        onRetry: () => ref.invalidate(provider),
        empty: EmptyState(
          icon: AppIcons.announcements,
          tone: AppTones.news,
          title: l10n.noPublicNews,
        ),
        itemBuilder: (context, item) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.m),
          child: AnnouncementCard(announcement: item, showAudience: false),
        ),
      ),
    );
  }
}

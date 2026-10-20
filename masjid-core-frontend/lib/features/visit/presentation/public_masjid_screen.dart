import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/contact/contact_launcher.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/widgets/announcement_card.dart';
import 'package:masjid_core_frontend/features/dashboard/presentation/widgets/next_namaz_card.dart';
import 'package:masjid_core_frontend/features/namaz_time/application/prayer_schedule.dart';
import 'package:masjid_core_frontend/features/namaz_time/presentation/widgets/prayer_labels.dart';
import 'package:masjid_core_frontend/features/visit/application/followed_masjids.dart';
import 'package:masjid_core_frontend/features/visit/data/public_masjid_api.dart';
import 'package:masjid_core_frontend/features/visit/presentation/find_masjid_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// A masjid's public page, for anyone with its code (no login): where it
/// is, the next namaz with the day's times, Jumma, and the news posted for
/// Everyone. Following it returns the code to the screen that opened this
/// one (the finder, then Masjid times), so the person lands on it there.
class PublicMasjidScreen extends ConsumerWidget {
  const PublicMasjidScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final masjid = ref
        .watch(publicMasjidPageProvider(code))
        .valueOrNull
        ?.masjid;
    return Scaffold(
      appBar: AppBar(
        title: Text(masjid?.name ?? l10n.masjidTimesTitle),
        actions: <Widget>[if (masjid != null) MasjidMenuButton(masjid: masjid)],
      ),
      body: SafeArea(
        top: false,
        child: PublicMasjidView(
          code: code,
          onFollowed: () {
            if (context.canPop()) context.pop(code);
          },
        ),
      ),
    );
  }
}

/// The page's content (loading, not found, or the masjid) without a frame;
/// [PublicMasjidScreen] and Masjid times show it. [onFollowed] runs after
/// the Follow button was used.
class PublicMasjidView extends ConsumerWidget {
  const PublicMasjidView({super.key, required this.code, this.onFollowed});

  final String code;
  final VoidCallback? onFollowed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final page = ref.watch(publicMasjidPageProvider(code));
    final data = page.valueOrNull;

    if (data != null) {
      return _PageContent(
        page: data,
        onRefresh: () => ref.refresh(publicMasjidPageProvider(code).future),
        onFollowed: onFollowed,
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
  const _PageContent({
    required this.page,
    required this.onRefresh,
    this.onFollowed,
  });

  final PublicMasjidPage page;
  final Future<void> Function() onRefresh;
  final VoidCallback? onFollowed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final masjid = page.masjid;
    final following = ref
        .watch(followedMasjidsProvider)
        .any((followed) => followed.code == masjid.code);
    final jumma = parseNamazTime(page.times?.jumma);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          PageBody.form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _Header(masjid: masjid),
                if (!following) ...<Widget>[
                  const SizedBox(height: AppSpace.l),
                  FilledButton.icon(
                    onPressed: () async {
                      await ref
                          .read(followedMasjidsProvider.notifier)
                          .follow(masjid);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.followingMasjidDone(masjid.name)),
                        ),
                      );
                      onFollowed?.call();
                    },
                    icon: const Icon(AppIcons.add),
                    label: Text(l10n.followMasjid),
                  ),
                ],
                const SizedBox(height: AppSpace.l),
                NextNamazCard(times: page.times, onOpen: () {}),
                if (jumma != null) ...<Widget>[
                  const SizedBox(height: AppSpace.m),
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(
                        Prayer.jumma.icon,
                        color: AppTones.namaz.color,
                      ),
                      title: Text(Prayer.jumma.label(l10n)),
                      trailing: Text(
                        prayerTimeText(context, jumma),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
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

/// Name, place, address and code: plain text on the page, no card.
class _Header extends StatelessWidget {
  const _Header({required this.masjid});

  final PublicMasjid masjid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final address = masjid.address?.trim() ?? '';
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const ToneIcon(
            icon: AppIcons.mosque,
            tone: AppTones.namaz,
            size: 56,
            circle: true,
          ),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(masjid.name, style: textTheme.titleLarge),
                if (masjid.place.isNotEmpty)
                  Text(
                    masjid.place,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: AppSpace.xs),
                if (address.isNotEmpty)
                  _MetaLine(icon: AppIcons.place, text: address),
                _MetaLine(
                  icon: Icons.tag_rounded,
                  text: l10n.masjidCodeIs(displayMasjidCode(masjid.code)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpace.xs),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}

enum _MasjidAction { share, stopFollowing }

/// The ⋮ menu for one masjid: share its code, and stop following it
/// (asked first, so a slip of the finger never drops it).
class MasjidMenuButton extends ConsumerWidget {
  const MasjidMenuButton({super.key, required this.masjid});

  final PublicMasjid masjid;

  Future<void> _stopFollowing(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      icon: AppIcons.mosque,
      title: l10n.stopFollowingQuestion(masjid.name),
      message: l10n.stopFollowingMessage,
      confirmLabel: l10n.stopFollowing,
      tone: AppTones.danger,
    );
    if (!confirmed) return;
    await ref.read(followedMasjidsProvider.notifier).unfollow(masjid.code);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final following = ref
        .watch(followedMasjidsProvider)
        .any((followed) => followed.code == masjid.code);
    return PopupMenuButton<_MasjidAction>(
      tooltip: MaterialLocalizations.of(context).showMenuTooltip,
      onSelected: (action) => switch (action) {
        _MasjidAction.share => ContactLauncher.share(
          l10n.masjidCodeShareText(masjid.name, displayMasjidCode(masjid.code)),
        ),
        _MasjidAction.stopFollowing => _stopFollowing(context, ref),
      },
      itemBuilder: (context) => <PopupMenuEntry<_MasjidAction>>[
        PopupMenuItem<_MasjidAction>(
          value: _MasjidAction.share,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(AppIcons.send),
            title: Text(l10n.share),
          ),
        ),
        if (following)
          PopupMenuItem<_MasjidAction>(
            value: _MasjidAction.stopFollowing,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.remove_circle_outline_rounded),
              title: Text(l10n.stopFollowing),
            ),
          ),
      ],
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

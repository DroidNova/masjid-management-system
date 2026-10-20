import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/contact/contact_launcher.dart';
import 'package:masjid_core_frontend/features/namaz_time/application/prayer_schedule.dart';
import 'package:masjid_core_frontend/features/namaz_time/presentation/widgets/prayer_labels.dart';
import 'package:masjid_core_frontend/features/visit/application/followed_masjids.dart';
import 'package:masjid_core_frontend/features/visit/data/public_masjid_api.dart';
import 'package:masjid_core_frontend/features/visit/presentation/find_masjid_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Home's "Other masjids": the masjids followed on this phone with their
/// next namaz, and a way to find another one.
class FollowedMasjidsSection extends ConsumerWidget {
  const FollowedMasjidsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final followed = ref.watch(followedMasjidsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionHeader(
          title: l10n.otherMasjids,
          icon: AppIcons.mosque,
          actionLabel: followed.isEmpty ? null : l10n.findMasjid,
          onAction: () => context.push(findMasjidLocation),
        ),
        if (followed.isEmpty)
          OutlinedButton.icon(
            onPressed: () => context.push(findMasjidLocation),
            icon: const Icon(AppIcons.search),
            label: Text(l10n.findMasjidHint),
          )
        else
          for (final masjid in followed)
            MasjidLinkTile(
              masjid: masjid,
              onTap: () => context.push('/visit/${masjid.code}'),
              trailing: _NextNamaz(code: masjid.code),
            ),
      ],
    );
  }
}

/// "Asr 4:30 PM" for a followed masjid; nothing while loading or offline.
class _NextNamaz extends ConsumerWidget {
  const _NextNamaz({required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final times = ref.watch(publicMasjidPageProvider(code)).valueOrNull?.times;
    final next = nextPrayer(times, DateTime.now());
    if (next == null) return const Icon(Icons.chevron_right_rounded);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          next.prayer.prayer.label(l10n),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          prayerTimeText(context, next.prayer.time),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppTones.namaz.color),
        ),
      ],
    );
  }
}

/// The masjid's own code, for members to share: anyone with it sees the
/// namaz times and the news posted for Everyone, nothing else.
class MasjidCodeCard extends StatelessWidget {
  const MasjidCodeCard({
    super.key,
    required this.code,
    required this.masjidName,
  });

  final String code;
  final String masjidName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final shown = displayMasjidCode(code);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const ToneIcon(icon: AppIcons.everyone, tone: AppTones.namaz),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(l10n.masjidCodeLabel, style: textTheme.titleMedium),
                      Text(
                        shown,
                        textDirection: TextDirection.ltr,
                        style: textTheme.headlineSmall?.copyWith(
                          letterSpacing: 4,
                          color: AppTones.namaz.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.s),
            Text(
              l10n.masjidCodeShareHelp,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpace.m),
            Wrap(
              spacing: AppSpace.s,
              runSpacing: AppSpace.s,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () => ContactLauncher.share(
                    l10n.masjidCodeShareText(masjidName, shown),
                  ),
                  icon: const Icon(AppIcons.send),
                  label: Text(l10n.share),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(l10n.codeCopied)));
                    }
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(l10n.copy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

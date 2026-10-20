import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/features/visit/application/followed_masjids.dart';
import 'package:masjid_core_frontend/features/visit/presentation/find_masjid_screen.dart';
import 'package:masjid_core_frontend/features/visit/presentation/public_masjid_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// "Masjid times" (`/visit`). With followed masjids it opens straight on
/// their times and news: chips on top switch between several, the search
/// icon finds another, and the menu shares or stops following the one
/// shown. With none followed it is the finder. Works without login.
class VisitScreen extends ConsumerStatefulWidget {
  const VisitScreen({super.key});

  @override
  ConsumerState<VisitScreen> createState() => _VisitScreenState();
}

class _VisitScreenState extends ConsumerState<VisitScreen> {
  String? _selected;

  Future<void> _find() async {
    final followed = await context.push<String>(findMasjidLocation);
    if (followed != null && mounted) setState(() => _selected = followed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final followed = ref.watch(followedMasjidsProvider);
    if (followed.isEmpty) return const FindMasjidScreen(embedded: true);

    // The chosen one, or the newest followed (also after stopping one).
    final current = followed.firstWhere(
      (masjid) => masjid.code == _selected,
      orElse: () => followed.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.masjidTimesTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.findMasjid,
            onPressed: _find,
            icon: const Icon(AppIcons.search),
          ),
          MasjidMenuButton(masjid: current),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (followed.length > 1)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.l,
                  AppSpace.xs,
                  AppSpace.l,
                  AppSpace.s,
                ),
                child: Row(
                  children: <Widget>[
                    for (final masjid in followed)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: AppSpace.s,
                        ),
                        child: ChoiceChip(
                          label: Text(masjid.name),
                          selected: masjid.code == current.code,
                          onSelected: (_) =>
                              setState(() => _selected = masjid.code),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: PublicMasjidView(
                key: ValueKey(current.code),
                code: current.code,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

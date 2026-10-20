import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/features/visit/application/followed_masjids.dart';
import 'package:masjid_core_frontend/features/visit/data/public_masjid_api.dart';
import 'package:masjid_core_frontend/features/visit/presentation/public_masjid_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Where finding a masjid opens (a code or search).
const String findMasjidLocation = '/visit/find';

/// "Masjid times" (`/visit`): with followed masjids, straight to their
/// times and news (chips on top switch between several; the search icon
/// finds another). With none, finding a masjid. Works without login.
class VisitScreen extends ConsumerStatefulWidget {
  const VisitScreen({super.key});

  @override
  ConsumerState<VisitScreen> createState() => _VisitScreenState();
}

class _VisitScreenState extends ConsumerState<VisitScreen> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final followed = ref.watch(followedMasjidsProvider);
    if (followed.isEmpty) return const FindMasjidScreen();

    // The chosen one, or the newest followed when it was unfollowed.
    final code = followed.any((masjid) => masjid.code == _selected)
        ? _selected!
        : followed.first.code;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.seeMasjidTimes),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.findMasjid,
            onPressed: () => context.push(findMasjidLocation),
            icon: const Icon(AppIcons.search),
          ),
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
                  AppSpace.s,
                  AppSpace.l,
                  AppSpace.xs,
                ),
                child: Row(
                  children: <Widget>[
                    for (final masjid in followed)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: AppSpace.s,
                        ),
                        child: ChoiceChip(
                          avatar: const Icon(AppIcons.mosque, size: 20),
                          label: Text(masjid.name),
                          selected: masjid.code == code,
                          onSelected: (_) =>
                              setState(() => _selected = masjid.code),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: PublicMasjidView(key: ValueKey(code), code: code),
            ),
          ],
        ),
      ),
    );
  }
}

/// Find a masjid to see its namaz times and public news: type its code
/// (from the masjid's notice board or a WhatsApp message) or search by
/// name or place. Works without login.
class FindMasjidScreen extends ConsumerStatefulWidget {
  const FindMasjidScreen({super.key});

  @override
  ConsumerState<FindMasjidScreen> createState() => _FindMasjidScreenState();
}

class _FindMasjidScreenState extends ConsumerState<FindMasjidScreen> {
  final TextEditingController _code = TextEditingController();
  final TextEditingController _search = TextEditingController();
  bool _searching = false;
  Object? _searchError;
  List<PublicMasjid>? _results;

  @override
  void dispose() {
    _code.dispose();
    _search.dispose();
    super.dispose();
  }

  bool get _codeComplete => normalizeMasjidCode(_code.text).length == 6;

  void _openCode() {
    if (!_codeComplete) return;
    context.push('/visit/${normalizeMasjidCode(_code.text)}');
  }

  Future<void> _runSearch() async {
    final text = _search.text.trim();
    if (text.length < 2 || _searching) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final results = await ref.read(publicMasjidApiProvider).search(text);
      if (mounted) setState(() => _results = results);
    } catch (error) {
      if (mounted) setState(() => _searchError = error);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final results = _results;
    final searchError = _searchError;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.findMasjid)),
      body: SingleChildScrollView(
        child: PageBody.form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(l10n.masjidCodeLabel, style: textTheme.titleMedium),
              const SizedBox(height: AppSpace.s),
              TextField(
                controller: _code,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.go,
                autocorrect: false,
                maxLength: 7,
                style: textTheme.headlineSmall?.copyWith(letterSpacing: 4),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9 -]')),
                ],
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _openCode(),
                decoration: InputDecoration(
                  hintText: 'K7M 2QX',
                  helperText: l10n.masjidCodeHint,
                  prefixIcon: const Icon(AppIcons.mosque),
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppSpace.m),
              FilledButton.icon(
                onPressed: _codeComplete ? _openCode : null,
                icon: const Icon(AppIcons.next),
                label: Text(l10n.openMasjid),
              ),
              const SizedBox(height: AppSpace.xl),
              Text(l10n.orSearchMasjid, style: textTheme.titleMedium),
              const SizedBox(height: AppSpace.s),
              TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _runSearch(),
                decoration: InputDecoration(
                  hintText: l10n.searchMasjidHint,
                  prefixIcon: const Icon(AppIcons.search),
                  suffixIcon: IconButton(
                    tooltip: l10n.search,
                    onPressed: _runSearch,
                    icon: const Icon(AppIcons.next),
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.m),
              if (_searching)
                const SkeletonList(itemCount: 2)
              else if (searchError != null)
                MessageBanner(text: errorText(l10n, searchError))
              else if (results != null && results.isEmpty)
                MessageBanner(
                  kind: StatusKind.neutral,
                  text: l10n.noMasjidFound,
                )
              else if (results != null)
                for (final masjid in results)
                  MasjidLinkTile(
                    masjid: masjid,
                    onTap: () => context.push('/visit/${masjid.code}'),
                  ),
              const SizedBox(height: AppSpace.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// A masjid's name and place, tapping opens its public page. [trailing]
/// replaces the arrow (Home shows the next namaz there).
class MasjidLinkTile extends StatelessWidget {
  const MasjidLinkTile({
    super.key,
    required this.masjid,
    required this.onTap,
    this.trailing,
  });

  final PublicMasjid masjid;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final place = masjid.place;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.m),
          child: Row(
            children: <Widget>[
              const ToneIcon(icon: AppIcons.mosque, tone: AppTones.namaz),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(masjid.name, style: textTheme.titleMedium),
                    if (place.isNotEmpty)
                      Text(
                        place,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.s),
              trailing ?? const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

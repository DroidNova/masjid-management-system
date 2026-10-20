import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/features/visit/data/public_masjid_api.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Where finding a masjid opens.
const String findMasjidLocation = '/visit/find';

/// Find a masjid: one search box for its name, village or code (from the
/// notice board or a WhatsApp message); results show as you type. Opening
/// one and following it comes back here with its code, and this screen
/// returns it to whoever opened it (Masjid times selects it).
///
/// [embedded]: shown inside Masjid times when nothing is followed yet,
/// so there is nothing to return to; that screen updates by itself.
class FindMasjidScreen extends ConsumerStatefulWidget {
  const FindMasjidScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<FindMasjidScreen> createState() => _FindMasjidScreenState();
}

class _FindMasjidScreenState extends ConsumerState<FindMasjidScreen> {
  final TextEditingController _query = TextEditingController();
  Timer? _debounce;
  bool _searching = false;
  Object? _error;
  List<PublicMasjid>? _results;

  /// The text the shown results are for; older answers are dropped.
  String _resultsFor = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    if (text.trim().length < 2) {
      setState(() {
        _results = null;
        _error = null;
        _searching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), _search);
  }

  Future<void> _search() async {
    final text = _query.text.trim();
    if (text.length < 2) return;
    _resultsFor = text;
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final results = await ref.read(publicMasjidApiProvider).search(text);
      if (!mounted || text != _resultsFor) return;
      setState(() => _results = results);
    } catch (error) {
      if (mounted && text == _resultsFor) setState(() => _error = error);
    } finally {
      if (mounted && text == _resultsFor) setState(() => _searching = false);
    }
  }

  Future<void> _open(PublicMasjid masjid) async {
    final followed = await context.push<String>('/visit/${masjid.code}');
    if (followed == null || !mounted || widget.embedded) return;
    context.pop(followed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final results = _results;
    final error = _error;

    final Widget content;
    if (error != null) {
      content = MessageBanner(text: errorText(l10n, error));
    } else if (results == null) {
      content = _Hint(text: l10n.findMasjidHelp);
    } else if (results.isEmpty && !_searching) {
      content = _Hint(text: l10n.noMasjidFound);
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final masjid in results)
            MasjidLinkTile(masjid: masjid, onTap: () => _open(masjid)),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.embedded ? l10n.masjidTimesTitle : l10n.findMasjid),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.l,
            AppSpace.s,
            AppSpace.l,
            AppSpace.xl,
          ),
          children: <Widget>[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxFormWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (widget.embedded) ...<Widget>[
                      Text(l10n.findMasjid, style: textTheme.titleLarge),
                      const SizedBox(height: AppSpace.m),
                    ],
                    SearchBar(
                      controller: _query,
                      autoFocus: !widget.embedded,
                      hintText: l10n.findMasjidSearchHint,
                      leading: const Icon(AppIcons.search),
                      trailing: <Widget>[
                        if (_searching)
                          const Padding(
                            padding: EdgeInsets.all(AppSpace.s),
                            child: SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else if (_query.text.isNotEmpty)
                          IconButton(
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).deleteButtonTooltip,
                            onPressed: () {
                              _query.clear();
                              _onChanged('');
                            },
                            icon: const Icon(AppIcons.close),
                          ),
                      ],
                      onChanged: _onChanged,
                      onSubmitted: (_) {
                        _debounce?.cancel();
                        _search();
                      },
                      elevation: const WidgetStatePropertyAll<double>(0),
                      backgroundColor: WidgetStatePropertyAll<Color>(
                        Theme.of(context).colorScheme.surfaceContainerHigh,
                      ),
                      padding: const WidgetStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: AppSpace.m),
                      ),
                    ),
                    const SizedBox(height: AppSpace.l),
                    content,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A short grey help line with an info picture, centred.
class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.l,
        vertical: AppSpace.xl,
      ),
      child: Column(
        children: <Widget>[
          const ToneIcon(
            icon: AppIcons.mosque,
            tone: AppTones.namaz,
            size: 64,
            circle: true,
          ),
          const SizedBox(height: AppSpace.m),
          Text(
            text,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A masjid's name and place; tapping opens it. [trailing] replaces the
/// arrow (Home shows the next namaz there).
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

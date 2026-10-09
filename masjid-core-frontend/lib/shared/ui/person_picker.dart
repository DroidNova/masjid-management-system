import 'dart:async';

import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/app_icons.dart';
import 'package:masjid_core_frontend/shared/ui/empty_state.dart';
import 'package:masjid_core_frontend/shared/ui/person_avatar.dart';
import 'package:masjid_core_frontend/shared/ui/responsive.dart';
import 'package:masjid_core_frontend/shared/ui/skeleton.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// A person shown in [showPersonPicker].
@immutable
class PickablePerson {
  const PickablePerson({required this.id, required this.name, this.subtitle});

  final String id;
  final String name;

  /// Phone number or family name, to tell people with the same name apart.
  final String? subtitle;
}

/// Pick a person from a searchable list instead of typing a name (rule 8).
/// [search] is called with the typed text ('' at first) and returns
/// matches; each feature passes its own repository call. Returns null when
/// closed without picking.
Future<PickablePerson?> showPersonPicker(
  BuildContext context, {
  required Future<List<PickablePerson>> Function(String query) search,
  required String title,
}) {
  final body = _PersonPickerBody(search: search, title: title);
  if (ScreenSize.of(context) == ScreenSize.compact) {
    return showModalBottomSheet<PickablePerson>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.9,
        child: body,
      ),
    );
  }
  return showDialog<PickablePerson>(
    context: context,
    builder: (_) =>
        Dialog(child: SizedBox(width: 520, height: 640, child: body)),
  );
}

class _PersonPickerBody extends StatefulWidget {
  const _PersonPickerBody({required this.search, required this.title});

  final Future<List<PickablePerson>> Function(String query) search;
  final String title;

  @override
  State<_PersonPickerBody> createState() => _PersonPickerBodyState();
}

class _PersonPickerBodyState extends State<_PersonPickerBody> {
  Timer? _debounce;
  int _request = 0;
  String _query = '';
  bool _loading = true;
  bool _failed = false;
  List<PickablePerson> _people = const <PickablePerson>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String text) {
    _query = text.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _load);
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final people = await widget.search(_query);
      // Ignore answers to older searches that arrive late.
      if (!mounted || request != _request) return;
      setState(() {
        _people = people;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || request != _request) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final Widget results;
    if (_loading) {
      results = const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpace.l),
        child: SkeletonList(),
      );
    } else if (_failed) {
      results = EmptyState(
        icon: AppIcons.problem,
        tone: AppTones.problem,
        title: l10n.somethingWentWrong,
        actionLabel: l10n.tryAgain,
        onAction: _load,
      );
    } else if (_people.isEmpty) {
      results = EmptyState(
        icon: AppIcons.personSearch,
        title: l10n.nothingFound,
      );
    } else {
      results = ListView.separated(
        itemCount: _people.length,
        separatorBuilder: (_, _) => const Divider(indent: 80),
        itemBuilder: (context, index) {
          final person = _people[index];
          final subtitle = person.subtitle;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.l),
            leading: PersonAvatar(name: person.name),
            title: Text(person.name),
            subtitle: subtitle == null
                ? null
                : Text(subtitle, textDirection: TextDirection.ltr),
            onTap: () => Navigator.of(context).pop(person),
          );
        },
      );
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpace.l,
            AppSpace.s,
            AppSpace.s,
            AppSpace.s,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: l10n.close,
                icon: const Icon(AppIcons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.l),
          child: TextField(
            autofocus: true,
            onChanged: _onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(AppIcons.search),
              hintText: l10n.searchPeople,
            ),
          ),
        ),
        const SizedBox(height: AppSpace.s),
        Expanded(child: results),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/settings/app_settings.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Every design-system piece on one page, to check the look in each
/// language, at phone, tablet, and desktop widths, and on each platform.
/// Development builds only (route `/dev/gallery`). Its own labels are
/// English on purpose: it is a developer tool, not part of the app.
class DesignGalleryScreen extends ConsumerStatefulWidget {
  const DesignGalleryScreen({super.key});

  @override
  ConsumerState<DesignGalleryScreen> createState() =>
      _DesignGalleryScreenState();
}

class _DesignGalleryScreenState extends ConsumerState<DesignGalleryScreen> {
  String _amount = '';
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  TimeOfDay _time = const TimeOfDay(hour: 16, minute: 45);
  bool _dangerFails = false;

  static const List<PickablePerson> _people = <PickablePerson>[
    PickablePerson(
      id: '1',
      name: 'Mohammed Rafiq',
      subtitle: '+91 98765 43210',
    ),
    PickablePerson(id: '2', name: 'अब्दुल करीम', subtitle: '+91 91234 56780'),
    PickablePerson(id: '3', name: 'سلیم احمد', subtitle: '+91 99887 76655'),
    PickablePerson(id: '4', name: 'Imran Khan', subtitle: '+91 90000 11111'),
  ];

  Future<List<PickablePerson>> _search(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final q = query.toLowerCase();
    return _people
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              (p.subtitle ?? '').contains(q),
        )
        .toList();
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final settingsController = ref.read(appSettingsProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design gallery'),
        actions: <Widget>[
          PopupMenuButton<AppLanguage>(
            tooltip: 'Language',
            icon: const Icon(AppIcons.language),
            onSelected: settingsController.setLanguage,
            itemBuilder: (_) => AppLanguage.values
                .map(
                  (language) => PopupMenuItem<AppLanguage>(
                    value: language,
                    child: Text(language.nativeName),
                  ),
                )
                .toList(),
          ),
          IconButton(
            tooltip: 'Large text',
            isSelected: settings.largeText,
            icon: const Icon(AppIcons.textSize),
            onPressed: () =>
                settingsController.setLargeText(!settings.largeText),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Width: ${MediaQuery.sizeOf(context).width.round()} dp '
                '(${ScreenSize.of(context).name}) · '
                'platform: ${Theme.of(context).platform.name} · '
                'language: ${Localizations.localeOf(context).languageCode}',
                style: textTheme.bodySmall,
              ),

              const SectionHeader(
                title: 'Colours',
                icon: Icons.palette_rounded,
              ),
              Wrap(
                spacing: AppSpace.s,
                runSpacing: AppSpace.s,
                children:
                    <(String, AppTone)>[
                          ('brand', AppTones.brand),
                          ('namaz', AppTones.namaz),
                          ('news', AppTones.news),
                          ('money in', AppTones.moneyIn),
                          ('money out', AppTones.moneyOut),
                          ('projects', AppTones.projects),
                          ('people', AppTones.people),
                          ('salary', AppTones.salary),
                          ('neutral', AppTones.neutral),
                        ]
                        .map((entry) => _Swatch(name: entry.$1, tone: entry.$2))
                        .toList(),
              ),

              const SectionHeader(title: 'Hero card'),
              HeroCard(
                tone: AppTones.namaz,
                child: Row(
                  children: <Widget>[
                    const Icon(AppIcons.asr, size: 56),
                    const SizedBox(width: AppSpace.l),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Asr',
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '4:45 PM',
                            style: textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const Text('in 1 h 20 min'),
                        ],
                      ),
                    ),
                    const ReadAloudButton(
                      text: 'Asr at 4:45 PM, in 1 hour 20 minutes',
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              const SectionHeader(title: 'Action tiles'),
              ActionTileGrid(
                tiles: <Widget>[
                  ActionTile(
                    icon: AppIcons.moneyIn,
                    label: 'Money in',
                    tone: AppTones.moneyIn,
                    onTap: () => _snack('Money in'),
                  ),
                  ActionTile(
                    icon: AppIcons.moneyOut,
                    label: 'Money out',
                    tone: AppTones.moneyOut,
                    onTap: () => _snack('Money out'),
                  ),
                  ActionTile(
                    icon: AppIcons.salary,
                    label: 'Salary',
                    tone: AppTones.salary,
                    onTap: () => _snack('Salary'),
                  ),
                  ActionTile(
                    icon: AppIcons.projects,
                    label: 'Projects',
                    tone: AppTones.projects,
                    onTap: () => _snack('Projects'),
                  ),
                  ActionTile(
                    icon: AppIcons.announcements,
                    label: 'News',
                    tone: AppTones.news,
                    badge: 3,
                    onTap: () => _snack('News'),
                  ),
                  ActionTile(
                    icon: AppIcons.fajr,
                    label: 'Times',
                    tone: AppTones.namaz,
                    onTap: () => _snack('Times'),
                  ),
                ],
              ),

              const SectionHeader(title: 'Amounts and status'),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSpace.l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AmountText(125000, size: AmountSize.hero),
                      AmountText(
                        500,
                        kind: AmountKind.moneyIn,
                        size: AmountSize.large,
                      ),
                      AmountText(1250.5, kind: AmountKind.moneyOut),
                      SizedBox(height: AppSpace.m),
                      Wrap(
                        spacing: AppSpace.s,
                        runSpacing: AppSpace.s,
                        children: <Widget>[
                          StatusBadge(kind: StatusKind.done, label: 'Paid'),
                          StatusBadge(kind: StatusKind.waiting, label: 'Due'),
                          StatusBadge(kind: StatusKind.problem, label: 'Late'),
                          StatusBadge(kind: StatusKind.neutral, label: 'Draft'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SectionHeader(title: 'People'),
              Card(
                child: Column(
                  children: _people
                      .map(
                        (person) => ListTile(
                          leading: PersonAvatar(name: person.name),
                          title: Text(person.name),
                          subtitle: Text(
                            person.subtitle ?? '',
                            textDirection: TextDirection.ltr,
                          ),
                          trailing: const StatusBadge(
                            kind: StatusKind.done,
                            label: 'Active',
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SectionHeader(title: 'Pick, don\'t type'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpace.l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      DateChips(
                        value: _date,
                        first: DateTime(2020),
                        onChanged: (value) => setState(() => _date = value),
                      ),
                      const SizedBox(height: AppSpace.l),
                      OutlinedButton.icon(
                        icon: const Icon(AppIcons.time),
                        label: Text(_time.format(context)),
                        onPressed: () async {
                          final picked = await pickTime(
                            context,
                            initial: _time,
                          );
                          if (picked != null) setState(() => _time = picked);
                        },
                      ),
                      const SizedBox(height: AppSpace.l),
                      AmountPad(
                        value: _amount,
                        autofocus: false,
                        onChanged: (value) => setState(() => _amount = value),
                      ),
                    ],
                  ),
                ),
              ),

              const SectionHeader(title: 'Sheets, dialogs, results'),
              Wrap(
                spacing: AppSpace.s,
                runSpacing: AppSpace.s,
                children: <Widget>[
                  OutlinedButton.icon(
                    icon: const Icon(AppIcons.logout),
                    label: const Text('Confirm sheet'),
                    onPressed: () async {
                      final ok = await showConfirmSheet(
                        context,
                        icon: AppIcons.logout,
                        title: 'Log out?',
                        confirmLabel: 'Log out',
                      );
                      _snack('Confirmed: $ok');
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(AppIcons.leave),
                    label: const Text('Danger dialog'),
                    onPressed: () async {
                      final left = await showDangerDialog(
                        context,
                        title: 'Leave masjid?',
                        subject: 'Barota Jama Masjid',
                        confirmLabel: 'Leave',
                        confirmIcon: AppIcons.leave,
                        points: const <DangerPoint>[
                          DangerPoint(
                            icon: AppIcons.mosque,
                            text:
                                'You will no longer see this masjid\'s times, '
                                'news, and money.',
                          ),
                          DangerPoint(
                            icon: AppIcons.myPayments,
                            text: 'Your payment history stays with the masjid.',
                          ),
                          DangerPoint(
                            icon: AppIcons.people,
                            text: 'Another masjid can add you after you leave.',
                          ),
                        ],
                        onConfirm: () async {
                          await Future<void>.delayed(
                            const Duration(seconds: 1),
                          );
                          if (_dangerFails) {
                            throw Exception('Simulated failure');
                          }
                        },
                      );
                      if (left && context.mounted) {
                        await showSuccess(
                          context,
                          title: 'You left the masjid',
                          icon: AppIcons.leave,
                          tone: AppTones.neutral,
                        );
                      }
                    },
                  ),
                  FilterChip(
                    label: const Text('Danger fails'),
                    selected: _dangerFails,
                    onSelected: (value) => setState(() => _dangerFails = value),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(AppIcons.done),
                    label: const Text('Success screen'),
                    onPressed: () => showSuccess(
                      context,
                      title: 'Saved',
                      detail: AmountText.format(500, kind: AmountKind.moneyIn),
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(AppIcons.personSearch),
                    label: const Text('Person picker'),
                    onPressed: () async {
                      final person = await showPersonPicker(
                        context,
                        title: 'Pick a family head',
                        search: _search,
                      );
                      _snack('Picked: ${person?.name}');
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(AppIcons.next),
                    label: const Text('Step flow'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const _StepFlowDemo(),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.view_sidebar_rounded),
                    label: const Text('Adaptive scaffold'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const _ScaffoldDemo(),
                      ),
                    ),
                  ),
                ],
              ),

              const SectionHeader(title: 'Hold to confirm'),
              HoldToConfirmButton(
                label: 'Leave',
                icon: AppIcons.leave,
                onConfirmed: () => _snack('Held long enough'),
              ),

              const SectionHeader(title: 'Loading and empty'),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSpace.l),
                  child: SkeletonList(itemCount: 3),
                ),
              ),
              const SizedBox(height: AppSpace.m),
              Card(
                child: SizedBox(
                  height: 380,
                  child: EmptyState(
                    icon: AppIcons.projects,
                    tone: AppTones.projects,
                    title: 'No projects yet',
                    actionLabel: 'Add first project',
                    actionIcon: AppIcons.add,
                    onAction: () => _snack('Add project'),
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.tone});

  final String name;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(AppSpace.s),
      decoration: BoxDecoration(
        color: tone.container,
        borderRadius: BorderRadius.circular(AppRadius.s),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(radius: 10, backgroundColor: tone.color),
          const SizedBox(width: AppSpace.s),
          Expanded(
            child: Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: tone.color),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepFlowDemo extends StatefulWidget {
  const _StepFlowDemo();

  @override
  State<_StepFlowDemo> createState() => _StepFlowDemoState();
}

class _StepFlowDemoState extends State<_StepFlowDemo> {
  String _amount = '';
  DateTime _date = DateUtils.dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Money in')),
      body: StepFlow(
        tone: AppTones.moneyIn,
        finishLabel: 'Save',
        onFinish: () async {
          await Future<void>.delayed(const Duration(milliseconds: 800));
          if (!context.mounted) return;
          final amount = AmountPad.parse(_amount) ?? 0;
          await showSuccess(
            context,
            title: 'Saved',
            detail: AmountText.format(amount, kind: AmountKind.moneyIn),
          );
          if (context.mounted) Navigator.of(context).pop();
        },
        steps: <FlowStep>[
          FlowStep(
            title: 'What kind?',
            icon: AppIcons.money,
            builder: (_) => ActionTileGrid(
              tiles: <Widget>[
                ActionTile(
                  icon: AppIcons.jumma,
                  label: 'Jumma',
                  tone: AppTones.moneyIn,
                  onTap: () {},
                ),
                ActionTile(
                  icon: AppIcons.donationBox,
                  label: 'Donation box',
                  tone: AppTones.moneyIn,
                  onTap: () {},
                ),
                ActionTile(
                  icon: AppIcons.zakat,
                  label: 'Zakat',
                  tone: AppTones.moneyIn,
                  onTap: () {},
                ),
              ],
            ),
          ),
          FlowStep(
            title: 'How much?',
            icon: AppIcons.salary,
            canContinue: AmountPad.parse(_amount) != null,
            builder: (_) => AmountPad(
              value: _amount,
              onChanged: (value) => setState(() => _amount = value),
            ),
          ),
          FlowStep(
            title: 'Which day?',
            icon: AppIcons.calendar,
            builder: (_) => DateChips(
              value: _date,
              first: DateTime(2020),
              onChanged: (value) => setState(() => _date = value),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaffoldDemo extends StatefulWidget {
  const _ScaffoldDemo();

  @override
  State<_ScaffoldDemo> createState() => _ScaffoldDemoState();
}

class _ScaffoldDemoState extends State<_ScaffoldDemo> {
  int _index = 0;

  static const List<AppDestination> _destinations = <AppDestination>[
    AppDestination(icon: AppIcons.home, label: 'Home'),
    AppDestination(icon: AppIcons.money, label: 'Money'),
    AppDestination(icon: AppIcons.projects, label: 'Projects'),
    AppDestination(icon: AppIcons.people, label: 'People'),
    AppDestination(icon: AppIcons.profile, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: const Text('Barota Jama Masjid'),
      header: const Padding(
        padding: EdgeInsets.all(AppSpace.l),
        child: Row(
          children: <Widget>[
            ToneIcon(icon: AppIcons.mosque, tone: AppTones.brand),
            SizedBox(width: AppSpace.m),
            Text('Barota Jama Masjid'),
          ],
        ),
      ),
      destinations: _destinations,
      selectedIndex: _index,
      onSelected: (index) => setState(() => _index = index),
      body: EmptyState(
        icon: _destinations[_index].icon,
        title: _destinations[_index].label,
        message: 'Resize the window: bottom bar → rail → side menu.',
        actionLabel: 'Back to gallery',
        onAction: () => Navigator.of(context).pop(),
      ),
    );
  }
}

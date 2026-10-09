import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/namaz_time/application/namaz_time_controller.dart';
import 'package:masjid_core_frontend/features/namaz_time/application/prayer_schedule.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/namaz_time_model.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/update_namaz_time_request.dart';
import 'package:masjid_core_frontend/features/namaz_time/presentation/widgets/prayer_labels.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Changes the masjid's namaz times: one card per prayer with its picture,
/// a big time button (clock or wheels), and −5 / +5 minute buttons for the
/// usual small seasonal changes. Changing one time is: tap, pick, Save.
///
/// [initial] (the times already on screen) fills the form without another
/// request; from a fresh URL the times are loaded.
class UpdateNamazTimeScreen extends ConsumerWidget {
  const UpdateNamazTimeScreen({super.key, this.initial});

  final NamazTimeModel? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final masjidId = ref.watch(
      currentUserProvider.select((user) => user?.masjidId),
    );

    Widget page(Widget body) => Scaffold(
      appBar: AppBar(title: Text(l10n.changeTimes)),
      body: SafeArea(top: false, child: body),
    );

    if (masjidId == null || masjidId.isEmpty) {
      return page(
        EmptyState(icon: AppIcons.mosque, title: l10n.noMasjidAssigned),
      );
    }

    final prefilled = initial;
    if (prefilled != null) return _NamazTimeForm(initial: prefilled);

    return ref
        .watch(myNamazTimeProvider)
        .when(
          // Keep the form (and what was changed) while it reloads.
          skipLoadingOnReload: true,
          loading: () => page(
            const SingleChildScrollView(
              child: PageBody.form(child: SkeletonList()),
            ),
          ),
          error: (error, _) => page(
            ErrorState(
              error: error,
              onRetry: () => ref.invalidate(myNamazTimeProvider),
            ),
          ),
          data: (namazTime) => _NamazTimeForm(initial: namazTime),
        );
  }
}

class _NamazTimeForm extends ConsumerStatefulWidget {
  const _NamazTimeForm({required this.initial});

  final NamazTimeModel initial;

  @override
  ConsumerState<_NamazTimeForm> createState() => _NamazTimeFormState();
}

class _NamazTimeFormState extends ConsumerState<_NamazTimeForm> {
  static const List<Prayer> _daily = <Prayer>[
    Prayer.fajr,
    Prayer.zuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  late final Map<Prayer, TimeOfDay?> _original = <Prayer, TimeOfDay?>{
    Prayer.fajr: parseNamazTime(widget.initial.fajr),
    Prayer.zuhr: parseNamazTime(widget.initial.zuhr),
    Prayer.asr: parseNamazTime(widget.initial.asr),
    Prayer.maghrib: parseNamazTime(widget.initial.maghrib),
    Prayer.isha: parseNamazTime(widget.initial.isha),
    Prayer.jumma: parseNamazTime(widget.initial.jumma),
  };
  late final Map<Prayer, TimeOfDay?> _times = Map.of(_original);
  late final TextEditingController _note = TextEditingController(
    text: widget.initial.note ?? '',
  )..addListener(() => setState(() {}));
  String? _error;

  bool get _changed =>
      _times.entries.any((entry) => entry.value != _original[entry.key]) ||
      _note.text.trim() != (widget.initial.note ?? '').trim();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  /// Typical time when a prayer has none yet, so the clock opens near it.
  static TimeOfDay _fallback(Prayer prayer) => switch (prayer) {
    Prayer.fajr => const TimeOfDay(hour: 5, minute: 0),
    Prayer.zuhr => const TimeOfDay(hour: 13, minute: 30),
    Prayer.asr => const TimeOfDay(hour: 17, minute: 0),
    Prayer.maghrib => const TimeOfDay(hour: 18, minute: 30),
    Prayer.isha => const TimeOfDay(hour: 20, minute: 0),
    Prayer.jumma => const TimeOfDay(hour: 13, minute: 15),
  };

  Future<void> _pick(Prayer prayer) async {
    final picked = await pickTime(
      context,
      initial: _times[prayer] ?? _fallback(prayer),
    );
    if (picked != null) {
      setState(() {
        _times[prayer] = picked;
        _error = null;
      });
    }
  }

  void _shift(Prayer prayer, int minutes) {
    setState(() {
      _times[prayer] = shiftTime(_times[prayer] ?? _fallback(prayer), minutes);
      _error = null;
    });
  }

  String? _stored(Prayer prayer) {
    final time = _times[prayer];
    return time == null ? null : formatNamazTime(time);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _error = null);
    final saved = await ref
        .read(namazTimeSaveControllerProvider.notifier)
        .save(
          UpdateNamazTimeRequest.fromForm(
            fajr: _stored(Prayer.fajr),
            zuhr: _stored(Prayer.zuhr),
            asr: _stored(Prayer.asr),
            maghrib: _stored(Prayer.maghrib),
            isha: _stored(Prayer.isha),
            jumma: _stored(Prayer.jumma),
            note: _note.text,
          ),
        );
    if (!mounted) return;
    if (!saved) {
      final error = ref.read(namazTimeSaveControllerProvider).error;
      setState(
        () => _error = errorText(l10n, error ?? l10n.somethingWentWrong),
      );
      return;
    }
    await showSuccess(context, title: l10n.timesSaved, icon: AppIcons.time);
    if (mounted) context.pop(true);
  }

  /// Leaving with unsaved changes asks first.
  Future<void> _confirmLeave() async {
    final l10n = AppLocalizations.of(context);
    final leave = await showConfirmSheet(
      context,
      icon: AppIcons.warning,
      tone: AppTones.waiting,
      title: l10n.leaveWithoutSaving,
      confirmLabel: l10n.leaveWithoutSavingConfirm,
    );
    if (leave && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saving = ref.watch(namazTimeSaveControllerProvider).isLoading;
    final error = _error;

    return PopScope(
      canPop: !_changed || saving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !saving) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.changeTimes)),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: PageBody.form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (final prayer in _daily)
                    _PrayerTimeCard(
                      prayer: prayer,
                      time: _times[prayer],
                      changed: _times[prayer] != _original[prayer],
                      enabled: !saving,
                      onPick: () => _pick(prayer),
                      onShift: (minutes) => _shift(prayer, minutes),
                    ),
                  SectionHeader(title: l10n.friday, icon: AppIcons.calendar),
                  _PrayerTimeCard(
                    prayer: Prayer.jumma,
                    time: _times[Prayer.jumma],
                    changed: _times[Prayer.jumma] != _original[Prayer.jumma],
                    enabled: !saving,
                    onPick: () => _pick(Prayer.jumma),
                    onShift: (minutes) => _shift(Prayer.jumma, minutes),
                  ),
                  const SizedBox(height: AppSpace.m),
                  AppFormField(
                    controller: _note,
                    label: l10n.noteOptional,
                    icon: AppIcons.info,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  if (error != null) ...<Widget>[
                    MessageBanner(text: error),
                    const SizedBox(height: AppSpace.l),
                  ],
                  BusyButton(
                    label: l10n.save,
                    icon: AppIcons.done,
                    busy: saving,
                    color: AppTones.namaz.color,
                    onPressed: _changed ? _save : null,
                  ),
                  const SizedBox(height: AppSpace.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One prayer: picture and name, the time as a big button, and −5 / +5.
class _PrayerTimeCard extends StatelessWidget {
  const _PrayerTimeCard({
    required this.prayer,
    required this.time,
    required this.changed,
    required this.enabled,
    required this.onPick,
    required this.onShift,
  });

  final Prayer prayer;
  final TimeOfDay? time;
  final bool changed;
  final bool enabled;
  final VoidCallback onPick;
  final ValueChanged<int> onShift;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final value = time;
    const tone = AppTones.namaz;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.m),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
          side: BorderSide(
            color: changed ? tone.color : AppColors.border,
            width: changed ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  ToneIcon(icon: prayer.icon, tone: tone, size: 44),
                  const SizedBox(width: AppSpace.m),
                  Expanded(
                    child: Text(
                      prayer.label(l10n),
                      style: textTheme.titleLarge,
                    ),
                  ),
                  if (changed)
                    StatusBadge(kind: StatusKind.waiting, label: l10n.changed),
                ],
              ),
              const SizedBox(height: AppSpace.m),
              Row(
                children: <Widget>[
                  IconButton.outlined(
                    tooltip: l10n.minusFiveMinutes,
                    onPressed: enabled ? () => onShift(-5) : null,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  const SizedBox(width: AppSpace.s),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: enabled ? onPick : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(64),
                        backgroundColor: tone.container,
                        foregroundColor: tone.color,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value == null
                              ? l10n.setTime
                              : prayerTimeText(context, value),
                          style: textTheme.headlineMedium?.copyWith(
                            color: tone.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s),
                  IconButton.outlined(
                    tooltip: l10n.plusFiveMinutes,
                    onPressed: enabled ? () => onShift(5) : null,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

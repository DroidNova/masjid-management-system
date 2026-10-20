import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/finance/presentation/money_categories.dart';
import 'package:masjid_core_frontend/features/projects/presentation/widgets/project_card.dart';
import 'package:masjid_core_frontend/features/record_history/data/record_history.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// A small history icon. Tapping it shows who added the record, who changed
/// or cancelled it, and when, so every money entry has a name behind it.
///
/// The server decides who may open which record (members: projects and
/// their own payments); screens only show the button where it applies.
class RecordHistoryButton extends StatelessWidget {
  const RecordHistoryButton({super.key, required this.target, this.color});

  final HistoryTarget target;

  /// Icon colour; defaults to the surrounding icon colour (app bar, card).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      tooltip: l10n.historyButton,
      icon: Icon(AppIcons.history, color: color),
      onPressed: () => showRecordHistory(context, target),
    );
  }
}

Future<void> showRecordHistory(BuildContext context, HistoryTarget target) =>
    showAppSheet<void>(
      context,
      builder: (sheetContext) => _HistorySheet(target: target),
    );

class _HistorySheet extends ConsumerWidget {
  const _HistorySheet({required this.target});

  final HistoryTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final history = ref.watch(recordHistoryProvider(target));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Center(
          child: ToneIcon(
            icon: AppIcons.history,
            tone: AppTones.people,
            size: 64,
            circle: true,
          ),
        ),
        const SizedBox(height: AppSpace.s),
        Text(
          l10n.historyTitle,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpace.l),
        history.when(
          loading: () => const Column(
            children: <Widget>[
              SkeletonBox(height: 56),
              SizedBox(height: AppSpace.s),
              SkeletonBox(height: 56),
            ],
          ),
          error: (_, _) => MessageBanner(
            text: l10n.historyLoadFailed,
            action: TextButton(
              onPressed: () => ref.invalidate(recordHistoryProvider(target)),
              child: Text(l10n.tryAgain),
            ),
          ),
          data: (data) => _Timeline(history: data),
        ),
        const SizedBox(height: AppSpace.xl),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.history});

  final RecordHistory history;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final collectedBy = history.collectedByName?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (!history.hasCreate)
          _Step(
            icon: AppIcons.info,
            tone: AppTones.neutral,
            title: l10n.historyBeforeTracking(
              AppFormat.date(history.createdAt),
            ),
          ),
        for (final event in history.events) _EventStep(event: event),
        if (collectedBy.isNotEmpty)
          _Step(
            icon: AppIcons.person,
            tone: AppTones.people,
            title: l10n.historyCollectedBy(collectedBy),
          ),
      ],
    );
  }
}

class _EventStep extends StatelessWidget {
  const _EventStep({required this.event});

  final HistoryEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = event.actorName;
    final (icon, tone, title) = switch (event.action) {
      'CREATE' when name == 'system' => (
        AppIcons.add,
        AppTones.moneyIn,
        l10n.historyAutomatic,
      ),
      'CREATE' => (AppIcons.add, AppTones.moneyIn, l10n.historyAdded(name)),
      'CANCEL' => (
        Icons.block_rounded,
        AppTones.danger,
        l10n.historyCancelled(name),
      ),
      _ => (AppIcons.edit, AppTones.namaz, l10n.historyChanged(name)),
    };
    return _Step(
      icon: icon,
      tone: tone,
      title: title,
      subtitle: AppFormat.dateTime(event.at),
      lines: <String>[
        for (final change in event.changes) _changeLine(context, change),
      ],
    );
  }

  /// "Amount: ₹500 → ₹700"; the arrow follows the reading direction.
  String _changeLine(BuildContext context, HistoryChange change) {
    final l10n = AppLocalizations.of(context);
    final arrow = Directionality.of(context) == TextDirection.rtl ? '←' : '→';
    final from = _value(l10n, change, change.from);
    final to = _value(l10n, change, change.to);
    return '${_fieldLabel(l10n, change.field)}: $from $arrow $to';
  }

  String _fieldLabel(AppLocalizations l10n, String field) => switch (field) {
    'amount' => l10n.historyFieldAmount,
    'title' => l10n.historyFieldName,
    'description' => l10n.historyFieldNote,
    'collectedAt' || 'spentAt' => l10n.historyFieldDate,
    'targetAmount' => l10n.historyFieldTarget,
    'spentAmount' => l10n.historyFieldSpent,
    'type' => l10n.historyFieldKind,
    'amountPerHead' => l10n.historyFieldPerFamily,
    'status' => l10n.status,
    'startDate' => l10n.startDate,
    'endDate' => l10n.endDate,
    _ => field,
  };

  String _value(AppLocalizations l10n, HistoryChange change, Object? value) {
    if (value == null) return '—';
    return switch (change.kind) {
      'money' when value is num => AppFormat.rupees(value),
      'date' => switch (DateTime.tryParse(value.toString())) {
        final DateTime date => AppFormat.date(date),
        null => value.toString(),
      },
      'code' when change.field == 'status' => projectStatusLook(
        l10n,
        value.toString(),
      ).$3,
      'code' when change.field == 'type' => moneyCategoryLabel(
        l10n,
        value.toString(),
      ),
      _ => value.toString(),
    };
  }
}

/// One line of the timeline: a coloured icon, what happened, when, and
/// the fields that changed.
class _Step extends StatelessWidget {
  const _Step({
    required this.icon,
    required this.tone,
    required this.title,
    this.subtitle,
    this.lines = const <String>[],
  });

  final IconData icon;
  final AppTone tone;
  final String title;
  final String? subtitle;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ToneIcon(icon: icon, tone: tone, size: 40, circle: true),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: textTheme.titleMedium),
                if (subtitle != null) Text(subtitle!, style: secondary),
                for (final line in lines)
                  Text(line, style: textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

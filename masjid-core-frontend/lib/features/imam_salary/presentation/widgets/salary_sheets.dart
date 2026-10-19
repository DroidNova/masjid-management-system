import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/finance/presentation/money_categories.dart';
import 'package:masjid_core_frontend/features/imam_salary/application/imam_salary_controllers.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/models/imam_salary_models.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/models/member_dues.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

int _paise(num amount) => (amount * 100).round();

/// Records a payment from one family head, the amount already set to what
/// they still owe: tap the family, then Save. Returns true when saved.
Future<bool> showSalaryPaymentSheet(
  BuildContext context,
  SalaryAssignment assignment,
) async {
  final saved = await showAppSheet<bool>(
    context,
    builder: (_) => _PaymentSheet(assignment: assignment),
  );
  if (saved != true || !context.mounted) return false;
  final l10n = AppLocalizations.of(context);
  await showSuccess(
    context,
    title: l10n.salaryPaymentSaved,
    detail: assignment.memberName,
    icon: AppIcons.salary,
    tone: AppTones.salary,
  );
  return true;
}

/// Starts the selected month: one amount for every family head.
Future<bool> showStartMonthSheet(BuildContext context) async {
  final saved = await showAppSheet<bool>(
    context,
    builder: (_) => const _AmountSheet(current: null),
  );
  if (saved != true || !context.mounted) return false;
  await showSuccess(
    context,
    title: AppLocalizations.of(context).salaryMonthStarted,
    icon: AppIcons.salary,
    tone: AppTones.salary,
  );
  return true;
}

/// Raises the amount per family for a started month (never lowers it).
Future<bool> showRaiseAmountSheet(
  BuildContext context,
  ImamSalaryMonth month,
) async {
  final saved = await showAppSheet<bool>(
    context,
    builder: (_) => _AmountSheet(current: month.amountPerHead),
  );
  if (saved != true || !context.mounted) return false;
  await showSuccess(
    context,
    title: AppLocalizations.of(context).saved,
    icon: AppIcons.salary,
    tone: AppTones.salary,
  );
  return true;
}

class _PaymentSheet extends ConsumerStatefulWidget {
  const _PaymentSheet({required this.assignment});

  final SalaryAssignment assignment;

  @override
  ConsumerState<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<_PaymentSheet> {
  late String _amount = AmountPad.textOf(widget.assignment.dueAmount);
  String _mode = 'CASH';
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  bool _saving = false;
  String? _error;

  /// Everything this family owes over all months, once loaded.
  MemberDues? get _dues =>
      ref.watch(memberDuesProvider(widget.assignment.memberId)).valueOrNull;

  /// The most that can be paid now: all months when known, else this one.
  double get _maxDue => _dues?.totalDue ?? widget.assignment.dueAmount;

  /// More than this month's due goes over all months, oldest first.
  bool _spreads(num amount) =>
      _paise(amount) > _paise(widget.assignment.dueAmount);

  String? _problem(AppLocalizations l10n) {
    final amount = AmountPad.parse(_amount);
    if (amount == null) return null;
    if (_paise(amount) > _paise(_maxDue)) {
      return l10n.payMoreThanDue(AppFormat.rupees(_maxDue));
    }
    return null;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final amount = AmountPad.parse(_amount);
    if (amount == null || _problem(l10n) != null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final controller = ref.read(salaryMonthProvider.notifier);
      if (_spreads(amount)) {
        await controller.spreadPayment(
          assignment: widget.assignment,
          amount: amount.toDouble(),
          totalDue: _maxDue,
          paymentMode: _mode,
          paidAt: _date,
        );
      } else {
        await controller.addPayment(
          assignment: widget.assignment,
          amount: amount.toDouble(),
          paymentMode: _mode,
          paidAt: _date,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = errorText(l10n, error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final assignment = widget.assignment;
    final problem = _problem(l10n);
    final error = problem ?? _error;
    final dues = _dues;
    final earlier = dues == null
        ? 0.0
        : (dues.totalDue - assignment.dueAmount).clamp(0.0, double.infinity);
    final typed = AmountPad.parse(_amount);

    return PopScope(
      canPop: !_saving,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              PersonAvatar(name: assignment.memberName),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(assignment.memberName, style: textTheme.titleLarge),
                    Text(
                      l10n.stillToPay(AppFormat.rupees(assignment.dueAmount)),
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppTones.waiting.color,
                      ),
                    ),
                    if (earlier > 0)
                      Text(
                        l10n.olderMonthsDue(AppFormat.rupees(earlier)),
                        style: textTheme.titleSmall?.copyWith(
                          color: AppTones.problem.color,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (dues != null && earlier > 0) ...<Widget>[
            const SizedBox(height: AppSpace.m),
            Wrap(
              spacing: AppSpace.s,
              runSpacing: AppSpace.s,
              children: <Widget>[
                for (final (label, value) in <(String, double)>[
                  (
                    l10n.thisMonthAmount(
                      AppFormat.rupees(assignment.dueAmount),
                    ),
                    assignment.dueAmount,
                  ),
                  (
                    l10n.allMonthsAmount(AppFormat.rupees(dues.totalDue)),
                    dues.totalDue,
                  ),
                ])
                  ChoiceChip(
                    label: Text(label),
                    selected: typed != null && _paise(typed) == _paise(value),
                    selectedColor: AppTones.salary.container,
                    onSelected: (_) => setState(() {
                      _amount = AmountPad.textOf(value);
                      _error = null;
                    }),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpace.l),
          AmountPad(
            value: _amount,
            autofocus: false,
            quickAmounts: const <int>[],
            onChanged: (value) => setState(() {
              _amount = value;
              _error = null;
            }),
          ),
          if (dues != null &&
              typed != null &&
              problem == null &&
              _spreads(typed)) ...<Widget>[
            const SizedBox(height: AppSpace.m),
            _Coverage(parts: dues.cover(typed.toDouble())),
          ],
          const SizedBox(height: AppSpace.l),
          Wrap(
            spacing: AppSpace.s,
            children: <String>['CASH', 'ONLINE']
                .map(
                  (mode) => ChoiceChip(
                    avatar: Icon(paymentModeIcon(mode), size: 20),
                    label: Text(paymentModeLabel(l10n, mode)),
                    selected: _mode == mode,
                    onSelected: (_) => setState(() => _mode = mode),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpace.m),
          DateChips(
            value: _date,
            first: DateTime(2000),
            onChanged: (value) => setState(() => _date = value),
          ),
          if (error != null) ...<Widget>[
            const SizedBox(height: AppSpace.m),
            MessageBanner(text: error),
          ],
          const SizedBox(height: AppSpace.l),
          BusyButton(
            label: l10n.save,
            icon: AppIcons.done,
            busy: _saving,
            color: AppTones.salary.color,
            onPressed: AmountPad.parse(_amount) == null || problem != null
                ? null
                : _save,
          ),
        ],
      ),
    );
  }
}

/// "This pays for:" and a chip per month the amount reaches: a tick when
/// the month is fully paid, the part otherwise. Shown when one amount
/// covers several months, so the committee sees where the money goes.
class _Coverage extends StatelessWidget {
  const _Coverage({required this.parts});

  final List<(DueMonth, double)> parts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return FadeSlideIn(
      offset: 12,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.m),
        decoration: BoxDecoration(
          color: AppTones.done.container,
          borderRadius: BorderRadius.circular(AppRadius.m),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.paysFor, style: textTheme.titleSmall),
            const SizedBox(height: AppSpace.s),
            Wrap(
              spacing: AppSpace.s,
              runSpacing: AppSpace.s,
              children: <Widget>[
                for (final (month, part) in parts)
                  _MonthPart(
                    label: AppFormat.monthYear(month.month, month.year),
                    full: _paise(part) >= _paise(month.dueAmount),
                    part: part,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthPart extends StatelessWidget {
  const _MonthPart({
    required this.label,
    required this.full,
    required this.part,
  });

  final String label;
  final bool full;
  final double part;

  @override
  Widget build(BuildContext context) {
    final tone = full ? AppTones.done : AppTones.waiting;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.m,
        vertical: AppSpace.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: tone.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            full ? AppIcons.done : AppIcons.waiting,
            size: 18,
            color: tone.color,
          ),
          const SizedBox(width: AppSpace.xs),
          Text(
            full ? label : '$label · ${AppFormat.rupees(part)}',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: tone.color),
          ),
        ],
      ),
    );
  }
}

/// The amount per family: to start a month ([current] null) or to raise it.
class _AmountSheet extends ConsumerStatefulWidget {
  const _AmountSheet({required this.current});

  final double? current;

  @override
  ConsumerState<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends ConsumerState<_AmountSheet> {
  late String _amount = AmountPad.textOf(widget.current ?? 0);
  bool _saving = false;
  String? _error;

  String? _problem(AppLocalizations l10n) {
    final amount = AmountPad.parse(_amount);
    final current = widget.current;
    if (amount == null || current == null) return null;
    if (_paise(amount) < _paise(current)) {
      return l10n.amountCanOnlyGoUp(AppFormat.rupees(current));
    }
    return null;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final amount = AmountPad.parse(_amount);
    if (amount == null || _problem(l10n) != null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final controller = ref.read(salaryMonthProvider.notifier);
    try {
      if (widget.current == null) {
        await controller.startMonth(amountPerHead: amount.toDouble());
      } else {
        await controller.increaseAmount(amountPerHead: amount.toDouble());
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = errorText(l10n, error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final problem = _problem(l10n);
    final error = problem ?? _error;
    final starting = widget.current == null;

    return PopScope(
      canPop: !_saving,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ScreenHeader(
            icon: AppIcons.salary,
            tone: AppTones.salary,
            title: starting ? l10n.startSalaryMonth : l10n.raiseAmount,
            subtitle: l10n.amountPerFamilyHelp,
          ),
          AmountPad(
            value: _amount,
            autofocus: false,
            quickAmounts: const <int>[200, 300, 500, 1000],
            onChanged: (value) => setState(() {
              _amount = value;
              _error = null;
            }),
          ),
          if (error != null) ...<Widget>[
            const SizedBox(height: AppSpace.m),
            MessageBanner(text: error),
          ],
          const SizedBox(height: AppSpace.l),
          BusyButton(
            label: starting ? l10n.startSalaryMonth : l10n.save,
            icon: AppIcons.done,
            busy: _saving,
            color: AppTones.salary.color,
            onPressed: AmountPad.parse(_amount) == null || problem != null
                ? null
                : _save,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/finance/presentation/money_categories.dart';
import 'package:masjid_core_frontend/features/imam_salary/application/imam_salary_controllers.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/models/imam_salary_models.dart';
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

  String? _problem(AppLocalizations l10n) {
    final amount = AmountPad.parse(_amount);
    if (amount == null) return null;
    if (_paise(amount) > _paise(widget.assignment.dueAmount)) {
      return l10n.payMoreThanDue(AppFormat.rupees(widget.assignment.dueAmount));
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
      await ref
          .read(salaryMonthProvider.notifier)
          .addPayment(
            assignment: widget.assignment,
            amount: amount.toDouble(),
            paymentMode: _mode,
            paidAt: _date,
          );
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
                  ],
                ),
              ),
            ],
          ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/imam_salary/application/imam_salary_controllers.dart';
import 'package:masjid_core_frontend/features/imam_salary/application/salary_validation.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/models/imam_salary_models.dart';

/// Shared shell: form, Cancel / Save buttons, saving spinner, server error.
/// Each dialog owns (and disposes) its text controllers.
abstract class _SalaryFormState<W extends ConsumerStatefulWidget>
    extends ConsumerState<W> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _saving = false;
  Object? error;

  String get title;
  String get saveLabel => 'Save';
  List<Widget> fields(BuildContext context);

  /// Calls the controller. Throws ApiException on failure.
  Future<void> submit();

  Future<void> _save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      error = null;
    });
    try {
      await submit();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        error = e;
      });
    }
  }

  /// Message for errors not tied to a form field.
  String? get _generalError {
    final e = error;
    if (e == null) return null;
    return fieldErrorFor(e) == null ? userMessage(e) : null;
  }

  /// Field error shown under the amount field, if this error has one.
  String? fieldErrorFor(Object e);

  @override
  Widget build(BuildContext context) {
    final general = _generalError;
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 400,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ...fields(context),
                if (general != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    general,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(saveLabel),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

/// Starts the selected month. Pops `true` when saved.
class StartSalaryMonthDialog extends ConsumerStatefulWidget {
  const StartSalaryMonthDialog({super.key});

  @override
  ConsumerState<StartSalaryMonthDialog> createState() =>
      _StartSalaryMonthDialogState();
}

class _StartSalaryMonthDialogState
    extends _SalaryFormState<StartSalaryMonthDialog> {
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _note = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  String get title => 'Start Salary Month';

  @override
  String? fieldErrorFor(Object e) => fieldError(e, 'amountPerHead');

  @override
  List<Widget> fields(BuildContext context) => <Widget>[
    TextFormField(
      controller: _amount,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Amount per family head',
        errorText: error == null ? null : fieldErrorFor(error!),
      ),
      validator: validateAmountPerHead,
    ),
    TextFormField(
      controller: _note,
      decoration: const InputDecoration(labelText: 'Note (optional)'),
    ),
  ];

  @override
  Future<void> submit() => ref
      .read(salaryMonthProvider.notifier)
      .startMonth(amountPerHead: parseRupees(_amount.text)!, note: _note.text);
}

// ---------------------------------------------------------------------------

/// Raises the amount per head of [month]. Pops `true` when saved.
class IncreaseSalaryDialog extends ConsumerStatefulWidget {
  const IncreaseSalaryDialog({super.key, required this.month});

  final ImamSalaryMonth month;

  @override
  ConsumerState<IncreaseSalaryDialog> createState() =>
      _IncreaseSalaryDialogState();
}

class _IncreaseSalaryDialogState
    extends _SalaryFormState<IncreaseSalaryDialog> {
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _reason = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  String get title => 'Increase Salary';

  @override
  String? fieldErrorFor(Object e) => fieldError(e, 'amountPerHead');

  @override
  List<Widget> fields(BuildContext context) => <Widget>[
    TextFormField(
      controller: _amount,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'New amount per family head',
        helperText: 'Now ${AppFormat.rupees(widget.month.amountPerHead)}',
        errorText: error == null ? null : fieldErrorFor(error!),
      ),
      validator: (value) =>
          validateIncreasedAmount(value, current: widget.month.amountPerHead),
    ),
    TextFormField(
      controller: _reason,
      decoration: const InputDecoration(labelText: 'Reason (optional)'),
    ),
  ];

  @override
  Future<void> submit() => ref
      .read(salaryMonthProvider.notifier)
      .increaseAmount(
        amountPerHead: parseRupees(_amount.text)!,
        reason: _reason.text,
      );
}

// ---------------------------------------------------------------------------

/// Records a payment for one family head. Pops `true` when saved.
class AddSalaryPaymentDialog extends ConsumerStatefulWidget {
  const AddSalaryPaymentDialog({super.key, required this.assignment});

  final SalaryAssignment assignment;

  @override
  ConsumerState<AddSalaryPaymentDialog> createState() =>
      _AddSalaryPaymentDialogState();
}

class _AddSalaryPaymentDialogState
    extends _SalaryFormState<AddSalaryPaymentDialog> {
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _note = TextEditingController();
  String _mode = 'CASH';
  DateTime _paidAt = DateTime.now();

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  String get title => 'Payment from ${widget.assignment.memberName}';

  @override
  String get saveLabel => 'Add Payment';

  @override
  String? fieldErrorFor(Object e) => fieldError(e, 'amount');

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: _paidAt,
    );
    if (picked != null && mounted) setState(() => _paidAt = picked);
  }

  @override
  List<Widget> fields(BuildContext context) => <Widget>[
    Text('Due ${AppFormat.rupees(widget.assignment.dueAmount)}'),
    TextFormField(
      controller: _amount,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Amount',
        errorText: error == null ? null : fieldErrorFor(error!),
      ),
      validator: (value) =>
          validatePaymentAmount(value, due: widget.assignment.dueAmount),
    ),
    DropdownButtonFormField<String>(
      initialValue: _mode,
      items: const <DropdownMenuItem<String>>[
        DropdownMenuItem<String>(value: 'CASH', child: Text('Cash')),
        DropdownMenuItem<String>(value: 'ONLINE', child: Text('Online')),
      ],
      onChanged: (value) {
        if (value != null) _mode = value;
      },
      decoration: const InputDecoration(labelText: 'Payment mode'),
    ),
    ListTile(
      title: Text(AppFormat.date(_paidAt)),
      trailing: const Icon(Icons.calendar_today),
      onTap: _pickDate,
    ),
    TextFormField(
      controller: _note,
      decoration: const InputDecoration(labelText: 'Note (optional)'),
    ),
  ];

  @override
  Future<void> submit() => ref
      .read(salaryMonthProvider.notifier)
      .addPayment(
        assignment: widget.assignment,
        amount: parseRupees(_amount.text)!,
        paymentMode: _mode,
        paidAt: _paidAt,
        note: _note.text,
      );
}

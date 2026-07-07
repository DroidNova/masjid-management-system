import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/features/finance/presentation/widgets/finance_labels.dart';
import 'package:platform_core_frontend/features/imam_salary/data/imam_salary_repository.dart';
import 'package:platform_core_frontend/features/imam_salary/models/create_imam_salary_request.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/app_text_field.dart';

const List<String> imamSalaryStatuses = <String>['UNPAID', 'PARTIAL', 'PAID'];
const Map<String, String> imamSalaryStatusLabels = <String, String>{
  'UNPAID': 'Unpaid',
  'PARTIAL': 'Partial',
  'PAID': 'Paid',
};
const List<String> imamSalaryMonthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class AddImamSalaryScreen extends StatefulWidget {
  const AddImamSalaryScreen({
    super.key,
    ImamSalaryRepository? imamSalaryRepository,
  }) : _imamSalaryRepository = imamSalaryRepository;

  final ImamSalaryRepository? _imamSalaryRepository;

  @override
  State<AddImamSalaryScreen> createState() => _AddImamSalaryScreenState();
}

class _AddImamSalaryScreenState extends State<AddImamSalaryScreen> {
  late final ImamSalaryRepository _repository =
      widget._imamSalaryRepository ?? ImamSalaryRepository();
  bool _isSaving = false;

  Future<void> _submit(ImamSalaryFormValue value) async {
    setState(() => _isSaving = true);
    try {
      await _repository.createImamSalary(
        CreateImamSalaryRequest(
          month: value.month,
          year: value.year,
          salaryAmount: value.salaryAmount,
          paidAmount: value.paidAmount,
          status: value.status,
          paidDate: value.paidDate,
          note: value.note,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salary record added successfully.')),
      );
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_cleanError(error))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('Add Imam Salary')),
      body: ImamSalaryFormBody(
        title: 'Add Salary Record',
        subtitle: 'Enter monthly salary payment details',
        initialMonth: now.month,
        initialYear: now.year,
        initialStatus: 'UNPAID',
        isSaving: _isSaving,
        buttonLabel: 'Save Salary',
        onSubmit: _submit,
      ),
    );
  }
}

class ImamSalaryFormValue {
  const ImamSalaryFormValue({
    required this.month,
    required this.year,
    required this.salaryAmount,
    required this.paidAmount,
    required this.status,
    this.paidDate,
    this.note,
  });

  final int month;
  final int year;
  final double salaryAmount;
  final double paidAmount;
  final String status;
  final String? paidDate;
  final String? note;
}

class ImamSalaryFormBody extends StatefulWidget {
  const ImamSalaryFormBody({
    super.key,
    required this.title,
    required this.subtitle,
    required this.initialMonth,
    required this.initialYear,
    required this.initialStatus,
    required this.isSaving,
    required this.buttonLabel,
    required this.onSubmit,
    this.initialSalaryAmount,
    this.initialPaidAmount,
    this.initialPaidDate,
    this.initialNote,
  });

  final String title;
  final String subtitle;
  final int initialMonth;
  final int initialYear;
  final double? initialSalaryAmount;
  final double? initialPaidAmount;
  final String initialStatus;
  final String? initialPaidDate;
  final String? initialNote;
  final bool isSaving;
  final String buttonLabel;
  final ValueChanged<ImamSalaryFormValue> onSubmit;

  @override
  State<ImamSalaryFormBody> createState() => _ImamSalaryFormBodyState();
}

class _ImamSalaryFormBodyState extends State<ImamSalaryFormBody> {
  final _formKey = GlobalKey<FormState>();
  late int _month = widget.initialMonth.clamp(1, 12).toInt();
  late String _status = widget.initialStatus;
  late final TextEditingController _yearController = TextEditingController(
    text: widget.initialYear.toString(),
  );
  late final TextEditingController _salaryController = TextEditingController(
    text: _initialAmountText(widget.initialSalaryAmount),
  );
  late final TextEditingController _paidController = TextEditingController(
    text: _initialAmountText(widget.initialPaidAmount ?? 0),
  );
  late final TextEditingController _paidDateController = TextEditingController(
    text: widget.initialPaidDate ?? '',
  );
  late final TextEditingController _noteController = TextEditingController(
    text: widget.initialNote ?? '',
  );

  @override
  void initState() {
    super.initState();
    _salaryController.addListener(_updateDuePreview);
    _paidController.addListener(_updateDuePreview);
  }

  @override
  void dispose() {
    _salaryController.removeListener(_updateDuePreview);
    _paidController.removeListener(_updateDuePreview);
    _yearController.dispose();
    _salaryController.dispose();
    _paidController.dispose();
    _paidDateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _updateDuePreview() => setState(() {});

  String _initialAmountText(double? amount) {
    if (amount == null || amount == 0) return '';
    return amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
  }

  double get _salaryAmount => double.tryParse(_salaryController.text.trim()) ?? 0;
  double get _paidAmount => double.tryParse(_paidController.text.trim()) ?? 0;
  double get _dueAmount => _salaryAmount - _paidAmount;

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      ImamSalaryFormValue(
        month: _month,
        year: int.parse(_yearController.text.trim()),
        salaryAmount: _salaryAmount,
        paidAmount: _paidAmount,
        status: _status,
        paidDate: _emptyToNull(_paidDateController.text),
        note: _emptyToNull(_noteController.text),
      ),
    );
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _requiredPositiveAmount(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');
    if (amount == null) return 'Enter a valid amount';
    if (amount <= 0) return 'Amount must be greater than 0';
    return null;
  }

  String? _optionalNonNegativeAmount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final amount = double.tryParse(text);
    if (amount == null) return 'Enter a valid amount';
    if (amount < 0) return 'Amount cannot be negative';
    if (amount > _salaryAmount && _salaryAmount > 0) {
      return 'Paid amount cannot be greater than salary amount';
    }
    return null;
  }

  String? _validateYear(String? value) {
    final year = int.tryParse(value?.trim() ?? '');
    if (year == null) return 'Enter a valid year';
    if (year < 2000) return 'Enter year 2000 or later';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.subtitle),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<int>(
                        value: _month,
                        decoration: const InputDecoration(labelText: 'Month *'),
                        items: List<DropdownMenuItem<int>>.generate(
                          12,
                          (index) => DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text(imamSalaryMonthNames[index]),
                          ),
                        ),
                        onChanged: widget.isSaving
                            ? null
                            : (value) => setState(() => _month = value ?? _month),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _yearController,
                        label: 'Year *',
                        hint: '2026',
                        keyboardType: TextInputType.number,
                        validator: _validateYear,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _salaryController,
                        label: 'Salary Amount *',
                        hint: '15000',
                        keyboardType: TextInputType.number,
                        validator: _requiredPositiveAmount,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _paidController,
                        label: 'Paid Amount',
                        hint: '0',
                        keyboardType: TextInputType.number,
                        validator: _optionalNonNegativeAmount,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(labelText: 'Status *'),
                        items: imamSalaryStatuses
                            .map(
                              (status) => DropdownMenuItem<String>(
                                value: status,
                                child: Text(imamSalaryStatusLabels[status]!),
                              ),
                            )
                            .toList(),
                        onChanged: widget.isSaving
                            ? null
                            : (value) => setState(() => _status = value ?? _status),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _paidDateController,
                        label: 'Paid Date',
                        hint: '2026-06-15T00:00:00.000Z',
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _noteController,
                        label: 'Note',
                        hint: 'Paid after Jumma',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Due Amount: ${formatRupees(_dueAmount)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        label: widget.buttonLabel,
                        isLoading: widget.isSaving,
                        onPressed: widget.isSaving ? null : _handleSubmit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

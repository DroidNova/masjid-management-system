import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/errors/error_message_helper.dart';
import 'package:platform_core_frontend/features/finance/data/finance_repository.dart';
import 'package:platform_core_frontend/features/finance/data/models/create_expense_request.dart';
import 'package:platform_core_frontend/features/finance/presentation/widgets/finance_labels.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/app_text_field.dart';
import 'package:platform_core_frontend/shared/widgets/app_date_field.dart';
import 'package:platform_core_frontend/shared/utils/date_format_utils.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, FinanceRepository? financeRepository})
      : _financeRepository = financeRepository;

  final FinanceRepository? _financeRepository;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _entryDate = DateTime.now();
  late final FinanceRepository _financeRepository =
      widget._financeRepository ?? FinanceRepository();

  String _selectedType = expenseTypeLabels.keys.first;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _financeRepository.createExpense(
        CreateExpenseRequest(
          type: _selectedType,
          amount: double.parse(_amountController.text.trim()),
          title: _titleController.text,
          description: _descriptionController.text,
          spentAt: formatApiDate(_entryDate),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully.')),
      );
      context.pop(true);
    } catch (error) {
      if (mounted) _showError(getReadableErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _amountValidator(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');
    if (amount == null) return 'Amount is required.';
    if (amount <= 0) return 'Amount must be greater than 0.';
    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Expense Type *',
                      ),
                      items: expenseTypeLabels.entries
                          .map(
                            (entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedType = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _amountController,
                      label: 'Amount *',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: _amountValidator,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _titleController,
                      label: 'Title',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 16),
                    AppDateField(
                      label: 'Date',
                      selectedDate: _entryDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      required: true,
                      onDateSelected: (date) => setState(() => _entryDate = date),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Save Expense',
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

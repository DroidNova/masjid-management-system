import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/features/finance/application/finance_entry_controller.dart';
import 'package:masjid_core_frontend/features/finance/data/models/create_collection_request.dart';
import 'package:masjid_core_frontend/features/finance/presentation/widgets/finance_labels.dart';
import 'package:masjid_core_frontend/shared/utils/date_format_utils.dart';
import 'package:masjid_core_frontend/shared/widgets/app_button.dart';
import 'package:masjid_core_frontend/shared/widgets/app_date_field.dart';
import 'package:masjid_core_frontend/shared/widgets/app_text_field.dart';

class AddCollectionScreen extends ConsumerStatefulWidget {
  const AddCollectionScreen({super.key});

  @override
  ConsumerState<AddCollectionScreen> createState() =>
      _AddCollectionScreenState();
}

class _AddCollectionScreenState extends ConsumerState<AddCollectionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _entryDate = DateTime.now();
  String _selectedType = collectionTypeLabels.keys.first;

  /// Last server error, shown under the matching fields.
  Object? _serverError;

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _serverError = null;
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref
        .read(financeEntryControllerProvider.notifier)
        .addCollection(
          CreateCollectionRequest(
            type: _selectedType,
            amount: double.parse(_amountController.text.trim()),
            title: _optional(_titleController.text),
            description: _optional(_descriptionController.text),
            collectedAt: formatApiDate(_entryDate),
          ),
        );
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection added successfully.')),
      );
      context.pop(true);
      return;
    }

    final error = ref.read(financeEntryControllerProvider).error;
    if (error == null) return;
    setState(() => _serverError = error);
    _formKey.currentState!.validate();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(userMessage(error))));
  }

  String? _optional(String text) => text.trim().isEmpty ? null : text.trim();

  String? _amountValidator(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');
    if (amount == null) return 'Amount is required.';
    if (amount <= 0) return 'Amount must be greater than 0.';
    return fieldError(_serverError, 'amount');
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(financeEntryControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Collection')),
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
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Collection Type *',
                      ),
                      items: collectionTypeLabels.entries
                          .map(
                            (entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
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
                      validator: (_) => fieldError(_serverError, 'title'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                      validator: (_) => fieldError(_serverError, 'description'),
                    ),
                    const SizedBox(height: 16),
                    AppDateField(
                      label: 'Date',
                      selectedDate: _entryDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      required: true,
                      onDateSelected: (date) =>
                          setState(() => _entryDate = date),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Save Collection',
                      isLoading: isSubmitting,
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

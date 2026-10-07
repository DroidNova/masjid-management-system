import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/features/projects/application/project_editor_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/create_project_request.dart';
import 'package:masjid_core_frontend/features/projects/presentation/widgets/project_status_chip.dart';
import 'package:masjid_core_frontend/shared/utils/date_format_utils.dart';
import 'package:masjid_core_frontend/shared/widgets/app_button.dart';
import 'package:masjid_core_frontend/shared/widgets/app_date_field.dart';
import 'package:masjid_core_frontend/shared/widgets/app_text_field.dart';

class AddProjectScreen extends ConsumerStatefulWidget {
  const AddProjectScreen({super.key});

  @override
  ConsumerState<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends ConsumerState<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController(text: '0');
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String _status = 'ONGOING';

  /// Last server error, shown under the matching fields.
  Object? _serverError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _serverError = null;
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref
        .read(projectEditorControllerProvider.notifier)
        .createProject(
          CreateProjectRequest(
            title: _titleController.text.trim(),
            description: _optional(_descriptionController.text),
            targetAmount: _amount(_targetAmountController),
            status: _status,
            startDate: _optional(_startDateController.text),
            endDate: _optional(_endDateController.text),
          ),
        );
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project added successfully.')),
      );
      context.pop(true);
      return;
    }

    final error = ref.read(projectEditorControllerProvider).error;
    if (error == null) return;
    setState(() => _serverError = error);
    _formKey.currentState!.validate();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(userMessage(error))));
  }

  String? _optional(String text) => text.trim().isEmpty ? null : text.trim();

  double _amount(TextEditingController controller) =>
      double.tryParse(controller.text.trim()) ?? 0;

  String? _titleValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Title is required.';
    return fieldError(_serverError, 'title');
  }

  String? _amountValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final amount = double.tryParse(text);
    if (amount == null) return 'Enter a valid amount.';
    if (amount < 0) return 'Amount cannot be negative.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(projectEditorControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Project')),
      body: ProjectFormBody(
        formKey: _formKey,
        titleController: _titleController,
        descriptionController: _descriptionController,
        targetAmountController: _targetAmountController,
        startDateController: _startDateController,
        endDateController: _endDateController,
        status: _status,
        onStatusChanged: (value) => setState(() => _status = value),
        titleValidator: _titleValidator,
        amountValidator: _amountValidator,
        buttonLabel: 'Save Project',
        isSubmitting: isSubmitting,
        onSubmit: _submit,
      ),
    );
  }
}

class ProjectFormBody extends StatelessWidget {
  const ProjectFormBody({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.targetAmountController,
    required this.startDateController,
    required this.endDateController,
    required this.status,
    required this.onStatusChanged,
    required this.titleValidator,
    required this.amountValidator,
    required this.buttonLabel,
    required this.isSubmitting,
    required this.onSubmit,
    this.onChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController targetAmountController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final String status;
  final ValueChanged<String> onStatusChanged;
  final FormFieldValidator<String> titleValidator;
  final FormFieldValidator<String> amountValidator;
  final String buttonLabel;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  /// Called when any form field changes.
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: formKey,
              onChanged: onChanged,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppTextField(
                    controller: titleController,
                    label: 'Title *',
                    validator: titleValidator,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: descriptionController,
                    label: 'Description',
                    maxLines: 3,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: targetAmountController,
                    label: 'Target Amount',
                    keyboardType: TextInputType.number,
                    validator: amountValidator,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status *'),
                    items: projectStatusLabels.entries
                        .map(
                          (entry) => DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onStatusChanged(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  AppDateField(
                    label: 'Start Date',
                    selectedDate: parseApiDate(startDateController.text),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onDateSelected: (date) {
                      startDateController.text = formatApiDate(date) ?? '';
                    },
                  ),
                  const SizedBox(height: 16),
                  AppDateField(
                    label: 'End Date',
                    selectedDate: parseApiDate(endDateController.text),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onDateSelected: (date) {
                      endDateController.text = formatApiDate(date) ?? '';
                    },
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: buttonLabel,
                    isLoading: isSubmitting,
                    onPressed: onSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

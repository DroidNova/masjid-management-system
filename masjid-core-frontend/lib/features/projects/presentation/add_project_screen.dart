import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/errors/error_message_helper.dart';
import 'package:platform_core_frontend/features/projects/data/models/create_project_request.dart';
import 'package:platform_core_frontend/features/projects/data/projects_repository.dart';
import 'package:platform_core_frontend/features/projects/presentation/widgets/project_status_chip.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/app_text_field.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key, ProjectsRepository? projectsRepository})
      : _projectsRepository = projectsRepository;

  final ProjectsRepository? _projectsRepository;

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController(text: '0');
  final _collectedAmountController = TextEditingController(text: '0');
  final _spentAmountController = TextEditingController(text: '0');
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  late final ProjectsRepository _projectsRepository =
      widget._projectsRepository ?? ProjectsRepository();

  String _status = 'ONGOING';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _collectedAmountController.dispose();
    _spentAmountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await _projectsRepository.createProject(
        CreateProjectRequest(
          title: _titleController.text,
          description: _descriptionController.text,
          targetAmount: _amount(_targetAmountController),
          collectedAmount: _amount(_collectedAmountController),
          spentAmount: _amount(_spentAmountController),
          status: _status,
          startDate: _startDateController.text,
          endDate: _endDateController.text,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project added successfully.')),
      );
      context.pop(true);
    } catch (error) {
      if (mounted) _showError(getReadableErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  double _amount(TextEditingController controller) {
    return double.tryParse(controller.text.trim()) ?? 0;
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Title is required.';
    return null;
  }

  String? _amountValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final amount = double.tryParse(text);
    if (amount == null) return 'Enter a valid amount.';
    if (amount < 0) return 'Amount cannot be negative.';
    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Project')),
      body: ProjectFormBody(
        formKey: _formKey,
        titleController: _titleController,
        descriptionController: _descriptionController,
        targetAmountController: _targetAmountController,
        collectedAmountController: _collectedAmountController,
        spentAmountController: _spentAmountController,
        startDateController: _startDateController,
        endDateController: _endDateController,
        status: _status,
        onStatusChanged: (value) => setState(() => _status = value),
        titleValidator: _required,
        amountValidator: _amountValidator,
        buttonLabel: 'Save Project',
        isSubmitting: _isSubmitting,
        onSubmit: _submit,
      ),
    );
  }
}

class ProjectFormBody extends StatelessWidget {
  const ProjectFormBody({
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.targetAmountController,
    required this.collectedAmountController,
    required this.spentAmountController,
    required this.startDateController,
    required this.endDateController,
    required this.status,
    required this.onStatusChanged,
    required this.titleValidator,
    required this.amountValidator,
    required this.buttonLabel,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController targetAmountController;
  final TextEditingController collectedAmountController;
  final TextEditingController spentAmountController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final String status;
  final ValueChanged<String> onStatusChanged;
  final FormFieldValidator<String> titleValidator;
  final FormFieldValidator<String> amountValidator;
  final String buttonLabel;
  final bool isSubmitting;
  final VoidCallback onSubmit;

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
                  AppTextField(
                    controller: collectedAmountController,
                    label: 'Collected Amount',
                    keyboardType: TextInputType.number,
                    validator: amountValidator,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: spentAmountController,
                    label: 'Spent Amount',
                    keyboardType: TextInputType.number,
                    validator: amountValidator,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: status,
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
                  AppTextField(
                    controller: startDateController,
                    label: 'Start Date',
                    hint: 'YYYY-MM-DD or leave empty',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: endDateController,
                    label: 'End Date',
                    hint: 'YYYY-MM-DD or leave empty',
                    textInputAction: TextInputAction.done,
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

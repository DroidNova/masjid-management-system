import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/features/projects/data/models/project_model.dart';
import 'package:platform_core_frontend/features/projects/data/models/update_project_request.dart';
import 'package:platform_core_frontend/features/projects/data/projects_repository.dart';
import 'package:platform_core_frontend/features/projects/presentation/add_project_screen.dart';

class EditProjectScreen extends StatefulWidget {
  const EditProjectScreen({
    super.key,
    required this.projectId,
    this.initialProject,
    ProjectsRepository? projectsRepository,
  }) : _projectsRepository = projectsRepository;

  final String projectId;
  final ProjectModel? initialProject;
  final ProjectsRepository? _projectsRepository;

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _collectedAmountController = TextEditingController();
  final _spentAmountController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  late final ProjectsRepository _projectsRepository =
      widget._projectsRepository ?? ProjectsRepository();

  String _status = 'ONGOING';
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

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

  Future<void> _loadProject() async {
    try {
      final project = widget.initialProject ??
          await _projectsRepository.getProjectById(widget.projectId);
      if (!mounted) return;
      _fill(project);
      setState(() => _isLoading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _cleanError(error);
        _isLoading = false;
      });
    }
  }

  void _fill(ProjectModel project) {
    _titleController.text = project.title;
    _descriptionController.text = project.description ?? '';
    _targetAmountController.text = project.targetAmount.toString();
    _collectedAmountController.text = project.collectedAmount.toString();
    _spentAmountController.text = project.spentAmount.toString();
    _startDateController.text = project.startDate ?? '';
    _endDateController.text = project.endDate ?? '';
    _status = project.status;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await _projectsRepository.updateProject(
        widget.projectId,
        UpdateProjectRequest(
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
        const SnackBar(content: Text('Project updated successfully.')),
      );
      context.pop(true);
    } catch (error) {
      if (mounted) _showError(_cleanError(error));
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

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Project')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Project')),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Project')),
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
        buttonLabel: 'Update Project',
        isSubmitting: _isSubmitting,
        onSubmit: _submit,
      ),
    );
  }
}

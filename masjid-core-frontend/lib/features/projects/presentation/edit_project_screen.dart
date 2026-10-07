import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/features/projects/application/project_detail_controller.dart';
import 'package:masjid_core_frontend/features/projects/application/project_editor_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/data/models/update_project_request.dart';
import 'package:masjid_core_frontend/features/projects/presentation/add_project_screen.dart';
import 'package:masjid_core_frontend/shared/utils/date_format_utils.dart';
import 'package:masjid_core_frontend/shared/widgets/app_button.dart';

class EditProjectScreen extends ConsumerStatefulWidget {
  const EditProjectScreen({
    super.key,
    required this.projectId,
    this.initialProject,
  });

  final String projectId;

  /// From the previous screen (route `extra`): fills the form instantly;
  /// replaced by the loaded project unless the user already started editing.
  final ProjectModel? initialProject;

  @override
  ConsumerState<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends ConsumerState<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String _status = 'ONGOING';
  bool _isFilled = false;
  bool _isFilledFromServer = false;
  bool _userEdited = false;
  bool _initialized = false;

  /// Bumped on every fill so the status dropdown picks up the new value.
  int _formVersion = 0;

  /// Last server error, shown under the matching fields.
  Object? _serverError;

  @override
  void initState() {
    super.initState();
    final preview = widget.initialProject;
    if (preview != null && preview.id == widget.projectId) _fill(preview);

    ref.listenManual<AsyncValue<ProjectModel>>(
      projectDetailProvider(widget.projectId),
      (previous, next) {
        final project = next.valueOrNull;
        if (project == null || _isFilledFromServer || _userEdited) return;
        _fill(project);
        _isFilledFromServer = true;
        if (_initialized && mounted) setState(() {});
      },
      fireImmediately: true,
    );
    _initialized = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _fill(ProjectModel project) {
    _titleController.text = project.title;
    _descriptionController.text = project.description ?? '';
    _targetAmountController.text = _amountText(project.targetAmount);
    _startDateController.text = formatApiDate(project.startDate) ?? '';
    _endDateController.text = formatApiDate(project.endDate) ?? '';
    _status = project.status;
    _isFilled = true;
    _formVersion++;
  }

  /// 2500 rather than 2500.0; paise kept when present.
  String _amountText(double amount) => amount == amount.roundToDouble()
      ? amount.toStringAsFixed(0)
      : amount.toString();

  Future<void> _submit() async {
    _serverError = null;
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref
        .read(projectEditorControllerProvider.notifier)
        .updateProject(
          widget.projectId,
          UpdateProjectRequest(
            title: _optional(_titleController.text),
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
        const SnackBar(content: Text('Project updated successfully.')),
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
    final projectState = ref.watch(projectDetailProvider(widget.projectId));
    final isSubmitting = ref.watch(projectEditorControllerProvider).isLoading;

    final Widget body;
    if (projectState.hasError && !_isFilledFromServer) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                userMessage(projectState.error!),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Retry',
                onPressed: () =>
                    ref.invalidate(projectDetailProvider(widget.projectId)),
              ),
            ],
          ),
        ),
      );
    } else if (!_isFilled) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = KeyedSubtree(
        key: ValueKey<int>(_formVersion),
        child: ProjectFormBody(
          formKey: _formKey,
          titleController: _titleController,
          descriptionController: _descriptionController,
          targetAmountController: _targetAmountController,
          startDateController: _startDateController,
          endDateController: _endDateController,
          status: _status,
          onStatusChanged: (value) => setState(() {
            _status = value;
            _userEdited = true;
          }),
          onChanged: () => _userEdited = true,
          titleValidator: _titleValidator,
          amountValidator: _amountValidator,
          buttonLabel: 'Update Project',
          isSubmitting: isSubmitting,
          onSubmit: _submit,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Project')),
      body: body,
    );
  }
}

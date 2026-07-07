import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/features/imam_salary/data/imam_salary_repository.dart';
import 'package:platform_core_frontend/features/imam_salary/models/imam_salary_model.dart';
import 'package:platform_core_frontend/features/imam_salary/models/update_imam_salary_request.dart';
import 'package:platform_core_frontend/features/imam_salary/presentation/add_imam_salary_screen.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';

class EditImamSalaryScreen extends StatefulWidget {
  const EditImamSalaryScreen({
    super.key,
    required this.salaryId,
    this.initialSalary,
    ImamSalaryRepository? imamSalaryRepository,
  }) : _imamSalaryRepository = imamSalaryRepository;

  final String salaryId;
  final ImamSalaryModel? initialSalary;
  final ImamSalaryRepository? _imamSalaryRepository;

  @override
  State<EditImamSalaryScreen> createState() => _EditImamSalaryScreenState();
}

class _EditImamSalaryScreenState extends State<EditImamSalaryScreen> {
  late final ImamSalaryRepository _repository =
      widget._imamSalaryRepository ?? ImamSalaryRepository();
  ImamSalaryModel? _salary;
  String? _errorMessage;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _salary = widget.initialSalary;
    _loadSalaryIfNeeded();
  }

  Future<void> _loadSalaryIfNeeded() async {
    if (_salary != null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final salary = await _repository.getImamSalaryById(widget.salaryId);
      if (!mounted) return;
      setState(() => _salary = salary);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _cleanError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit(ImamSalaryFormValue value) async {
    setState(() => _isSaving = true);
    try {
      await _repository.updateImamSalary(
        widget.salaryId,
        UpdateImamSalaryRequest(
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
        const SnackBar(content: Text('Salary record updated successfully.')),
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
    if (_isLoading) return const LoadingView();

    if (_salary == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Salary')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(_errorMessage ?? 'Salary record not found.'),
                const SizedBox(height: 12),
                AppButton(label: 'Back', onPressed: () => context.pop()),
              ],
            ),
          ),
        ),
      );
    }

    final salary = _salary!;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Salary')),
      body: ImamSalaryFormBody(
        title: 'Edit Salary Record',
        subtitle: 'Update monthly salary payment details',
        initialMonth: salary.month == 0 ? DateTime.now().month : salary.month,
        initialYear: salary.year == 0 ? DateTime.now().year : salary.year,
        initialSalaryAmount: salary.salaryAmount,
        initialPaidAmount: salary.paidAmount,
        initialStatus: imamSalaryStatuses.contains(salary.status)
            ? salary.status
            : 'UNPAID',
        initialPaidDate: salary.paidDate,
        initialNote: salary.note,
        isSaving: _isSaving,
        buttonLabel: 'Update Salary',
        onSubmit: _submit,
      ),
    );
  }
}

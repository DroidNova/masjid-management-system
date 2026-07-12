import 'package:flutter/material.dart';
import 'package:platform_core_frontend/shared/utils/date_format_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/permissions/permission_helper.dart';
import 'package:platform_core_frontend/core/storage/session_storage.dart';
import 'package:platform_core_frontend/features/finance/presentation/widgets/finance_labels.dart';
import 'package:platform_core_frontend/features/imam_salary/data/imam_salary_repository.dart';
import 'package:platform_core_frontend/features/imam_salary/models/imam_salary_model.dart';
import 'package:platform_core_frontend/features/imam_salary/presentation/widgets/imam_salary_status_chip.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';

class ImamSalaryDetailScreen extends StatefulWidget {
  const ImamSalaryDetailScreen({
    super.key,
    required this.salaryId,
    this.initialSalary,
    ImamSalaryRepository? imamSalaryRepository,
    SessionStorage? sessionStorage,
  })  : _imamSalaryRepository = imamSalaryRepository,
        _sessionStorage = sessionStorage;

  final String salaryId;
  final ImamSalaryModel? initialSalary;
  final ImamSalaryRepository? _imamSalaryRepository;
  final SessionStorage? _sessionStorage;

  @override
  State<ImamSalaryDetailScreen> createState() => _ImamSalaryDetailScreenState();
}

class _ImamSalaryDetailScreenState extends State<ImamSalaryDetailScreen> {
  late final ImamSalaryRepository _imamSalaryRepository =
      widget._imamSalaryRepository ?? ImamSalaryRepository();
  late final SessionStorage _sessionStorage =
      widget._sessionStorage ?? SessionStorage();

  ImamSalaryModel? _salary;
  String? _errorMessage;
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _canManageImamSalary = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
    if (widget.initialSalary != null) {
      _salary = widget.initialSalary;
      _isLoading = false;
    }
    _loadSalary();
  }

  Future<void> _loadPermissions() async {
    final user = await _sessionStorage.getUser();
    if (!mounted) return;
    setState(() {
      _canManageImamSalary = PermissionHelper.canManageImamSalary(
        user?.roles ?? const <String>[],
      );
    });
  }

  Future<void> _loadSalary() async {
    setState(() {
      _isLoading = _salary == null;
      _errorMessage = null;
    });
    try {
      final salary = await _imamSalaryRepository.getImamSalaryById(
        widget.salaryId,
      );
      if (!mounted) return;
      setState(() => _salary = salary);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _cleanError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openEdit(ImamSalaryModel salary) async {
    await context.push<bool>(
      '/imam-salaries/${salary.id}/edit',
      extra: salary,
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Salary Record'),
        content: const Text(
          'Are you sure you want to delete this salary record?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) await _deleteSalary();
  }

  Future<void> _deleteSalary() async {
    setState(() => _isDeleting = true);
    try {
      await _imamSalaryRepository.deleteImamSalary(widget.salaryId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salary record deleted successfully.')),
      );
      context.pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_cleanError(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Salary Detail')),
        body: const LoadingView(),
      );
    }

    if (_errorMessage != null || _salary == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Salary Detail')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  _errorMessage ?? 'Unable to load salary record.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                AppButton(label: 'Retry', onPressed: _loadSalary),
              ],
            ),
          ),
        ),
      );
    }

    final salary = _salary!;
    return Scaffold(
      appBar: AppBar(title: const Text('Salary Detail')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '${salary.monthName} ${salary.year}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              ImamSalaryStatusChip(status: salary.status),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(
                            label: 'Salary Amount',
                            value: formatRupees(salary.salaryAmount),
                          ),
                          _DetailRow(
                            label: 'Paid Amount',
                            value: formatRupees(salary.paidAmount),
                          ),
                          _DetailRow(
                            label: 'Due Amount',
                            value: formatRupees(salary.dueAmount),
                          ),
                          _DetailRow(
                            label: 'Paid Date',
                            value: formatReadableDate(parseApiDate(salary.paidDate)),
                          ),
                          _DetailRow(
                            label: 'Note',
                            value: salary.note ?? 'Not added',
                          ),
                          if (salary.imamName != null) ...<Widget>[
                            const Divider(height: 28),
                            _DetailRow(label: 'Imam', value: salary.imamName!),
                            if (salary.imamPhone != null)
                              _DetailRow(
                                label: 'Phone',
                                value: salary.imamPhone!,
                              ),
                            if (salary.imamEmail != null)
                              _DetailRow(
                                label: 'Email',
                                value: salary.imamEmail!,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (_canManageImamSalary) ...<Widget>[
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Edit',
                      onPressed: () => _openEdit(salary),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Delete',
                      isOutlined: true,
                      isLoading: _isDeleting,
                      onPressed: _confirmDelete,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

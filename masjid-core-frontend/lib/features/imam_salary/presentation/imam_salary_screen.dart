import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/permissions/permission_helper.dart';
import 'package:platform_core_frontend/core/refresh/app_data_refresh_bus.dart';
import 'package:platform_core_frontend/core/storage/session_storage.dart';
import 'package:platform_core_frontend/features/auth/data/auth_repository.dart';
import 'package:platform_core_frontend/features/auth/data/models/app_user.dart';
import 'package:platform_core_frontend/features/finance/presentation/widgets/finance_labels.dart';
import 'package:platform_core_frontend/features/imam_salary/data/imam_salary_repository.dart';
import 'package:platform_core_frontend/features/imam_salary/models/imam_salary_model.dart';
import 'package:platform_core_frontend/features/imam_salary/presentation/widgets/imam_salary_card.dart';
import 'package:platform_core_frontend/features/imam_salary/presentation/widgets/imam_salary_empty_view.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';

class ImamSalaryScreen extends StatefulWidget {
  const ImamSalaryScreen({
    super.key,
    ImamSalaryRepository? imamSalaryRepository,
    AuthRepository? authRepository,
    SessionStorage? sessionStorage,
  })  : _imamSalaryRepository = imamSalaryRepository,
        _authRepository = authRepository,
        _sessionStorage = sessionStorage;

  final ImamSalaryRepository? _imamSalaryRepository;
  final AuthRepository? _authRepository;
  final SessionStorage? _sessionStorage;

  @override
  State<ImamSalaryScreen> createState() => _ImamSalaryScreenState();
}

class _ImamSalaryScreenState extends State<ImamSalaryScreen> {
  late final ImamSalaryRepository _imamSalaryRepository =
      widget._imamSalaryRepository ?? ImamSalaryRepository();
  late final AuthRepository _authRepository =
      widget._authRepository ?? AuthRepository();
  late final SessionStorage _sessionStorage =
      widget._sessionStorage ?? SessionStorage();

  List<ImamSalaryModel> _records = <ImamSalaryModel>[];
  String? _errorMessage;
  bool _isLoading = true;
  bool _hasLoaded = false;
  Future<void>? _activeLoad;
  late final ValueNotifier<int> _refreshNotifier;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _refreshNotifier =
        AppDataRefreshBus.instance.notifierFor(AppDataScope.imamSalary);
    _refreshNotifier.addListener(_onRefreshRequested);
    _loadCurrentUser();
    _loadRecords();
  }

  @override
  void dispose() {
    _refreshNotifier.removeListener(_onRefreshRequested);
    super.dispose();
  }

  void _onRefreshRequested() {
    _loadRecords(force: true);
  }

  Future<void> _loadCurrentUser() async {
    final user = await _sessionStorage.getUser();
    if (!mounted) return;
    setState(() => _currentUser = user);
  }

  Future<void> _loadRecords({bool force = false}) {
    final activeLoad = _activeLoad;
    if (activeLoad != null) return activeLoad;
    if (!force && _hasLoaded) return Future<void>.value();

    _activeLoad = _performLoadRecords().whenComplete(() {
      _activeLoad = null;
    });
    return _activeLoad!;
  }

  Future<void> _performLoadRecords() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final records = await _imamSalaryRepository.getImamSalaries();
      records.sort((a, b) {
        final yearCompare = b.year.compareTo(a.year);
        if (yearCompare != 0) return yearCompare;
        return b.month.compareTo(a.month);
      });
      if (!mounted) return;
      setState(() {
        _records = records;
        _hasLoaded = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _cleanError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openAddSalary() async {
    await context.push('/imam-salaries/add');
  }

  Future<void> _openDetail(ImamSalaryModel record) async {
    await context.push('/imam-salaries/${record.id}', extra: record);
  }

  Future<void> _logout() async {
    await _authRepository.logout();
    if (!mounted) return;
    context.go('/auth');
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  bool get _isUnauthorizedError {
    final message = _errorMessage?.toLowerCase() ?? '';
    return message.contains('unauthorized') ||
        message.contains('session') ||
        message.contains('401');
  }

  bool get _isNoMasjidError {
    final message = _errorMessage?.toLowerCase() ?? '';
    return message.contains('not assigned') || message.contains('masjid');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Imam Salary')),
        body: const LoadingView(),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Imam Salary')),
        body: _ImamSalaryErrorView(
          message: _isUnauthorizedError
              ? 'Session expired. Please login again.'
              : _isNoMasjidError
                  ? 'You are not assigned to any masjid yet.'
                  : 'Unable to load imam salary records.',
          detail: _isUnauthorizedError || _isNoMasjidError ? null : _errorMessage,
          buttonLabel: _isUnauthorizedError ? 'Back to Login' : 'Retry',
          onPressed: _isUnauthorizedError ? _logout : () => _loadRecords(force: true),
        ),
      );
    }

    final totalSalary = _records.fold<double>(
      0,
      (sum, record) => sum + record.salaryAmount,
    );
    final totalPaid = _records.fold<double>(
      0,
      (sum, record) => sum + record.paidAmount,
    );
    final totalDue = _records.fold<double>(
      0,
      (sum, record) => sum + record.dueAmount,
    );

    final canManageImamSalary = PermissionHelper.canManageImamSalary(
      _currentUser?.roles ?? const <String>[],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Imam Salary')),
      body: RefreshIndicator(
        onRefresh: () => _loadRecords(force: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Imam Salary',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage monthly salary records',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    _SalaryTotalsCard(
                      totalSalary: totalSalary,
                      totalPaid: totalPaid,
                      totalDue: totalDue,
                    ),
                    const SizedBox(height: 12),
                    if (canManageImamSalary) ...<Widget>[
                      AppButton(
                        label: 'Add Salary',
                        onPressed: _openAddSalary,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_records.isEmpty)
                      const ImamSalaryEmptyView()
                    else
                      ..._records.map(
                        (record) => ImamSalaryCard(
                          salary: record,
                          onTap: () => _openDetail(record),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalaryTotalsCard extends StatelessWidget {
  const _SalaryTotalsCard({
    required this.totalSalary,
    required this.totalPaid,
    required this.totalDue,
  });

  final double totalSalary;
  final double totalPaid;
  final double totalDue;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _TotalRow(label: 'Total Salary', value: formatRupees(totalSalary)),
            _TotalRow(label: 'Total Paid', value: formatRupees(totalPaid)),
            _TotalRow(label: 'Total Due', value: formatRupees(totalDue)),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ImamSalaryErrorView extends StatelessWidget {
  const _ImamSalaryErrorView({
    required this.message,
    required this.onPressed,
    this.detail,
    this.buttonLabel = 'Retry',
  });

  final String message;
  final String? detail;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(
                Icons.payments_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (detail != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(detail!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 20),
              AppButton(label: buttonLabel, onPressed: onPressed),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/permissions/permission_helper.dart';
import 'package:platform_core_frontend/core/refresh/app_data_refresh_bus.dart';
import 'package:platform_core_frontend/core/storage/session_storage.dart';
import 'package:platform_core_frontend/features/auth/data/auth_repository.dart';
import 'package:platform_core_frontend/features/auth/data/models/app_user.dart';
import 'package:platform_core_frontend/features/finance/data/finance_repository.dart';
import 'package:platform_core_frontend/features/finance/data/models/collection_entry_model.dart';
import 'package:platform_core_frontend/features/finance/data/models/expense_entry_model.dart';
import 'package:platform_core_frontend/features/finance/data/models/finance_summary_model.dart';
import 'package:platform_core_frontend/features/finance/presentation/widgets/finance_empty_view.dart';
import 'package:platform_core_frontend/features/finance/presentation/widgets/finance_entry_tile.dart';
import 'package:platform_core_frontend/features/finance/presentation/widgets/finance_summary_card.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({
    super.key,
    FinanceRepository? financeRepository,
    AuthRepository? authRepository,
    SessionStorage? sessionStorage,
  })  : _financeRepository = financeRepository,
        _authRepository = authRepository,
        _sessionStorage = sessionStorage;

  final FinanceRepository? _financeRepository;
  final AuthRepository? _authRepository;
  final SessionStorage? _sessionStorage;

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  late final FinanceRepository _financeRepository =
      widget._financeRepository ?? FinanceRepository();
  late final AuthRepository _authRepository =
      widget._authRepository ?? AuthRepository();
  late final SessionStorage _sessionStorage =
      widget._sessionStorage ?? SessionStorage();

  FinanceSummaryModel _summary = FinanceSummaryModel.empty();
  List<CollectionEntryModel> _collections = <CollectionEntryModel>[];
  List<ExpenseEntryModel> _expenses = <ExpenseEntryModel>[];
  String? _errorMessage;
  bool _isLoading = true;
  bool _hasLoaded = false;
  Future<void>? _activeLoad;
  late final ValueNotifier<int> _refreshNotifier;
  int _selectedTab = 0;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _refreshNotifier =
        AppDataRefreshBus.instance.notifierFor(AppDataScope.finance);
    _refreshNotifier.addListener(_onRefreshRequested);
    _loadCurrentUser();
    _loadFinanceData();
  }

  @override
  void dispose() {
    _refreshNotifier.removeListener(_onRefreshRequested);
    super.dispose();
  }

  void _onRefreshRequested() {
    _loadFinanceData(force: true);
  }

  Future<void> _loadCurrentUser() async {
    final user = await _sessionStorage.getUser();
    if (!mounted) return;
    setState(() => _currentUser = user);
  }

  Future<void> _loadFinanceData({bool force = false}) {
    final activeLoad = _activeLoad;
    if (activeLoad != null) return activeLoad;
    if (!force && _hasLoaded) return Future<void>.value();

    _activeLoad = _performLoadFinanceData().whenComplete(() {
      _activeLoad = null;
    });
    return _activeLoad!;
  }

  Future<void> _performLoadFinanceData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait<Object>([
        _financeRepository.getFinanceSummary(),
        _financeRepository.getCollections(),
        _financeRepository.getExpenses(),
      ]);

      if (!mounted) return;

      setState(() {
        _summary = results[0] as FinanceSummaryModel;
        _collections = results[1] as List<CollectionEntryModel>;
        _expenses = results[2] as List<ExpenseEntryModel>;
        _hasLoaded = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _cleanError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openAddCollection() async {
    await context.push('/finance/add-collection');
  }

  Future<void> _openAddExpense() async {
    await context.push('/finance/add-expense');
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
    if (_isLoading) return const LoadingView();

    if (_errorMessage != null) {
      if (_isUnauthorizedError) {
        return _FinanceErrorView(
          message: 'Session expired. Please login again.',
          buttonLabel: 'Back to Login',
          onPressed: _logout,
        );
      }

      return _FinanceErrorView(
        message: _isNoMasjidError
            ? 'You are not assigned to any masjid yet.'
            : 'Unable to load finance data.',
        detail: _isNoMasjidError ? null : _errorMessage,
        onPressed: () => _loadFinanceData(force: true),
      );
    }

    final roles = _currentUser?.roles ?? const <String>[];
    final canManageFinance = PermissionHelper.canManageFinance(roles);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => _loadFinanceData(force: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FinanceSummaryCard(summary: _summary),
                  const SizedBox(height: 12),
                  _ImamSalaryNavigationCard(
                    subtitle: PermissionHelper.canManageImamSalary(roles)
                        ? 'Manage salary paid/unpaid records'
                        : 'View salary paid/unpaid records',
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<int>(
                    segments: const <ButtonSegment<int>>[
                      ButtonSegment<int>(
                        value: 0,
                        label: Text('Collections'),
                      ),
                      ButtonSegment<int>(
                        value: 1,
                        label: Text('Expenses'),
                      ),
                    ],
                    selected: <int>{_selectedTab},
                    onSelectionChanged: (selection) {
                      setState(() => _selectedTab = selection.first);
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_selectedTab == 0)
                    _FinanceEntriesSection(
                      title: 'Collections',
                      buttonLabel: 'Add Collection',
                      onAddPressed: canManageFinance ? _openAddCollection : null,
                      emptyMessage: 'No collections added yet.',
                      children: _collections
                          .map(
                            (entry) => FinanceEntryTile(
                              type: entry.type,
                              amount: entry.amount,
                              title: entry.title,
                              description: entry.description,
                              date: entry.collectedAt ?? entry.createdAt,
                              status: entry.status,
                              auditInfo: entry.auditInfo,
                              isExpense: false,
                            ),
                          )
                          .toList(),
                    )
                  else
                    _FinanceEntriesSection(
                      title: 'Expenses',
                      buttonLabel: 'Add Expense',
                      onAddPressed: canManageFinance ? _openAddExpense : null,
                      emptyMessage: 'No expenses added yet.',
                      children: _expenses
                          .map(
                            (entry) => FinanceEntryTile(
                              type: entry.type,
                              amount: entry.amount,
                              title: entry.title,
                              description: entry.description,
                              date: entry.spentAt ?? entry.createdAt,
                              status: entry.status,
                              auditInfo: entry.auditInfo,
                              isExpense: true,
                            ),
                          )
                          .toList(),
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


class _ImamSalaryNavigationCard extends StatelessWidget {
  const _ImamSalaryNavigationCard({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/imam-salaries'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.payments_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Imam Salary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinanceEntriesSection extends StatelessWidget {
  const _FinanceEntriesSection({
    required this.title,
    required this.buttonLabel,
    this.onAddPressed,
    required this.emptyMessage,
    required this.children,
  });

  final String title;
  final String buttonLabel;
  final VoidCallback? onAddPressed;
  final String emptyMessage;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (onAddPressed != null)
                  FilledButton(
                    onPressed: onAddPressed,
                    child: Text(buttonLabel),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (children.isEmpty) FinanceEmptyView(message: emptyMessage),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _FinanceErrorView extends StatelessWidget {
  const _FinanceErrorView({
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
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.account_balance_wallet_outlined,
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
      ),
    );
  }
}

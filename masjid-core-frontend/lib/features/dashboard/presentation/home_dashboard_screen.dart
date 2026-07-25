import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/permissions/permission_helper.dart';
import 'package:platform_core_frontend/core/refresh/app_data_refresh_bus.dart';
import 'package:platform_core_frontend/core/storage/session_storage.dart';
import 'package:platform_core_frontend/features/auth/data/auth_repository.dart';
import 'package:platform_core_frontend/features/auth/data/models/app_user.dart';
import 'package:platform_core_frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:platform_core_frontend/features/dashboard/presentation/widgets/announcement_preview_card.dart';
import 'package:platform_core_frontend/features/dashboard/presentation/widgets/finance_summary_card.dart';
import 'package:platform_core_frontend/features/dashboard/presentation/widgets/imam_salary_card.dart';
import 'package:platform_core_frontend/features/dashboard/presentation/widgets/masjid_header_card.dart';
import 'package:platform_core_frontend/features/dashboard/presentation/widgets/namaz_time_card.dart';
import 'package:platform_core_frontend/features/dashboard/presentation/widgets/project_summary_card.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    super.key,
    DashboardRepository? dashboardRepository,
    AuthRepository? authRepository,
    SessionStorage? sessionStorage,
  })  : _dashboardRepository = dashboardRepository,
        _authRepository = authRepository,
        _sessionStorage = sessionStorage;

  final DashboardRepository? _dashboardRepository;
  final AuthRepository? _authRepository;
  final SessionStorage? _sessionStorage;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  late final DashboardRepository _dashboardRepository =
      widget._dashboardRepository ?? DashboardRepository();
  late final AuthRepository _authRepository =
      widget._authRepository ?? AuthRepository();
  late final SessionStorage _sessionStorage =
      widget._sessionStorage ?? SessionStorage();

  DashboardResponse? _dashboard;
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
        AppDataRefreshBus.instance.notifierFor(AppDataScope.dashboard);
    _refreshNotifier.addListener(_onRefreshRequested);
    _loadCurrentUser();
    _loadDashboard();
  }

  @override
  void dispose() {
    _refreshNotifier.removeListener(_onRefreshRequested);
    super.dispose();
  }

  void _onRefreshRequested() {
    _loadDashboard(force: true);
  }

  Future<void> _loadCurrentUser() async {
    final user = await _sessionStorage.getUser();
    if (!mounted) return;
    setState(() => _currentUser = user);
  }

  Future<void> _loadDashboard({bool force = false}) {
    final activeLoad = _activeLoad;
    if (activeLoad != null) return activeLoad;
    if (!force && _hasLoaded) return Future<void>.value();

    _activeLoad = _performLoadDashboard().whenComplete(() {
      _activeLoad = null;
    });
    return _activeLoad!;
  }

  Future<void> _performLoadDashboard() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dashboard = await _dashboardRepository.getMyMasjidDashboard();
      if (!mounted) return;
      setState(() {
        _dashboard = dashboard;
        _hasLoaded = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _cleanError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authRepository.logout();
    if (!mounted) return;
    context.go('/auth');
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  bool get _isNoMasjidError {
    final message = _errorMessage?.toLowerCase() ?? '';
    return message.contains('masjid') ||
        message.contains('forbidden') ||
        message.contains('not assigned');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingView();
    }

    if (_errorMessage != null) {
      return _DashboardErrorView(
        message: _isNoMasjidError
            ? 'You are not assigned to any masjid yet.'
            : 'Unable to load dashboard',
        detail: _isNoMasjidError ? null : _errorMessage,
        primaryButtonLabel: _isNoMasjidError ? 'Logout / Back to Login' : 'Retry',
        onPrimaryPressed: _isNoMasjidError ? _logout : () => _loadDashboard(force: true),
      );
    }

    final dashboard = _dashboard;
    final roles = _currentUser?.roles ?? const <String>[];
    final canUpdateNamazTime = PermissionHelper.canUpdateNamazTime(roles);
    final canManageAnnouncements = PermissionHelper.canManageAnnouncements(roles);
    final canManageFinance = PermissionHelper.canManageFinance(roles);
    final canManageProjects = PermissionHelper.canManageProjects(roles);
    final canViewContributions = PermissionHelper.hasRoleInList(roles, PermissionHelper.member) ||
        PermissionHelper.hasRoleInList(roles, PermissionHelper.committeeMember) ||
        PermissionHelper.hasRoleInList(roles, PermissionHelper.masjidAdmin);
    if (dashboard == null) {
      return _DashboardErrorView(
        message: 'Unable to load dashboard',
        onPrimaryPressed: () => _loadDashboard(force: true),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => _loadDashboard(force: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  MasjidHeaderCard(
                    masjid: dashboard.masjid,
                    imam: dashboard.imam,
                    membersCount: dashboard.membersCount,
                  ),
                  const SizedBox(height: 12),
                  NamazTimeCard(namazTime: dashboard.namazTime),
                  if (canUpdateNamazTime) ...<Widget>[
                    const SizedBox(height: 8),
                    AppButton(
                      label: 'Update Namaz Time',
                      isOutlined: true,
                      onPressed: () async {
                        await context.push(
                          '/namaz-time/update',
                          extra: <String, dynamic>{
                            'masjidId': dashboard.masjid?.id,
                          },
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  AnnouncementPreviewCard(
                    announcements: dashboard.latestAnnouncements,
                    onViewAll: () => context.push('/announcements'),
                    onAddAnnouncement: canManageAnnouncements
                        ? () => context.push('/announcements/add')
                        : null,
                  ),
                  const SizedBox(height: 12),
                  FinanceSummaryCard(
                    financeSummary: dashboard.financeSummary,
                  ),
                  if (canManageFinance) ...<Widget>[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        FilledButton.icon(
                          onPressed: () => context.push('/finance/add-collection'),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Collection'),
                        ),
                        FilledButton.icon(
                          onPressed: () => context.push('/finance/add-expense'),
                          icon: const Icon(Icons.remove),
                          label: const Text('Add Expense'),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  ProjectSummaryCard(
                    projectsSummary: dashboard.projectsSummary,
                  ),
                  if (canManageProjects) ...<Widget>[
                    const SizedBox(height: 8),
                    AppButton(
                      label: 'Add Project',
                      isOutlined: true,
                      onPressed: () => context.push('/projects/add'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ImamSalaryCard(
                    salarySummary: dashboard.imamSalarySummary,
                  ),
                  if (canViewContributions) ...<Widget>[
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.volunteer_activism_outlined),
                        title: const Text('My Contributions'),
                        subtitle: const Text(
                          'View your imam salary and donation history',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/contributions'),
                      ),
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

class _DashboardErrorView extends StatelessWidget {
  const _DashboardErrorView({
    required this.message,
    required this.onPrimaryPressed,
    this.detail,
    this.primaryButtonLabel = 'Retry',
  });

  final String message;
  final String? detail;
  final String primaryButtonLabel;
  final VoidCallback onPrimaryPressed;

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
                  Icons.info_outline,
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
                  Text(
                    detail!,
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),
                AppButton(
                  label: primaryButtonLabel,
                  onPressed: onPrimaryPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

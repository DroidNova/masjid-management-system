import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:platform_core_frontend/core/refresh/app_data_refresh_bus.dart';
import 'package:platform_core_frontend/features/super_admin/data/super_admin_repository.dart';
import 'package:platform_core_frontend/features/super_admin/models/admin_dashboard_summary.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/super_admin_tab_controller.dart';
import 'package:platform_core_frontend/shared/widgets/error_view.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key, this.repository});

  final SuperAdminRepository? repository;

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  late final SuperAdminRepository _repository =
      widget.repository ?? SuperAdminRepository();
  late final ValueNotifier<int> _refreshNotifier;
  AdminDashboardSummary _summary = const AdminDashboardSummary();
  Future<void>? _activeLoad;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _refreshNotifier =
        AppDataRefreshBus.instance.notifierFor(AppDataScope.adminDashboard);
    _refreshNotifier.addListener(_onRefreshRequested);
    _loadData();
  }

  @override
  void dispose() {
    _refreshNotifier.removeListener(_onRefreshRequested);
    super.dispose();
  }

  void _onRefreshRequested() {
    _loadData(force: true);
  }

  Future<void> _loadData({bool force = false}) {
    final activeLoad = _activeLoad;
    if (activeLoad != null && !force) return activeLoad;
    _activeLoad = _performLoad().whenComplete(() {
      _activeLoad = null;
    });
    return _activeLoad!;
  }

  Future<void> _performLoad() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final summary = await _repository.getDashboardSummary();
      if (!mounted) return;
      setState(() => _summary = summary);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingView();
    if (_errorMessage != null) {
      return ErrorView(
        title: 'Unable to load',
        message: _errorMessage!,
        onRetry: () => _loadData(force: true),
      );
    }

    final dashboard = _summary;
    return RefreshIndicator(
      onRefresh: () => _loadData(force: true),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _card('Total Users', dashboard.totalUsers),
              _card('Active Users', dashboard.activeUsers),
              _card(
                'Inactive Users',
                dashboard.inactiveUsers + dashboard.suspendedUsers,
              ),
              _card('Total Masjids', dashboard.totalMasjids),
              _card('Pending Requests', dashboard.pendingRequests),
              _card('Approved Requests', dashboard.approvedRequests),
              _card('Rejected Requests', dashboard.rejectedRequests),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              FilledButton(
                onPressed: () => selectSuperAdminTab(context, 1),
                child: const Text('Masjid Requests'),
              ),
              FilledButton(
                onPressed: () => selectSuperAdminTab(context, 2),
                child: const Text('Masjids'),
              ),
              FilledButton(
                onPressed: () => selectSuperAdminTab(context, 3),
                child: const Text('Users'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(String title, int value) {
    return SizedBox(
      width: 190,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/super_admin/data/super_admin_repository.dart';
import 'package:platform_core_frontend/features/super_admin/models/admin_user_model.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/users/widgets/admin_user_card.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/users/widgets/update_user_status_dialog.dart';
import 'package:platform_core_frontend/shared/widgets/error_view.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key, this.repository});

  final SuperAdminRepository? repository;

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  static const int _pageLimit = 20;

  late final SuperAdminRepository _repository =
      widget.repository ?? SuperAdminRepository();
  final TextEditingController _searchController = TextEditingController();

  List<AdminUserModel> _items = <AdminUserModel>[];
  String? _selectedStatus;
  String? _selectedRole;
  String _search = '';
  int _page = 1;
  int _requestRevision = 0;
  Timer? _searchDebounce;
  Future<void>? _activeLoad;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool force = false}) {
    final activeLoad = _activeLoad;
    if (activeLoad != null && !force) return activeLoad;

    final revision = ++_requestRevision;
    _activeLoad = _performLoad(revision).whenComplete(() {
      _activeLoad = null;
    });
    return _activeLoad!;
  }

  Future<void> _performLoad(int revision) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final page = await _repository.getUsers(
        search: _search,
        status: _selectedStatus,
        role: _selectedRole,
        page: _page,
        limit: _pageLimit,
      );
      if (!mounted || revision != _requestRevision) return;
      setState(() => _items = page.items);
    } catch (error) {
      if (!mounted || revision != _requestRevision) return;
      setState(() => _errorMessage = _cleanError(error));
    } finally {
      if (mounted && revision == _requestRevision) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onStatusChanged(String? status) {
    if (_selectedStatus == status) return;
    setState(() {
      _selectedStatus = status;
      _page = 1;
    });
    _loadData(force: true);
  }

  void _onRoleChanged(String? role) {
    if (_selectedRole == role) return;
    setState(() {
      _selectedRole = role;
      _page = 1;
    });
    _loadData(force: true);
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      final trimmed = value.trim();
      if (_search == trimmed) return;
      setState(() {
        _search = trimmed;
        _page = 1;
      });
      _loadData(force: true);
    });
  }

  Future<void> _changeStatus(AdminUserModel item) async {
    final status = await showUpdateUserStatusDialog(context);
    if (status == null) return;
    final updated = await _repository.updateUserStatus(item.id, status);
    if (!mounted) return;
    setState(() {
      _items = _items
          .map((user) => user.id == updated.id ? updated : user)
          .toList();
    });
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search users',
              hintText: 'Search by name, phone, or email',
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _statusChip('All', null),
            _statusChip('Active', 'ACTIVE'),
            _statusChip('Inactive', 'INACTIVE'),
            _statusChip('Suspended', 'SUSPENDED'),
            DropdownButton<String?>(
              value: _selectedRole,
              hint: const Text('All Roles'),
              items: const <String?>[
                null,
                'SUPER_ADMIN',
                'MASJID_ADMIN',
                'IMAM',
                'COMMITTEE_MEMBER',
                'MEMBER',
              ].map((role) {
                return DropdownMenuItem<String?>(
                  value: role,
                  child: Text(role ?? 'All Roles'),
                );
              }).toList(),
              onChanged: _onRoleChanged,
            ),
          ],
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _statusChip(String label, String? status) {
    return FilterChip(
      label: Text(label),
      selected: _selectedStatus == status,
      onSelected: (_) => _onStatusChanged(status),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingView();
    if (_errorMessage != null) {
      return ErrorView(
        title: 'Unable to load',
        message: _errorMessage!,
        onRetry: () => _loadData(force: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(force: true),
      child: ListView(
        children: <Widget>[
          for (final item in _items)
            AdminUserCard(item: item, onStatus: () => _changeStatus(item)),
          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No users found')),
            ),
        ],
      ),
    );
  }
}

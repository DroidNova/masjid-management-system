import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/super_admin/data/super_admin_repository.dart';
import 'package:platform_core_frontend/features/super_admin/models/admin_user_model.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/users/widgets/assign_roles_dialog.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/users/widgets/update_user_status_dialog.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/widgets_common.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';

class AdminUserDetailScreen extends StatefulWidget {
  const AdminUserDetailScreen({
    super.key,
    required this.id,
    this.initial,
    this.repository,
  });

  final String id;
  final AdminUserModel? initial;
  final SuperAdminRepository? repository;

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  late final SuperAdminRepository _repository =
      widget.repository ?? SuperAdminRepository();
  AdminUserModel? _user;
  String? _errorMessage;
  bool _isLoading = true;
  Future<void>? _activeLoad;

  @override
  void initState() {
    super.initState();
    _user = widget.initial;
    _loadUser();
  }

  Future<void> _loadUser({bool force = false}) {
    final activeLoad = _activeLoad;
    if (activeLoad != null) return activeLoad;
    _activeLoad = _performLoadUser().whenComplete(() {
      _activeLoad = null;
    });
    return _activeLoad!;
  }

  Future<void> _performLoadUser() async {
    if (!mounted) return;
    setState(() {
      _isLoading = _user == null;
      _errorMessage = null;
    });
    try {
      final user = await _repository.getUser(widget.id);
      if (!mounted) return;
      setState(() => _user = user);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _cleanError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changeStatus(AdminUserModel user) async {
    final status = await showUpdateUserStatusDialog(context);
    if (status == null) return;
    final updated = await _repository.updateUserStatus(user.id, status);
    if (!mounted) return;
    setState(() => _user = updated);
  }

  Future<void> _assignRoles(AdminUserModel user) async {
    final roles = await showAssignRolesDialog(context, user.roles);
    if (roles == null) return;
    final updated = await _repository.updateUserRoles(user.id, roles);
    if (!mounted) return;
    setState(() => _user = updated);
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: _isLoading && user == null
          ? const LoadingView()
          : user == null
              ? Center(child: Text(_errorMessage ?? 'Unable to load user.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_errorMessage!),
                      ),
                    AdminStatusChip(user.status),
                    InfoRow('Name', user.fullName),
                    InfoRow('Phone', user.phone),
                    InfoRow('Email', user.email),
                    InfoRow('Roles', user.roles.join(', ')),
                    InfoRow('Masjid', user.masjidName ?? user.masjidId),
                    InfoRow('Created', user.createdAt),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      children: <Widget>[
                        FilledButton(
                          onPressed: () => _changeStatus(user),
                          child: const Text('Change Status'),
                        ),
                        FilledButton(
                          onPressed: () => _assignRoles(user),
                          child: const Text('Assign Roles'),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}

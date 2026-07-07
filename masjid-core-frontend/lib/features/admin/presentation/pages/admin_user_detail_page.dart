import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:platform_core_frontend/features/admin/presentation/controllers/admin_user_detail_controller.dart';
import 'package:platform_core_frontend/features/admin/presentation/policies/admin_user_policy.dart';
import 'package:platform_core_frontend/features/admin/presentation/widgets/roles_wrap.dart';
import 'package:platform_core_frontend/features/admin/presentation/widgets/user_status_chip.dart';
import 'package:platform_core_frontend/features/auth/presentation/auth_scope.dart';
import 'package:platform_core_frontend/shared/widgets/protected_app_shell.dart';
import 'package:platform_core_frontend/shared/widgets/unauthorized_view.dart';

class AdminUserDetailPage extends StatefulWidget {
  const AdminUserDetailPage({
    super.key,
    required this.userId,
    required this.repository,
  });

  final String userId;
  final AdminRepository repository;

  @override
  State<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends State<AdminUserDetailPage> {
  late final AdminUserDetailController _controller;

  static const List<String> _statusOptions = <String>[
    // TODO(BACKEND): load allowed status values from metadata endpoint once available.
    'ACTIVE',
    'SUSPENDED',
    'DISABLED',
  ];

  static const List<String> _roleOptions = <String>[
    'ADMIN',
    'USER',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AdminUserDetailController(widget.repository);
    _controller.loadUser(widget.userId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showStatusDialog() async {
    final current = _controller.state.user?.status;
    var selected = current;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update user status'),
          content: DropdownButtonFormField<String>(
            value: _statusOptions.contains(current) ? current : _statusOptions.first,
            items: _statusOptions
                .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
            onChanged: (value) => selected = value,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Update')),
          ],
        );
      },
    );

    if (confirmed != true || selected == null) {
      return;
    }

    await _controller.updateStatus(id: widget.userId, status: selected!);
    _showFeedback();
  }

  Future<void> _showRoleDialog(List<String> availableRoles) async {
    final currentRoles = _controller.state.user?.roles.toSet() ?? <String>{};
    final selectedRoles = <String>{...currentRoles};

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign roles'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: availableRoles
                      .map(
                        (role) => CheckboxListTile(
                          dense: true,
                          value: selectedRoles.contains(role),
                          title: Text(role),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                selectedRoles.add(role);
                              } else {
                                selectedRoles.remove(role);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Apply')),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _controller.assignRoles(id: widget.userId, roles: selectedRoles.toList());
    _showFeedback();
  }

  void _showFeedback() {
    final message = _controller.state.actionMessage ?? _controller.state.errorMessage;
    if (message == null) {
      return;
    }

    final isError = _controller.state.errorMessage != null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
    _controller.clearMessages();
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthScope.of(context);
    final actor = authController.state.user;
    if (!authController.canManageUsers) {
      return const ProtectedAppShell(
        title: 'User Detail',
        child: UnauthorizedView(),
      );
    }

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;

        return ProtectedAppShell(
          title: 'Admin User Detail',
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Builder(
              builder: (_) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.errorMessage != null && state.user == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.errorMessage!),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _controller.loadUser(widget.userId),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final user = state.user;
                if (user == null) {
                  return const Center(child: Text('User not found.'));
                }
                final canEditStatus = AdminUserPolicy.canEditStatus(actor, user);
                final canEditRoles = AdminUserPolicy.canEditRoles(actor, user);
                final availableRoles = AdminUserPolicy.availableAssignableRoles(actor, user)
                    .where((role) => _roleOptions.contains(role))
                    .toList(growable: false);
                final readOnlyReason = AdminUserPolicy.readOnlyReason(actor, user);
                final showActions = canEditStatus || canEditRoles;

                return ListView(
                  children: [
                    Text('User Details', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    Text('ID: ${user.id}'),
                    const SizedBox(height: 8),
                    Text('Name: ${user.name ?? '-'}'),
                    const SizedBox(height: 8),
                    Text('Email: ${user.email}'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Status: '),
                        UserStatusChip(status: user.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Roles:'),
                    const SizedBox(height: 6),
                    RolesWrap(roles: user.roles),
                    const SizedBox(height: 12),
                    const Text('Permissions:'),
                    const SizedBox(height: 6),
                    RolesWrap(roles: user.permissions),
                    if (user.createdAt != null) ...[
                      const SizedBox(height: 8),
                      Text('Created: ${user.createdAt}'),
                    ],
                    if (user.updatedAt != null) ...[
                      const SizedBox(height: 8),
                      Text('Updated: ${user.updatedAt}'),
                    ],
                    const SizedBox(height: 20),
                    if (readOnlyReason != null) ...[
                      Text(
                        readOnlyReason,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (showActions)
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          if (canEditStatus)
                            ElevatedButton(
                              onPressed: state.isUpdatingStatus ? null : _showStatusDialog,
                              child: state.isUpdatingStatus
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Update Status'),
                            ),
                          if (canEditRoles && availableRoles.isNotEmpty)
                            OutlinedButton(
                              onPressed: state.isAssigningRoles
                                  ? null
                                  : () => _showRoleDialog(availableRoles),
                              child: state.isAssigningRoles
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Assign Roles'),
                            ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

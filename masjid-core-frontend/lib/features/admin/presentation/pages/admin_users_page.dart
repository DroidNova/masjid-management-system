import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/routing/app_router.dart';
import 'package:platform_core_frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:platform_core_frontend/features/admin/presentation/controllers/admin_users_controller.dart';
import 'package:platform_core_frontend/features/admin/presentation/widgets/roles_wrap.dart';
import 'package:platform_core_frontend/features/admin/presentation/widgets/user_status_chip.dart';
import 'package:platform_core_frontend/features/auth/presentation/auth_scope.dart';
import 'package:platform_core_frontend/shared/widgets/list_state_view.dart';
import 'package:platform_core_frontend/shared/widgets/list_toolbar.dart';
import 'package:platform_core_frontend/shared/widgets/pagination_bar.dart';
import 'package:platform_core_frontend/shared/widgets/protected_app_shell.dart';
import 'package:platform_core_frontend/shared/widgets/unauthorized_view.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({
    super.key,
    required this.repository,
  });

  final AdminRepository repository;

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  late final AdminUsersController _controller;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _controller = AdminUsersController(widget.repository);
    _searchController = TextEditingController();
    _controller.loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthScope.of(context);

    if (!authController.canManageUsers) {
      return const ProtectedAppShell(
        title: 'Admin Users',
        child: UnauthorizedView(),
      );
    }

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;

        return ProtectedAppShell(
          title: 'Admin Users',
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage platform users',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                ListToolbar(
                  searchController: _searchController,
                  onSearch: _controller.search,
                  onRefresh: _controller.retry,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Builder(
                    builder: (_) {
                      if (state.isLoading) {
                        return const ListStateView.loading();
                      }

                      if (state.errorMessage != null) {
                        return ListStateView.error(
                          errorMessage: state.errorMessage!,
                          onRetry: _controller.retry,
                        );
                      }

                      if (state.users.isEmpty) {
                        return const ListStateView.empty(
                          emptyMessage: 'No users found.',
                        );
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth > 760) {
                                  return SingleChildScrollView(
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text('ID')),
                                        DataColumn(label: Text('Name')),
                                        DataColumn(label: Text('Email')),
                                        DataColumn(label: Text('Status')),
                                        DataColumn(label: Text('Roles')),
                                      ],
                                      rows: state.users
                                          .map(
                                            (user) => DataRow(
                                              onSelectChanged: (_) {
                                                context.push(AppRoutes.adminUserDetail(user.id));
                                              },
                                              cells: [
                                                DataCell(Text(user.id)),
                                                DataCell(Text(user.name ?? '-')),
                                                DataCell(Text(user.email)),
                                                DataCell(
                                                  UserStatusChip(status: user.status),
                                                ),
                                                DataCell(RolesWrap(roles: user.roles)),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  itemCount: state.users.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final user = state.users[index];
                                    return Card(
                                      child: ListTile(
                                        title: Text(user.name ?? user.email),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(user.email),
                                            const SizedBox(height: 6),
                                            UserStatusChip(status: user.status),
                                          ],
                                        ),
                                        onTap: () =>
                                            context.push(AppRoutes.adminUserDetail(user.id)),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          PaginationBar(
                            meta: state.meta,
                            onPrevious: () =>
                                _controller.goToPage(state.meta.page - 1),
                            onNext: () => _controller.goToPage(state.meta.page + 1),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

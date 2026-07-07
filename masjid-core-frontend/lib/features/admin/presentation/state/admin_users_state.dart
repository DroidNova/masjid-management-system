import 'package:platform_core_frontend/features/admin/domain/entities/admin_user_summary.dart';
import 'package:platform_core_frontend/shared/models/page_meta.dart';
import 'package:platform_core_frontend/shared/types/list_query_params.dart';

class AdminUsersState {
  const AdminUsersState({
    this.users = const <AdminUserSummary>[],
    this.isLoading = false,
    this.errorMessage,
    this.query = const ListQueryParams(),
    this.meta = const PageMeta(page: 1, limit: 20, total: 0),
  });

  final List<AdminUserSummary> users;
  final bool isLoading;
  final String? errorMessage;
  final ListQueryParams query;
  final PageMeta meta;

  AdminUsersState copyWith({
    List<AdminUserSummary>? users,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    ListQueryParams? query,
    PageMeta? meta,
  }) {
    return AdminUsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      query: query ?? this.query,
      meta: meta ?? this.meta,
    );
  }
}

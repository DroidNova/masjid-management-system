import 'package:flutter/foundation.dart';
import 'package:platform_core_frontend/core/network/api_exception.dart';
import 'package:platform_core_frontend/core/network/api_result.dart';
import 'package:platform_core_frontend/features/admin/domain/entities/admin_user_summary.dart';
import 'package:platform_core_frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:platform_core_frontend/features/admin/presentation/state/admin_users_state.dart';
import 'package:platform_core_frontend/shared/models/paginated_data.dart';
import 'package:platform_core_frontend/shared/types/list_query_params.dart';

class AdminUsersController extends ChangeNotifier {
  AdminUsersController(this._repository);

  final AdminRepository _repository;

  AdminUsersState _state = const AdminUsersState();
  AdminUsersState get state => _state;

  Future<void> loadUsers({ListQueryParams? query}) async {
    final nextQuery = query ?? _state.query;

    _setState(
      _state.copyWith(
        isLoading: true,
        query: nextQuery,
        clearError: true,
      ),
    );

    final result = await _repository.getUsers(query: nextQuery);
    switch (result) {
      case ApiSuccess<PaginatedData<AdminUserSummary>>(:final data):
        _setState(
          _state.copyWith(
            users: data.items,
            meta: data.meta,
            isLoading: false,
            clearError: true,
          ),
        );
      case ApiFailure<PaginatedData<AdminUserSummary>>(:final exception):
        _setState(
          _state.copyWith(
            isLoading: false,
            errorMessage: _toUserMessage(exception),
          ),
        );
    }
  }

  Future<void> search(String value) {
    return loadUsers(
      query: _state.query.copyWith(
        page: 1,
        search: value.trim().isEmpty ? null : value.trim(),
      ),
    );
  }

  Future<void> goToPage(int page) {
    return loadUsers(query: _state.query.copyWith(page: page));
  }

  Future<void> retry() => loadUsers(query: _state.query);

  String _toUserMessage(ApiException exception) {
    if (exception.isForbidden) {
      return 'You do not have permission to perform this action.';
    }
    if (exception.isUnauthorized || exception.isSessionExpired) {
      return 'Your session has expired. Please login again.';
    }
    if (exception.message.trim().isNotEmpty) {
      return exception.message;
    }
    return 'Unable to load users right now.';
  }

  void _setState(AdminUsersState newState) {
    _state = newState;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:platform_core_frontend/core/network/api_exception.dart';
import 'package:platform_core_frontend/core/network/api_result.dart';
import 'package:platform_core_frontend/features/admin/domain/entities/admin_user_detail.dart';
import 'package:platform_core_frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:platform_core_frontend/features/admin/presentation/state/admin_user_detail_state.dart';

class AdminUserDetailController extends ChangeNotifier {
  AdminUserDetailController(this._repository);

  final AdminRepository _repository;

  AdminUserDetailState _state = const AdminUserDetailState();
  AdminUserDetailState get state => _state;

  Future<void> loadUser(String id) async {
    _setState(_state.copyWith(isLoading: true, clearError: true));
    final result = await _repository.getUserById(id);
    _applyUserResult(result, loading: false);
  }

  Future<void> updateStatus({required String id, required String status}) async {
    _setState(
      _state.copyWith(
        isUpdatingStatus: true,
        clearError: true,
        clearActionMessage: true,
      ),
    );

    final result = await _repository.updateUserStatus(id: id, status: status);
    _applyUserResult(
      result,
      updatingStatus: false,
      actionMessage: 'Status updated successfully.',
    );
  }

  Future<void> assignRoles({required String id, required List<String> roles}) async {
    _setState(
      _state.copyWith(
        isAssigningRoles: true,
        clearError: true,
        clearActionMessage: true,
      ),
    );

    final result = await _repository.assignUserRoles(id: id, roles: roles);
    _applyUserResult(
      result,
      assigningRoles: false,
      actionMessage: 'Roles updated successfully.',
    );
  }

  void clearMessages() {
    _setState(_state.copyWith(clearActionMessage: true, clearError: true));
  }

  void _applyUserResult(
    ApiResult<AdminUserDetail> result, {
    bool? loading,
    bool? updatingStatus,
    bool? assigningRoles,
    String? actionMessage,
  }) {
    switch (result) {
      case ApiSuccess<AdminUserDetail>(:final data):
        _setState(
          _state.copyWith(
            user: data,
            isLoading: loading ?? false,
            isUpdatingStatus: updatingStatus ?? false,
            isAssigningRoles: assigningRoles ?? false,
            clearError: true,
            actionMessage: actionMessage,
          ),
        );
      case ApiFailure<AdminUserDetail>(:final exception):
        _setState(
          _state.copyWith(
            isLoading: loading ?? false,
            isUpdatingStatus: updatingStatus ?? false,
            isAssigningRoles: assigningRoles ?? false,
            errorMessage: _toUserMessage(exception),
          ),
        );
    }
  }

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
    return 'Unable to complete admin action.';
  }

  void _setState(AdminUserDetailState newState) {
    _state = newState;
    notifyListeners();
  }
}

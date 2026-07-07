import 'package:platform_core_frontend/features/admin/domain/entities/admin_user_detail.dart';

class AdminUserDetailState {
  const AdminUserDetailState({
    this.user,
    this.isLoading = false,
    this.isUpdatingStatus = false,
    this.isAssigningRoles = false,
    this.errorMessage,
    this.actionMessage,
  });

  final AdminUserDetail? user;
  final bool isLoading;
  final bool isUpdatingStatus;
  final bool isAssigningRoles;
  final String? errorMessage;
  final String? actionMessage;

  AdminUserDetailState copyWith({
    AdminUserDetail? user,
    bool clearUser = false,
    bool? isLoading,
    bool? isUpdatingStatus,
    bool? isAssigningRoles,
    String? errorMessage,
    bool clearError = false,
    String? actionMessage,
    bool clearActionMessage = false,
  }) {
    return AdminUserDetailState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
      isAssigningRoles: isAssigningRoles ?? this.isAssigningRoles,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionMessage: clearActionMessage
          ? null
          : (actionMessage ?? this.actionMessage),
    );
  }
}

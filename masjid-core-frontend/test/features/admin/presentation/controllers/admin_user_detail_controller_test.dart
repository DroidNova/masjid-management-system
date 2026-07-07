import 'package:flutter_test/flutter_test.dart';
import 'package:platform_core_frontend/core/errors/app_exception.dart';
import 'package:platform_core_frontend/core/network/api_result.dart';
import 'package:platform_core_frontend/features/admin/domain/entities/admin_user_detail.dart';
import 'package:platform_core_frontend/features/admin/domain/entities/admin_user_summary.dart';
import 'package:platform_core_frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:platform_core_frontend/features/admin/presentation/controllers/admin_user_detail_controller.dart';
import 'package:platform_core_frontend/shared/models/page_meta.dart';
import 'package:platform_core_frontend/shared/models/paginated_data.dart';
import 'package:platform_core_frontend/shared/types/list_query_params.dart';

void main() {
  group('AdminUserDetailController', () {
    test('surfaces backend message for forbidden role assignment', () async {
      final repository = _FakeAdminRepository(
        assignRolesResult: const ApiFailure<AdminUserDetail>(
          UnknownException('SUPER_ADMIN role cannot be assigned via API'),
        ),
      );
      final controller = AdminUserDetailController(repository);

      await controller.assignRoles(id: 'user-1', roles: const ['SUPER_ADMIN']);

      expect(
        controller.state.errorMessage,
        'SUPER_ADMIN role cannot be assigned via API',
      );
      expect(controller.state.actionMessage, isNull);
      expect(controller.state.isAssigningRoles, isFalse);
    });
  });
}

class _FakeAdminRepository implements AdminRepository {
  _FakeAdminRepository({
    this.assignRolesResult,
  });

  final ApiResult<AdminUserDetail>? assignRolesResult;

  @override
  Future<ApiResult<AdminUserDetail>> assignUserRoles({
    required String id,
    required List<String> roles,
  }) async {
    return assignRolesResult ??
        ApiSuccess<AdminUserDetail>(
          _userDetail.copyWith(roles: roles),
        );
  }

  @override
  Future<ApiResult<AdminUserDetail>> getUserById(String id) async {
    return const ApiSuccess<AdminUserDetail>(_userDetail);
  }

  @override
  Future<ApiResult<PaginatedData<AdminUserSummary>>> getUsers({
    ListQueryParams query = const ListQueryParams(),
  }) async {
    return const ApiSuccess<PaginatedData<AdminUserSummary>>(
      PaginatedData<AdminUserSummary>(
        items: <AdminUserSummary>[],
        meta: PageMeta(
          page: 1,
          limit: 10,
          totalItems: 0,
          totalPages: 0,
        ),
      ),
    );
  }

  @override
  Future<ApiResult<AdminUserDetail>> updateUserStatus({
    required String id,
    required String status,
  }) async {
    return ApiSuccess<AdminUserDetail>(_userDetail.copyWith(status: status));
  }
}

const _userDetail = _AdminUserDetailFixture.user;

extension on AdminUserDetail {
  AdminUserDetail copyWith({
    String? status,
    List<String>? roles,
  }) {
    return AdminUserDetail(
      id: id,
      email: email,
      status: status ?? this.status,
      roles: roles ?? this.roles,
      permissions: permissions,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class _AdminUserDetailFixture {
  static const user = AdminUserDetail(
    id: 'user-1',
    email: 'user@example.com',
    status: 'ACTIVE',
    roles: <String>['USER'],
    permissions: <String>[],
  );
}

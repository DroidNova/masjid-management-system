import 'package:platform_core_frontend/core/network/api_result.dart';
import 'package:platform_core_frontend/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:platform_core_frontend/features/admin/domain/entities/admin_user_detail.dart';
import 'package:platform_core_frontend/features/admin/domain/entities/admin_user_summary.dart';
import 'package:platform_core_frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:platform_core_frontend/shared/models/paginated_data.dart';
import 'package:platform_core_frontend/shared/types/list_query_params.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._remoteDataSource);

  final AdminRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<PaginatedData<AdminUserSummary>>> getUsers({
    ListQueryParams query = const ListQueryParams(),
  }) async {
    final result = await _remoteDataSource.getUsers(query: query);
    return result.mapData(
      (data) => PaginatedData<AdminUserSummary>(
        items: data.items.map((user) => user.toEntity()).toList(growable: false),
        meta: data.meta,
      ),
    );
  }

  @override
  Future<ApiResult<AdminUserDetail>> getUserById(String id) async {
    final result = await _remoteDataSource.getUserById(id);
    return result.mapData((model) => model.toEntity());
  }

  @override
  Future<ApiResult<AdminUserDetail>> updateUserStatus({
    required String id,
    required String status,
  }) async {
    final result = await _remoteDataSource.updateUserStatus(id: id, status: status);
    return result.mapData((model) => model.toEntity());
  }

  @override
  Future<ApiResult<AdminUserDetail>> assignUserRoles({
    required String id,
    required List<String> roles,
  }) async {
    final result = await _remoteDataSource.assignUserRoles(id: id, roles: roles);
    return result.mapData((model) => model.toEntity());
  }
}

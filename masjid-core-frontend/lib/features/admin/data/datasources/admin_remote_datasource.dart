import 'package:platform_core_frontend/core/constants/api_endpoints.dart';
import 'package:platform_core_frontend/core/network/api_result.dart';
import 'package:platform_core_frontend/core/network/dio_client.dart';
import 'package:platform_core_frontend/core/network/list_response_mapper.dart';
import 'package:platform_core_frontend/features/admin/data/models/admin_user_detail_model.dart';
import 'package:platform_core_frontend/features/admin/data/models/admin_user_summary_model.dart';
import 'package:platform_core_frontend/shared/models/paginated_data.dart';
import 'package:platform_core_frontend/shared/types/list_query_params.dart';

class AdminRemoteDataSource {
  AdminRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<ApiResult<PaginatedData<AdminUserSummaryModel>>> getUsers({
    ListQueryParams query = const ListQueryParams(),
  }) {
    return _dioClient.get<PaginatedData<AdminUserSummaryModel>>(
      ApiEndpoints.adminUsers,
      queryParameters: query.toQueryMap(),
      parser: (raw) => ListResponseMapper.map<AdminUserSummaryModel>(
        raw,
        itemParser: AdminUserSummaryModel.fromJson,
        defaultLimit: query.limit,
      ),
    );
  }

  Future<ApiResult<AdminUserDetailModel>> getUserById(String id) {
    return _dioClient.get<AdminUserDetailModel>(
      ApiEndpoints.adminUserById(id),
      parser: AdminUserDetailModel.fromResponse,
    );
  }

  Future<ApiResult<AdminUserDetailModel>> updateUserStatus({
    required String id,
    required String status,
  }) {
    return _dioClient.patch<AdminUserDetailModel>(
      ApiEndpoints.adminUserStatus(id),
      data: {
        'status': status,
      },
      parser: AdminUserDetailModel.fromResponse,
    );
  }

  Future<ApiResult<AdminUserDetailModel>> assignUserRoles({
    required String id,
    required List<String> roles,
  }) {
    return _dioClient.post<AdminUserDetailModel>(
      ApiEndpoints.adminUserRoles(id),
      data: {
        'roles': roles,
      },
      parser: AdminUserDetailModel.fromResponse,
    );
  }
}

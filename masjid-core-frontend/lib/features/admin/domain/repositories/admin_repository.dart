import 'package:platform_core_frontend/core/network/api_result.dart';
import 'package:platform_core_frontend/features/admin/domain/entities/admin_user_detail.dart';
import 'package:platform_core_frontend/features/admin/domain/entities/admin_user_summary.dart';
import 'package:platform_core_frontend/shared/models/paginated_data.dart';
import 'package:platform_core_frontend/shared/types/list_query_params.dart';

abstract class AdminRepository {
  Future<ApiResult<PaginatedData<AdminUserSummary>>> getUsers({
    ListQueryParams query = const ListQueryParams(),
  });

  Future<ApiResult<AdminUserDetail>> getUserById(String id);

  Future<ApiResult<AdminUserDetail>> updateUserStatus({
    required String id,
    required String status,
  });

  Future<ApiResult<AdminUserDetail>> assignUserRoles({
    required String id,
    required List<String> roles,
  });
}

import 'package:platform_core_frontend/core/constants/api_endpoints.dart';
import 'package:platform_core_frontend/core/network/api_result.dart';
import 'package:platform_core_frontend/core/network/dio_client.dart';
import 'package:platform_core_frontend/features/auth/data/models/auth_tokens_model.dart';
import 'package:platform_core_frontend/features/auth/data/models/current_user_model.dart';
import 'package:platform_core_frontend/shared/types/json_types.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<ApiResult<AuthTokensModel>> register({required JsonMap payload}) {
    return _dioClient.post<AuthTokensModel>(
      ApiEndpoints.authRegister,
      data: payload,
      parser: AuthTokensModel.fromResponse,
      requiresAuth: false,
    );
  }

  Future<ApiResult<AuthTokensModel>> login({required JsonMap payload}) {
    return _dioClient.post<AuthTokensModel>(
      ApiEndpoints.authLogin,
      data: payload,
      parser: AuthTokensModel.fromResponse,
      requiresAuth: false,
    );
  }

  Future<ApiResult<AuthTokensModel>> refreshToken({
    required String refreshToken,
  }) {
    return _dioClient.post<AuthTokensModel>(
      ApiEndpoints.authRefresh,
      data: {'refreshToken': refreshToken},
      parser: AuthTokensModel.fromResponse,
      requiresAuth: false,
    );
  }

  Future<ApiResult<void>> logout() {
    return _dioClient.post<void>(
      ApiEndpoints.authLogout,
      parser: (_) {},
    );
  }

  Future<ApiResult<CurrentUserModel>> getCurrentUser() {
    return _dioClient.get<CurrentUserModel>(
      ApiEndpoints.authMe,
      parser: CurrentUserModel.fromResponse,
    );
  }
}

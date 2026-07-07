import 'package:platform_core_frontend/core/network/api_result.dart';
import 'package:platform_core_frontend/features/auth/domain/entities/auth_tokens.dart';
import 'package:platform_core_frontend/features/auth/domain/entities/current_user.dart';
import 'package:platform_core_frontend/shared/types/json_types.dart';

abstract class AuthRepository {
  Future<ApiResult<AuthTokens>> register({required JsonMap payload});

  Future<ApiResult<AuthTokens>> login({required JsonMap payload});

  Future<ApiResult<AuthTokens>> refreshToken({String? refreshToken});

  Future<ApiResult<void>> logout();

  Future<ApiResult<CurrentUser>> getCurrentUser();
}

import 'dart:math';

import 'package:platform_core_frontend/core/network/api_exception.dart';
import 'package:platform_core_frontend/core/network/api_result.dart';
import 'package:platform_core_frontend/core/storage/token_storage.dart';
import 'package:platform_core_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:platform_core_frontend/features/auth/data/models/auth_tokens_model.dart';
import 'package:platform_core_frontend/features/auth/domain/entities/auth_tokens.dart';
import 'package:platform_core_frontend/features/auth/domain/entities/current_user.dart';
import 'package:platform_core_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:platform_core_frontend/shared/types/json_types.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<ApiResult<AuthTokens>> register({required JsonMap payload}) async {
    final result = await _remoteDataSource.register(payload: payload);
    return _persistTokens(result);
  }

  @override
  Future<ApiResult<AuthTokens>> login({required JsonMap payload}) async {
    final result = await _remoteDataSource.login(payload: payload);
    return _persistTokens(result);
  }

  @override
  Future<ApiResult<AuthTokens>> refreshToken({String? refreshToken}) async {
    final token = refreshToken ?? await _tokenStorage.getRefreshToken();
    if (token == null || token.isEmpty) {
      return const ApiFailure<AuthTokens>(
        ApiException(message: 'Your session has expired. Please login again.'),
      );
    }

    final result = await _remoteDataSource.refreshToken(refreshToken: token);
    return _persistTokens(result);
  }

  @override
  Future<ApiResult<void>> logout() async {
    final result = await _remoteDataSource.logout();
    await _tokenStorage.clearTokens();
    return result;
  }

  @override
  Future<ApiResult<CurrentUser>> getCurrentUser() async {
    final result = await _remoteDataSource.getCurrentUser();
    return result.mapData((model) => model.toEntity());
  }

  Future<ApiResult<AuthTokens>> _persistTokens(
    ApiResult<AuthTokensModel> result,
  ) async {
    final entityResult = result.mapData((model) => model.toEntity());

    switch (entityResult) {
      case ApiSuccess<AuthTokens>(:final data):
        await _tokenStorage.saveAccessToken(data.accessToken);
        await _tokenStorage.saveRefreshToken(data.refreshToken);
        return ApiSuccess<AuthTokens>(data);
      case ApiFailure<AuthTokens>(:final exception):
        return ApiFailure<AuthTokens>(exception);
    }
  }
}

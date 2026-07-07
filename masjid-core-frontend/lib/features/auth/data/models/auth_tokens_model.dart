import 'package:platform_core_frontend/core/network/response_mapper.dart';
import 'package:platform_core_frontend/features/auth/data/models/current_user_model.dart';
import 'package:platform_core_frontend/features/auth/domain/entities/auth_tokens.dart';
import 'package:platform_core_frontend/shared/types/json_types.dart';

class AuthTokensModel {
  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  final String accessToken;
  final String refreshToken;
  final CurrentUserModel? user;

  factory AuthTokensModel.fromJson(JsonMap json) {
    final accessToken = json['accessToken'] ?? json['access_token'] ?? '';
    final refreshToken = json['refreshToken'] ?? json['refresh_token'] ?? '';

    return AuthTokensModel(
      accessToken: accessToken.toString(),
      refreshToken: refreshToken.toString(),
      user: (json['user'] is Map<String, dynamic>)
          ? CurrentUserModel.fromJson(json['user'] as JsonMap)
          : null,
    );
  }

  factory AuthTokensModel.fromResponse(dynamic raw) {
    final json = ResponseMapper.unwrapDataMap(raw);
    final tokenMap = (json['tokens'] is Map<String, dynamic>)
        ? json['tokens'] as Map<String, dynamic>
        : json;
    final userMap = (json['user'] is Map<String, dynamic>)
        ? json['user'] as JsonMap
        : (tokenMap['user'] is Map<String, dynamic>)
            ? tokenMap['user'] as JsonMap
            : null;

    final auth = AuthTokensModel.fromJson(tokenMap);
    return AuthTokensModel(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      user: userMap == null ? auth.user : CurrentUserModel.fromJson(userMap),
    );
  }

  AuthTokens toEntity() {
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user?.toEntity(),
    );
  }

  JsonMap toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user?.toJson(),
    };
  }
}

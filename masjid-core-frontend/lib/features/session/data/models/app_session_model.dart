import 'package:platform_core_frontend/features/auth/data/models/auth_tokens_model.dart';
import 'package:platform_core_frontend/features/auth/data/models/current_user_model.dart';
import 'package:platform_core_frontend/features/auth/domain/entities/auth_tokens.dart';
import 'package:platform_core_frontend/features/auth/domain/entities/current_user.dart';
import 'package:platform_core_frontend/features/session/domain/entities/app_session.dart';
import 'package:platform_core_frontend/shared/types/json_types.dart';

class AppSessionModel extends AppSession {
  const AppSessionModel({
    super.user,
    super.tokens,
  });

  factory AppSessionModel.fromJson(JsonMap json) {
    return AppSessionModel(
      user: json['user'] is JsonMap
          ? CurrentUserModel.fromJson(json['user'] as JsonMap).toEntity()
          : null,
      tokens: json['tokens'] is JsonMap
          ? AuthTokensModel.fromJson(json['tokens'] as JsonMap).toEntity()
          : null,
    );
  }

  JsonMap toJson() {
    return {
      'user': _userToJson(user),
      'tokens': _tokensToJson(tokens),
    };
  }

  JsonMap? _userToJson(CurrentUser? user) {
    if (user == null) {
      return null;
    }

    return {
      'id': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'roles': user.roles,
      'permissions': user.permissions,
    };
  }

  JsonMap? _tokensToJson(AuthTokens? tokens) {
    if (tokens == null) {
      return null;
    }

    return {
      'accessToken': tokens.accessToken,
      'refreshToken': tokens.refreshToken,
    };
  }
}

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:platform_core_frontend/features/auth/data/models/app_user.dart';

class SessionStorage {
  SessionStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _userKey = 'current_user';

  final FlutterSecureStorage _secureStorage;

  Future<void> saveUser(AppUser user) {
    return _secureStorage.write(
      key: _userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<AppUser?> getUser() async {
    final rawUser = await _secureStorage.read(key: _userKey);
    if (rawUser == null || rawUser.isEmpty) return null;

    final decoded = jsonDecode(rawUser);
    if (decoded is Map<String, dynamic>) {
      return AppUser.fromJson(decoded);
    }
    return null;
  }

  Future<void> clearUser() {
    return _secureStorage.delete(key: _userKey);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/community/data/community_repository.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockCommunityRepository extends Mock implements CommunityRepository {}

/// Auth fixed to one signed-in user (no storage, no network).
class FixedAuth extends AuthController {
  FixedAuth(this.user);

  final AppUser? user;
  int signOutCalls = 0;

  @override
  AuthState build() =>
      user == null ? const AuthSignedOut() : AuthSignedIn(user!);

  @override
  Future<void> signOut() async {
    signOutCalls++;
    state = const AuthSignedOut();
  }
}

AppUser testUser({
  List<String> permissions = const <String>[],
  List<String> roles = const <String>['MEMBER'],
  String? masjidId = 'm1',
}) => AppUser(
  id: 'me',
  fullName: 'Rafiq',
  roles: roles,
  permissions: permissions,
  masjidId: masjidId,
);

const localizationsDelegates = <LocalizationsDelegate<Object>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];

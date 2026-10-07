import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/core/storage/session_storage.dart';
import 'package:masjid_core_frontend/core/storage/token_storage.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/auth_repository.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:mocktail/mocktail.dart';

class _Tokens extends TokenStorage {
  _Tokens({this.access, this.refresh});
  String? access;
  String? refresh;

  @override
  Future<String?> getAccessToken() async => access;
  @override
  Future<String?> getRefreshToken() async => refresh;
  @override
  Future<bool> hasAccessToken() async => access != null;
  @override
  Future<void> clearTokens() async => access = refresh = null;
}

class _Sessions extends SessionStorage {
  _Sessions([this.user]);
  AppUser? user;

  @override
  Future<AppUser?> getUser() async => user;
  @override
  Future<void> saveUser(AppUser user) async => this.user = user;
  @override
  Future<void> clearUser() async => user = null;
}

class _MockRepository extends Mock implements AuthRepository {}

const _stored = AppUser(
  id: 'u1',
  fullName: 'Stored',
  roles: ['MEMBER'],
  permissions: ['dashboard.read'],
);
const _fresh = AppUser(
  id: 'u1',
  fullName: 'Fresh',
  roles: ['COMMITTEE_MEMBER'],
  permissions: ['dashboard.read', 'expenses.manage'],
);

ProviderContainer _container({
  required _Tokens tokens,
  required _Sessions sessions,
  required _MockRepository repository,
}) {
  final container = ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(tokens),
      sessionStorageProvider.overrideWithValue(sessions),
      authRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Lets the controller's startup microtask and awaits finish.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _MockRepository repository;

  setUp(() {
    repository = _MockRepository();
    when(() => repository.clearLocalSession()).thenAnswer((_) async {});
    when(() => repository.logout()).thenAnswer((_) async {});
  });

  test('starts unknown, then signed out when nothing is stored', () async {
    final container = _container(
      tokens: _Tokens(),
      sessions: _Sessions(),
      repository: repository,
    );

    expect(container.read(authControllerProvider), isA<AuthUnknown>());
    await _settle();
    expect(container.read(authControllerProvider), isA<AuthSignedOut>());
  });

  test('opens with the stored user, then refreshes permissions', () async {
    when(() => repository.fetchCurrentUser()).thenAnswer((_) async => _fresh);
    final container = _container(
      tokens: _Tokens(access: 'a', refresh: 'r'),
      sessions: _Sessions(_stored),
      repository: repository,
    );

    container.read(authControllerProvider);
    await _settle();
    await _settle();

    expect(container.read(currentUserProvider)?.fullName, 'Fresh');
    expect(
      container.read(currentPermissionsProvider),
      contains('expenses.manage'),
    );
  });

  test('stays signed in when the background refresh fails offline', () async {
    when(() => repository.fetchCurrentUser()).thenThrow(
      const ApiException(message: 'offline', code: ApiErrorCodes.network),
    );
    final container = _container(
      tokens: _Tokens(access: 'a', refresh: 'r'),
      sessions: _Sessions(_stored),
      repository: repository,
    );

    container.read(authControllerProvider);
    await _settle();
    await _settle();

    expect(container.read(currentUserProvider)?.fullName, 'Stored');
  });

  test('uses the refresh token when only that is stored', () async {
    when(() => repository.fetchCurrentUser()).thenAnswer((_) async => _fresh);
    final container = _container(
      tokens: _Tokens(refresh: 'r'),
      sessions: _Sessions(),
      repository: repository,
    );

    container.read(authControllerProvider);
    await _settle();
    await _settle();

    expect(container.read(authControllerProvider), isA<AuthSignedIn>());
  });

  test('signs out with a message when the session expires', () async {
    when(() => repository.fetchCurrentUser()).thenAnswer((_) async => _fresh);
    final sessions = _Sessions(_stored);
    final container = _container(
      tokens: _Tokens(access: 'a', refresh: 'r'),
      sessions: sessions,
      repository: repository,
    );
    container.read(authControllerProvider);
    await _settle();

    await container
        .read(authControllerProvider.notifier)
        .handleSessionExpired();

    final state = container.read(authControllerProvider);
    expect(state, isA<AuthSignedOut>());
    expect((state as AuthSignedOut).message, contains('expired'));
    expect(sessions.user, isNull);
  });

  test('signOut calls the server and clears the user', () async {
    when(() => repository.fetchCurrentUser()).thenAnswer((_) async => _fresh);
    final container = _container(
      tokens: _Tokens(access: 'a', refresh: 'r'),
      sessions: _Sessions(_stored),
      repository: repository,
    );
    container.read(authControllerProvider);
    await _settle();

    await container.read(authControllerProvider.notifier).signOut();

    verify(() => repository.logout()).called(1);
    expect(container.read(currentUserProvider), isNull);
  });

  test('an unchanged user from /auth/me emits no new state', () async {
    when(
      () => repository.fetchCurrentUser(),
    ).thenAnswer((_) async => _stored.copyWith());
    final container = _container(
      tokens: _Tokens(access: 'a', refresh: 'r'),
      sessions: _Sessions(_stored),
      repository: repository,
    );
    final states = <AuthState>[];
    container.listen(
      authControllerProvider,
      (_, next) => states.add(next),
      fireImmediately: true,
    );
    await _settle();
    await _settle();

    // Unknown, then signed in once; the equal refreshed user is dropped.
    expect(states, hasLength(2));
    expect(states.last, isA<AuthSignedIn>());

    await container.read(authControllerProvider.notifier).refreshUser();
    expect(states, hasLength(2));
  });

  test('a deactivated account is signed out on refresh', () async {
    when(() => repository.fetchCurrentUser()).thenThrow(
      const ApiException(
        message: 'User is inactive',
        code: ApiErrorCodes.userInactive,
        statusCode: 403,
      ),
    );
    final container = _container(
      tokens: _Tokens(access: 'a', refresh: 'r'),
      sessions: _Sessions(_stored),
      repository: repository,
    );
    container.read(authControllerProvider);
    await _settle();
    await _settle();

    expect(container.read(authControllerProvider), isA<AuthSignedOut>());
    verify(() => repository.clearLocalSession()).called(1);
  });
}

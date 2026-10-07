// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/storage/token_storage.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage secure;
  late TokenStorage tokens;

  setUp(() {
    secure = _MockSecureStorage();
    tokens = TokenStorage(secureStorage: secure);
    when(
      () => secure.read(key: 'access_token'),
    ).thenAnswer((_) async => 'stored-access');
    when(
      () => secure.read(key: 'refresh_token'),
    ).thenAnswer((_) async => 'stored-refresh');
    when(
      () => secure.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(() => secure.delete(key: any(named: 'key'))).thenAnswer((_) async {});
  });

  test('reads the secure store once, then serves from memory', () async {
    final results = await Future.wait(<Future<String?>>[
      tokens.getAccessToken(),
      tokens.getAccessToken(),
      tokens.getRefreshToken(),
    ]);
    expect(results, <String?>[
      'stored-access',
      'stored-access',
      'stored-refresh',
    ]);
    expect(await tokens.hasAccessToken(), isTrue);

    verify(() => secure.read(key: 'access_token')).called(1);
    verify(() => secure.read(key: 'refresh_token')).called(1);
  });

  test('save updates memory and the secure store', () async {
    await tokens.saveTokens(accessToken: 'new-a', refreshToken: 'new-r');

    expect(await tokens.getAccessToken(), 'new-a');
    expect(await tokens.getRefreshToken(), 'new-r');
    verify(() => secure.write(key: 'access_token', value: 'new-a')).called(1);
    verify(() => secure.write(key: 'refresh_token', value: 'new-r')).called(1);
    verifyNever(() => secure.read(key: any(named: 'key')));
  });

  test('clear empties memory and the secure store', () async {
    await tokens.getAccessToken();
    await tokens.clearTokens();

    expect(await tokens.getAccessToken(), isNull);
    expect(await tokens.hasAccessToken(), isFalse);
    verify(() => secure.delete(key: 'access_token')).called(1);
    verify(() => secure.delete(key: 'refresh_token')).called(1);
  });
}

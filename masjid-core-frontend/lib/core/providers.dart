import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/core/storage/session_storage.dart';
import 'package:masjid_core_frontend/core/storage/token_storage.dart';
import 'package:masjid_core_frontend/features/auth/data/auth_api.dart';
import 'package:masjid_core_frontend/features/auth/data/auth_repository.dart';

/// App-wide dependencies. Override them in tests with
/// `ProviderScope(overrides: [...])` or `ProviderContainer(overrides: [...])`.

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final sessionStorageProvider = Provider<SessionStorage>(
  (ref) => SessionStorage(),
);

/// The single HTTP client, configured in main.dart.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    authApi: AuthApi(apiClient: ref.watch(apiClientProvider)),
    tokenStorage: ref.watch(tokenStorageProvider),
    sessionStorage: ref.watch(sessionStorageProvider),
  ),
);

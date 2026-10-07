/// Build-time configuration.
///
/// Values come from `--dart-define-from-file=env/<name>.json` (see env/).
/// Defaults match local development so `flutter run` works without flags.
class ApiConfig {
  const ApiConfig._();

  /// dev | staging | prod
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  static bool get isProduction => environment == 'prod';
}

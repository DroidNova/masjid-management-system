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

  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  /// The API's address. A path such as `/api/v1` (website builds) means
  /// "this website's own address": the site's nginx forwards /api/ to the
  /// backend, so the site works the same on localhost, the tunnel, or a
  /// real domain, with no cross-site requests.
  static String get baseUrl => resolveBaseUrl(_configuredBaseUrl, Uri.base);

  /// [configured] as is when it is a full address; a path is joined to the
  /// [page]'s origin.
  static String resolveBaseUrl(String configured, Uri page) =>
      configured.startsWith('/') ? '${page.origin}$configured' : configured;

  static bool get isProduction => environment == 'prod';
}

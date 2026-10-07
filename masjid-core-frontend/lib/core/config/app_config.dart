class AppConfig {
  const AppConfig({
    required this.appName,
    required this.productKey,
    required this.apiBaseUrl,
    required this.environment,
    required this.requestTimeout,
  });

  final String appName;
  final String productKey;
  final String apiBaseUrl;
  final String environment;
  final Duration requestTimeout;

  static const AppConfig platformCoreDev = AppConfig(
    appName: 'Platform Core',
    productKey: 'platform-core',
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:3000/api/v1',
    ),
    environment: 'dev',
    requestTimeout: Duration(seconds: 30),
  );

  AppConfig copyWith({
    String? appName,
    String? productKey,
    String? apiBaseUrl,
    String? environment,
    Duration? requestTimeout,
  }) {
    return AppConfig(
      appName: appName ?? this.appName,
      productKey: productKey ?? this.productKey,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      environment: environment ?? this.environment,
      requestTimeout: requestTimeout ?? this.requestTimeout,
    );
  }
}

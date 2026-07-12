enum AppEnvironment { dev, staging, prod }

class AppConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
  });

  static AppConfig? _instance;

  static void initialize(AppConfig config) {
    _instance = config;
  }

  static AppConfig get instance {
    if (_instance == null) {
      throw StateError('AppConfig must be initialized first.');
    }
    return _instance!;
  }
}

import '../feature_flags/feature_flags.dart';

enum AppEnvironment { development, staging, production }

class AppConfig {
  final String appName;
  final AppEnvironment environment;
  final FeatureFlags featureFlags;
  final bool crashTestEnabled;

  const AppConfig({
    required this.appName,
    required this.environment,
    required this.featureFlags,
    required this.crashTestEnabled,
  });

  const AppConfig.production({this.crashTestEnabled = false})
    : appName = 'OrangeONE',
      environment = AppEnvironment.production,
      featureFlags = const FeatureFlags.production();

  const AppConfig.development({this.crashTestEnabled = false})
    : appName = 'OrangeONE Dev',
      environment = AppEnvironment.development,
      featureFlags = const FeatureFlags.disabled();

  const AppConfig.staging({this.crashTestEnabled = false})
    : appName = 'OrangeONE Staging',
      environment = AppEnvironment.staging,
      featureFlags = const FeatureFlags.production();

  factory AppConfig.fromEnvironment({
    String environmentName = const String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'production',
    ),
    bool crashTestEnabled = const bool.fromEnvironment(
      'ENABLE_CRASH_TEST',
      defaultValue: false,
    ),
  }) {
    return switch (environmentName.toLowerCase()) {
      'development' ||
      'dev' => AppConfig.development(crashTestEnabled: crashTestEnabled),
      'staging' ||
      'stage' => AppConfig.staging(crashTestEnabled: crashTestEnabled),
      'production' ||
      'prod' => AppConfig.production(crashTestEnabled: crashTestEnabled),
      _ => AppConfig.production(crashTestEnabled: crashTestEnabled),
    };
  }

  String get environmentName {
    return switch (environment) {
      AppEnvironment.development => 'development',
      AppEnvironment.staging => 'staging',
      AppEnvironment.production => 'production',
    };
  }

  bool get isProduction {
    return environment == AppEnvironment.production;
  }

  bool get isDevelopment {
    return environment == AppEnvironment.development;
  }

  bool get isStaging {
    return environment == AppEnvironment.staging;
  }
}

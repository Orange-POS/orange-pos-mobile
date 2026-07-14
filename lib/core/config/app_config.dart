import '../feature_flags/feature_flags.dart';

enum AppEnvironment { development, staging, production }

class AppConfig {
  final String appName;
  final AppEnvironment environment;
  final FeatureFlags featureFlags;

  const AppConfig({
    required this.appName,
    required this.environment,
    required this.featureFlags,
  });

  const AppConfig.production()
    : appName = 'OrangeONE',
      environment = AppEnvironment.production,
      featureFlags = const FeatureFlags.production();

  const AppConfig.development()
    : appName = 'OrangeONE Dev',
      environment = AppEnvironment.development,
      featureFlags = const FeatureFlags.disabled();

  const AppConfig.staging()
    : appName = 'OrangeONE Staging',
      environment = AppEnvironment.staging,
      featureFlags = const FeatureFlags.production();

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

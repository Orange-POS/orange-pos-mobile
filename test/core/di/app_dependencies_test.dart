import 'package:flutter_app/core/config/app_config.dart';
import 'package:flutter_app/core/di/app_dependencies.dart';
import 'package:flutter_app/core/feature_flags/feature_flags.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppDependencies', () {
    test('uses production config by default', () {
      final dependencies = AppDependencies();

      expect(dependencies.config.appName, 'OrangeONE');
      expect(dependencies.config.isProduction, true);
      expect(dependencies.featureFlags.isDemoModeAvailable, true);
    });

    test('uses feature flags from provided config', () {
      const config = AppConfig(
        appName: 'OrangeONE Dev',
        environment: AppEnvironment.development,
        featureFlags: FeatureFlags.disabled(),
      );

      final dependencies = AppDependencies(config: config);

      expect(dependencies.config.appName, 'OrangeONE Dev');
      expect(dependencies.featureFlags.isDemoModeAvailable, false);
      expect(dependencies.featureFlags.isAnalyticsEnabled, false);
    });
  });
}
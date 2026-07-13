import 'package:flutter_app/core/config/app_config.dart';
import 'package:flutter_app/core/feature_flags/feature_flags.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('production config uses production environment', () {
      const config = AppConfig.production();

      expect(config.appName, 'OrangeONE');
      expect(config.environment, AppEnvironment.production);
      expect(config.isProduction, true);
      expect(config.isDevelopment, false);
      expect(config.isStaging, false);
      expect(config.featureFlags.demoModeAvailable, true);
    });

    test('supports development config', () {
      const config = AppConfig(
        appName: 'OrangeONE Dev',
        environment: AppEnvironment.development,
        featureFlags: FeatureFlags.disabled(),
      );

      expect(config.appName, 'OrangeONE Dev');
      expect(config.environment, AppEnvironment.development);
      expect(config.isDevelopment, true);
      expect(config.isProduction, false);
      expect(config.featureFlags.demoModeAvailable, false);
    });

    test('supports staging config', () {
      const config = AppConfig(
        appName: 'OrangeONE Staging',
        environment: AppEnvironment.staging,
        featureFlags: FeatureFlags.production(),
      );

      expect(config.appName, 'OrangeONE Staging');
      expect(config.environment, AppEnvironment.staging);
      expect(config.isStaging, true);
      expect(config.isProduction, false);
    });
  });
}

import 'package:flutter_app/core/config/app_config.dart';

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
      expect(config.environmentName, 'production');
    });

    test('development config uses development environment', () {
      const config = AppConfig.development();

      expect(config.appName, 'OrangeONE Dev');
      expect(config.environment, AppEnvironment.development);
      expect(config.environmentName, 'development');
      expect(config.isDevelopment, true);
      expect(config.isProduction, false);
      expect(config.featureFlags.demoModeAvailable, false);
    });

    test('staging config uses staging environment', () {
      const config = AppConfig.staging();

      expect(config.appName, 'OrangeONE Staging');
      expect(config.environment, AppEnvironment.staging);
      expect(config.environmentName, 'staging');
      expect(config.isStaging, true);
      expect(config.isProduction, false);
    });
  });
}

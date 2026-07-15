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

    test('fromEnvironment defaults to production', () {
      final config = AppConfig.fromEnvironment();

      expect(config.environment, AppEnvironment.production);
      expect(config.appName, 'OrangeONE');
    });

    test('fromEnvironment supports development aliases', () {
      expect(
        AppConfig.fromEnvironment(environmentName: 'development').environment,
        AppEnvironment.development,
      );
      expect(
        AppConfig.fromEnvironment(environmentName: 'dev').environment,
        AppEnvironment.development,
      );
    });

    test('fromEnvironment supports staging aliases', () {
      expect(
        AppConfig.fromEnvironment(environmentName: 'staging').environment,
        AppEnvironment.staging,
      );
      expect(
        AppConfig.fromEnvironment(environmentName: 'stage').environment,
        AppEnvironment.staging,
      );
    });

    test('fromEnvironment supports production aliases', () {
      expect(
        AppConfig.fromEnvironment(environmentName: 'production').environment,
        AppEnvironment.production,
      );
      expect(
        AppConfig.fromEnvironment(environmentName: 'prod').environment,
        AppEnvironment.production,
      );
    });

    test('fromEnvironment falls back to production for unknown values', () {
      final config = AppConfig.fromEnvironment(environmentName: 'unknown');

      expect(config.environment, AppEnvironment.production);
    });
  });
}

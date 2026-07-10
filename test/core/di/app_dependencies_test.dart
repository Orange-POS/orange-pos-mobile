import 'package:flutter_app/core/config/app_config.dart';
import 'package:flutter_app/core/di/app_dependencies.dart';
import 'package:flutter_app/core/feature_flags/feature_flag_controller.dart';
import 'package:flutter_app/core/feature_flags/feature_flags.dart';
import 'package:flutter_app/features/products/data/product_repository_factory.dart';
import 'package:flutter_app/services/analytics_service.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/services/session_service.dart';
import 'package:flutter_app/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/services/crash_reporting_service.dart';
import 'package:flutter_app/core/feature_flags/feature_flag_provider.dart';
import 'package:flutter_app/features/auth/application/auth_use_cases.dart';
import 'package:flutter_app/services/api_client.dart';

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

    test('creates default app dependencies', () {
      final dependencies = AppDependencies();

      expect(dependencies.config, isA<AppConfig>());
      expect(dependencies.featureFlags, isA<FeatureFlagController>());
      expect(
        dependencies.productRepositoryFactory,
        isA<ProductRepositoryFactory>(),
      );
      expect(dependencies.analyticsService, isA<AnalyticsService>());
      expect(dependencies.authService, isA<AuthService>());
      expect(dependencies.sessionService, isA<SessionService>());
      expect(dependencies.tokenStorage, isA<TokenStorage>());
      expect(dependencies.crashReportingService, isA<CrashReportingService>());
      expect(dependencies.featureFlagProvider, isA<FeatureFlagProvider>());
    });

    test('uses provided feature flag controller', () {
      final featureFlags = FeatureFlagController();

      final dependencies = AppDependencies(featureFlags: featureFlags);

      expect(dependencies.featureFlags, same(featureFlags));
    });

    test('creates auth use cases by default', () {
      final dependencies = AppDependencies();

      expect(dependencies.authUseCases, isA<AuthUseCases>());
    });

    test('auth use cases reuse dependency service instances', () {
      final authService = AuthService();
      final sessionService = SessionService();
      final tokenStorage = TokenStorage.instance;

      final dependencies = AppDependencies(
        authService: authService,
        sessionService: sessionService,
        tokenStorage: tokenStorage,
      );

      expect(
        identical(dependencies.authUseCases.authService, authService),
        isTrue,
      );
      expect(
        identical(dependencies.authUseCases.sessionService, sessionService),
        isTrue,
      );
      expect(
        identical(dependencies.authUseCases.tokenStorage, tokenStorage),
        isTrue,
      );
    });

    test('creates an api client by default', () {
      final dependencies = AppDependencies();

      expect(dependencies.apiClient, isA<ApiClient>());
    });

    test('uses injected api client for default API services', () {
      final apiClient = ApiClient();

      final dependencies = AppDependencies(apiClient: apiClient);

      expect(identical(dependencies.apiClient, apiClient), isTrue);
      expect(
        identical(dependencies.analyticsService.apiClient, apiClient),
        isTrue,
      );
      expect(identical(dependencies.authService.apiClient, apiClient), isTrue);
      expect(
        identical(dependencies.sessionService.apiClient, apiClient),
        isTrue,
      );
    });
  });
}

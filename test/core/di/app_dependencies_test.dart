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
import 'package:flutter_app/core/crash/crash_test_service.dart';
import 'package:flutter_app/core/crash/firebase_crash_test_service.dart';
import 'package:flutter_app/core/errors/app_error_reporter.dart';
import 'package:flutter_app/core/analytics/observable_analytics_service.dart';

void main() {
  group('AppDependencies', () {
    test('uses production config by default', () {
      final dependencies = AppDependencies();

      expect(dependencies.config.appName, 'OrangeONE');
      expect(dependencies.config.isProduction, true);
      expect(dependencies.featureFlags.isDemoModeAvailable, true);
      expect(dependencies.appErrorReporter, isA<AppErrorReporter>());
      expect(
        dependencies.observableAnalyticsService,
        isA<ObservableAnalyticsService>(),
      );
    });

    test('uses feature flags from provided config', () {
      const config = AppConfig(
        appName: 'OrangeONE Dev',
        environment: AppEnvironment.development,
        featureFlags: FeatureFlags.disabled(),
        crashTestEnabled: false,
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
      expect(dependencies.crashReporter, isA<CrashReportingService>());
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

    test('uses production environment config by default', () {
      final dependencies = AppDependencies();

      expect(dependencies.config.environment, AppEnvironment.production);
      expect(dependencies.config.appName, 'OrangeONE');
    });

    test('uses provided config when supplied', () {
      final dependencies = AppDependencies(config: const AppConfig.staging());

      expect(dependencies.config.environment, AppEnvironment.staging);
      expect(dependencies.config.appName, 'OrangeONE Staging');
    });

    test('uses disabled crash test service by default', () {
      final dependencies = AppDependencies();

      expect(dependencies.crashTestService, isA<DisabledCrashTestService>());
    });

    test('uses Firebase crash test service when crash testing is enabled', () {
      final dependencies = AppDependencies(
        config: const AppConfig.production(crashTestEnabled: true),
      );

      expect(dependencies.crashTestService, isA<FirebaseCrashTestService>());
    });

    test('app error reporter reuses crash reporter and config', () {
      final crashReporter = CrashReportingService();
      const config = AppConfig.staging();

      final dependencies = AppDependencies(
        config: config,
        crashReporter: crashReporter,
      );

      expect(dependencies.appErrorReporter.crashReporter, same(crashReporter));
      expect(dependencies.appErrorReporter.config, same(config));
    });
    test(
      'observable analytics service reuses analytics and error reporter',
      () {
        final analyticsService = AnalyticsService();
        final appErrorReporter = AppErrorReporter(
          crashReporter: CrashReportingService(),
          config: const AppConfig.production(),
        );

        final dependencies = AppDependencies(
          analyticsService: analyticsService,
          appErrorReporter: appErrorReporter,
        );

        expect(
          dependencies.observableAnalyticsService.analyticsService,
          same(analyticsService),
        );
        expect(
          dependencies.observableAnalyticsService.appErrorReporter,
          same(appErrorReporter),
        );
      },
    );
  });
}

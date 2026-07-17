import '../../features/auth/application/auth_use_cases.dart';
import '../../features/products/data/product_repository_factory.dart';
import '../../services/analytics_service.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/crash_reporting_service.dart';
import '../../services/session_service.dart';
import '../../services/token_storage.dart';
import '../config/app_config.dart';
import '../feature_flags/feature_flag_controller.dart';
import '../feature_flags/feature_flag_provider.dart';
import '../crash/crash_reporter.dart';

class AppDependencies {
  final AppConfig config;
  final FeatureFlagController featureFlags;
  final ProductRepositoryFactory productRepositoryFactory;
  final AnalyticsService analyticsService;
  final AuthService authService;
  final SessionService sessionService;
  final TokenStorage tokenStorage;
  final CrashReporter crashReporter;
  final FeatureFlagProvider featureFlagProvider;
  final AuthUseCases authUseCases;
  final ApiClient apiClient;

  factory AppDependencies({
    AppConfig? config,
    FeatureFlagController? featureFlags,
    FeatureFlagProvider? featureFlagProvider,
    ProductRepositoryFactory? productRepositoryFactory,
    ApiClient? apiClient,
    AnalyticsService? analyticsService,
    AuthService? authService,
    SessionService? sessionService,
    TokenStorage? tokenStorage,
    CrashReporter? crashReporter,
    AuthUseCases? authUseCases,
  }) {
    final resolvedApiClient = apiClient ?? ApiClient();
    final resolvedAuthService =
        authService ?? AuthService(apiClient: resolvedApiClient);
    final resolvedSessionService =
        sessionService ?? SessionService(apiClient: resolvedApiClient);
    final resolvedTokenStorage = tokenStorage ?? TokenStorage.instance;
    final resolvedConfig = config ?? AppConfig.fromEnvironment();
    return AppDependencies._(
      config: resolvedConfig,
      featureFlags:
          featureFlags ??
          FeatureFlagController(flags: resolvedConfig.featureFlags),
      featureFlagProvider:
          featureFlagProvider ??
          LocalFeatureFlagProvider(flags: resolvedConfig.featureFlags),
      productRepositoryFactory:
          productRepositoryFactory ?? ProductRepositoryFactory(),
      apiClient: resolvedApiClient,
      analyticsService:
          analyticsService ?? AnalyticsService(apiClient: resolvedApiClient),
      authService: resolvedAuthService,
      sessionService: resolvedSessionService,
      tokenStorage: resolvedTokenStorage,
      crashReporter: crashReporter ?? CrashReportingService(),
      authUseCases:
          authUseCases ??
          AuthUseCases(
            authService: resolvedAuthService,
            sessionService: resolvedSessionService,
            tokenStorage: resolvedTokenStorage,
          ),
    );
  }

  const AppDependencies._({
    required this.config,
    required this.featureFlags,
    required this.featureFlagProvider,
    required this.productRepositoryFactory,
    required this.apiClient,
    required this.analyticsService,
    required this.authService,
    required this.sessionService,
    required this.tokenStorage,
    required this.crashReporter,
    required this.authUseCases,
  });
}

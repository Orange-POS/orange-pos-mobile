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
import '../crash/crash_test_service.dart';
import '../crash/firebase_crash_test_service.dart';
import '../errors/app_error_reporter.dart';

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
  final CrashTestService crashTestService;
  final AppErrorReporter appErrorReporter;

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
    CrashTestService? crashTestService,
    AppErrorReporter? appErrorReporter,
  }) {
    final resolvedApiClient = apiClient ?? ApiClient();
    final resolvedAuthService =
        authService ?? AuthService(apiClient: resolvedApiClient);
    final resolvedSessionService =
        sessionService ?? SessionService(apiClient: resolvedApiClient);
    final resolvedTokenStorage = tokenStorage ?? TokenStorage.instance;
    final resolvedConfig = config ?? AppConfig.fromEnvironment();
    final resolvedCrashReporter = crashReporter ?? CrashReportingService();

    final resolvedAppErrorReporter =
        appErrorReporter ??
        AppErrorReporter(
          crashReporter: resolvedCrashReporter,
          config: resolvedConfig,
        );
    final resolvedCrashTestService =
        crashTestService ??
        (resolvedConfig.crashTestEnabled
            ? FirebaseCrashTestService()
            : const DisabledCrashTestService());
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
      appErrorReporter: resolvedAppErrorReporter,
      authUseCases:
          authUseCases ??
          AuthUseCases(
            authService: resolvedAuthService,
            sessionService: resolvedSessionService,
            tokenStorage: resolvedTokenStorage,
          ),
      crashTestService: resolvedCrashTestService,
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
    required this.crashTestService,
    required this.appErrorReporter,
  });
}

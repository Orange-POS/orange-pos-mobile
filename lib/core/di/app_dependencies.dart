import '../../features/auth/application/auth_use_cases.dart';
import '../../features/products/data/product_repository_factory.dart';
import '../../services/analytics_service.dart';
import '../../services/auth_service.dart';
import '../../services/crash_reporting_service.dart';
import '../../services/session_service.dart';
import '../../services/token_storage.dart';
import '../config/app_config.dart';
import '../feature_flags/feature_flag_controller.dart';
import '../feature_flags/feature_flag_provider.dart';

class AppDependencies {
  final AppConfig config;
  final FeatureFlagController featureFlags;
  final ProductRepositoryFactory productRepositoryFactory;
  final AnalyticsService analyticsService;
  final AuthService authService;
  final SessionService sessionService;
  final TokenStorage tokenStorage;
  final CrashReportingService crashReportingService;
  final FeatureFlagProvider featureFlagProvider;
  final AuthUseCases authUseCases;

  AppDependencies({
    AppConfig config = const AppConfig.production(),
    FeatureFlagController? featureFlags,
    FeatureFlagProvider? featureFlagProvider,
    ProductRepositoryFactory productRepositoryFactory =
        const ProductRepositoryFactory(),
    AnalyticsService? analyticsService,
    AuthService? authService,
    SessionService? sessionService,
    TokenStorage? tokenStorage,
    CrashReportingService? crashReportingService,
    AuthUseCases? authUseCases,
  }) : this._(
         config: config,
         featureFlags:
             featureFlags ?? FeatureFlagController(flags: config.featureFlags),
         featureFlagProvider:
             featureFlagProvider ??
             LocalFeatureFlagProvider(flags: config.featureFlags),
         productRepositoryFactory: productRepositoryFactory,
         analyticsService: analyticsService ?? AnalyticsService(),
         authService: authService ?? AuthService(),
         sessionService: sessionService ?? SessionService(),
         tokenStorage: tokenStorage ?? TokenStorage.instance,
         crashReportingService:
             crashReportingService ?? CrashReportingService(),
         authUseCases: authUseCases,
       );

  AppDependencies._({
    required this.config,
    required this.featureFlags,
    required this.featureFlagProvider,
    required this.productRepositoryFactory,
    required this.analyticsService,
    required this.authService,
    required this.sessionService,
    required this.tokenStorage,
    required this.crashReportingService,
    AuthUseCases? authUseCases,
  }) : authUseCases =
           authUseCases ??
           AuthUseCases(
             authService: authService,
             sessionService: sessionService,
             tokenStorage: tokenStorage,
           );
}

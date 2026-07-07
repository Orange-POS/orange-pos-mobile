import '../../features/products/data/product_repository_factory.dart';
import '../../services/analytics_service.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';
import '../../services/token_storage.dart';
import '../config/app_config.dart';
import '../feature_flags/feature_flag_controller.dart';
import '../../services/crash_reporting_service.dart';
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

  AppDependencies({
    AppConfig config = const AppConfig.production(),
    FeatureFlagController? featureFlags,
    FeatureFlagProvider? featureFlagProvider,
    ProductRepositoryFactory? productRepositoryFactory,
    AnalyticsService? analyticsService,
    AuthService? authService,
    SessionService? sessionService,
    TokenStorage? tokenStorage,
    CrashReportingService? crashReportingService,
  }) : config = config,
       featureFlags =
           featureFlags ?? FeatureFlagController(flags: config.featureFlags),
       featureFlagProvider =
           featureFlagProvider ??
           LocalFeatureFlagProvider(flags: config.featureFlags),
       productRepositoryFactory =
           productRepositoryFactory ?? const ProductRepositoryFactory(),
       analyticsService = analyticsService ?? AnalyticsService(),
       authService = authService ?? AuthService(),
       sessionService = sessionService ?? SessionService(),
       tokenStorage = tokenStorage ?? TokenStorage.instance,
       crashReportingService = crashReportingService ?? CrashReportingService();
}

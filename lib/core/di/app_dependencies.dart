import '../config/app_config.dart';
import '../feature_flags/feature_flag_controller.dart';

class AppDependencies {
  final AppConfig config;
  final FeatureFlagController featureFlags;

  AppDependencies({
    AppConfig config = const AppConfig.production(),
    FeatureFlagController? featureFlags,
  }) : config = config,
       featureFlags =
           featureFlags ?? FeatureFlagController(flags: config.featureFlags);
}

import 'feature_flags.dart';
import 'feature_flag_provider.dart';

class FeatureFlagController {
  FeatureFlags _flags;
  bool _demoModeEnabled;

  FeatureFlagController({
    FeatureFlags flags = const FeatureFlags.production(),
    bool demoModeEnabled = false,
  }) : this._(flags, demoModeEnabled);

  FeatureFlagController._(this._flags, this._demoModeEnabled);

  FeatureFlags get flags => _flags;

  Future<void> refreshFromProvider(FeatureFlagProvider provider) async {
    final latestFlags = await provider.loadFlags();
    updateFlags(latestFlags);
  }

  bool get isDemoModeAvailable {
    return _flags.demoModeAvailable;
  }

  bool get isDemoModeEnabled {
    return _flags.demoModeAvailable && _demoModeEnabled;
  }

  bool get isAnalyticsEnabled {
    return _flags.analyticsEnabled;
  }

  bool get isCrashReportingEnabled {
    return _flags.crashReportingEnabled;
  }

  bool get isRemoteConfigEnabled {
    return _flags.remoteConfigEnabled;
  }

  void enableDemoMode() {
    if (!_flags.demoModeAvailable) {
      return;
    }

    _demoModeEnabled = true;
  }

  void disableDemoMode() {
    _demoModeEnabled = false;
  }

  void updateFlags(FeatureFlags flags) {
    _flags = flags;

    if (!_flags.demoModeAvailable) {
      _demoModeEnabled = false;
    }
  }
}

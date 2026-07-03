class FeatureFlags {
  final bool demoModeAvailable;
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool remoteConfigEnabled;

  const FeatureFlags({
    required this.demoModeAvailable,
    required this.analyticsEnabled,
    required this.crashReportingEnabled,
    required this.remoteConfigEnabled,
  });

  const FeatureFlags.production()
    : demoModeAvailable = true,
      analyticsEnabled = true,
      crashReportingEnabled = false,
      remoteConfigEnabled = false;

  const FeatureFlags.disabled()
    : demoModeAvailable = false,
      analyticsEnabled = false,
      crashReportingEnabled = false,
      remoteConfigEnabled = false;
}

import 'package:flutter_app/core/feature_flags/feature_flag_provider.dart';
import 'package:flutter_app/core/feature_flags/feature_flags.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalFeatureFlagProvider', () {
    test('loads production flags by default', () async {
      const provider = LocalFeatureFlagProvider();

      final flags = await provider.loadFlags();

      expect(flags.demoModeAvailable, true);
      expect(flags.analyticsEnabled, true);
      expect(flags.crashReportingEnabled, false);
      expect(flags.remoteConfigEnabled, false);
    });

    test('loads provided flags', () async {
      const provider = LocalFeatureFlagProvider(flags: FeatureFlags.disabled());

      final flags = await provider.loadFlags();

      expect(flags.demoModeAvailable, false);
      expect(flags.analyticsEnabled, false);
      expect(flags.crashReportingEnabled, false);
      expect(flags.remoteConfigEnabled, false);
    });
  });
}

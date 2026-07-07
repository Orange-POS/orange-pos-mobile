import 'package:flutter_app/core/feature_flags/feature_flag_controller.dart';
import 'package:flutter_app/core/feature_flags/feature_flags.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/feature_flags/feature_flag_provider.dart';

void main() {
  group('FeatureFlagController', () {
    test('uses production flags by default', () {
      final controller = FeatureFlagController();

      expect(controller.isDemoModeAvailable, true);
      expect(controller.isDemoModeEnabled, false);
      expect(controller.isAnalyticsEnabled, true);
      expect(controller.isCrashReportingEnabled, false);
      expect(controller.isRemoteConfigEnabled, false);
    });

    test('enables demo mode when available', () {
      final controller = FeatureFlagController();

      controller.enableDemoMode();

      expect(controller.isDemoModeEnabled, true);
    });

    test('does not enable demo mode when unavailable', () {
      final controller = FeatureFlagController(
        flags: const FeatureFlags.disabled(),
      );

      controller.enableDemoMode();

      expect(controller.isDemoModeAvailable, false);
      expect(controller.isDemoModeEnabled, false);
    });

    test('disables demo mode', () {
      final controller = FeatureFlagController();

      controller.enableDemoMode();
      controller.disableDemoMode();

      expect(controller.isDemoModeEnabled, false);
    });

    test('turns off demo mode when updated flags disable it', () {
      final controller = FeatureFlagController();

      controller.enableDemoMode();
      controller.updateFlags(const FeatureFlags.disabled());

      expect(controller.isDemoModeAvailable, false);
      expect(controller.isDemoModeEnabled, false);
    });

    test('refreshes flags from provider', () async {
      final controller = FeatureFlagController();

      controller.enableDemoMode();

      await controller.refreshFromProvider(
        const LocalFeatureFlagProvider(flags: FeatureFlags.disabled()),
      );

      expect(controller.isDemoModeAvailable, false);
      expect(controller.isDemoModeEnabled, false);
      expect(controller.isAnalyticsEnabled, false);
      expect(controller.isCrashReportingEnabled, false);
      expect(controller.isRemoteConfigEnabled, false);
    });
  });
}

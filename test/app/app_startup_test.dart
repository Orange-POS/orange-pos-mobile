import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/app_startup.dart';
import 'package:flutter_app/app/inventory_tracker_app.dart';
import 'package:flutter_app/core/crash/crash_reporter.dart';
import 'package:flutter_app/core/di/app_dependencies.dart';
import 'package:flutter_app/core/feature_flags/feature_flag_controller.dart';
import 'package:flutter_app/core/feature_flags/feature_flag_provider.dart';
import 'package:flutter_app/core/feature_flags/feature_flags.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:ui';

void main() {
  group('startOrangeOneApp', () {
    FlutterExceptionHandler? originalFlutterErrorHandler;
    ErrorCallback? originalPlatformErrorHandler;

    setUp(() {
      originalFlutterErrorHandler = FlutterError.onError;
      originalPlatformErrorHandler = PlatformDispatcher.instance.onError;
    });

    tearDown(() {
      FlutterError.onError = originalFlutterErrorHandler;
      PlatformDispatcher.instance.onError = originalPlatformErrorHandler;
    });

    test(
      'routes Flutter framework errors to the resolved crash reporter',
      () async {
        final crashReporter = _RecordingCrashReporter();
        final dependencies = AppDependencies(
          featureFlags: FeatureFlagController(),
          featureFlagProvider: const LocalFeatureFlagProvider(),
        );

        await startOrangeOneApp(
          dependencies: dependencies,
          crashReporter: crashReporter,
          appRunner: (_) {},
        );

        final details = FlutterErrorDetails(
          exception: Exception('flutter framework error'),
          stack: StackTrace.current,
          context: ErrorDescription('unit test'),
        );

        FlutterError.onError!(details);

        expect(crashReporter.flutterErrorDetails, same(details));
      },
    );

    test('refreshes feature flags before running the app', () async {
      final provider = _FakeFeatureFlagProvider(
        flags: const FeatureFlags(
          demoModeAvailable: true,
          analyticsEnabled: false,
          crashReportingEnabled: true,
          remoteConfigEnabled: false,
        ),
      );

      final dependencies = AppDependencies(
        featureFlags: FeatureFlagController(),
        featureFlagProvider: provider,
      );

      Widget? startedApp;

      await startOrangeOneApp(
        dependencies: dependencies,
        crashReporter: _RecordingCrashReporter(),
        appRunner: (app) {
          startedApp = app;
        },
      );

      expect(provider.loadFlagsCalled, isTrue);
      expect(dependencies.featureFlags.isDemoModeAvailable, isTrue);
      expect(startedApp, isA<ProviderScope>());
    });

    test(
      'routes platform dispatcher errors to the resolved crash reporter',
      () async {
        final crashReporter = _RecordingCrashReporter();
        final dependencies = AppDependencies(
          featureFlags: FeatureFlagController(),
          featureFlagProvider: const LocalFeatureFlagProvider(),
        );

        await startOrangeOneApp(
          dependencies: dependencies,
          crashReporter: crashReporter,
          appRunner: (_) {},
        );

        final error = Exception('platform dispatcher error');
        final stackTrace = StackTrace.current;

        final handled = PlatformDispatcher.instance.onError!(error, stackTrace);

        await Future<void>.delayed(Duration.zero);

        expect(handled, isTrue);
        expect(crashReporter.error, same(error));
        expect(crashReporter.stackTrace, same(stackTrace));
        expect(crashReporter.reason, 'Uncaught platform dispatcher error');
        expect(crashReporter.fatal, isTrue);
      },
    );

    test(
      'wraps InventoryTrackerApp with the dependency provider override',
      () async {
        final dependencies = AppDependencies();

        Widget? startedApp;

        await startOrangeOneApp(
          dependencies: dependencies,
          crashReporter: _RecordingCrashReporter(),
          appRunner: (app) {
            startedApp = app;
          },
        );

        final providerScope = startedApp as ProviderScope;

        expect(providerScope.child, isA<InventoryTrackerApp>());
      },
    );
  });

  group('recordUncaughtAsyncError', () {
    test('records uncaught async errors as fatal reports', () async {
      final crashReporter = _RecordingCrashReporter();
      final error = Exception('async failure');
      final stackTrace = StackTrace.current;

      await recordUncaughtAsyncError(
        crashReporter: crashReporter,
        error: error,
        stackTrace: stackTrace,
      );

      expect(crashReporter.error, same(error));
      expect(crashReporter.stackTrace, same(stackTrace));
      expect(crashReporter.reason, 'Uncaught async error');
      expect(crashReporter.fatal, isTrue);
    });
  });
}

class _FakeFeatureFlagProvider implements FeatureFlagProvider {
  final FeatureFlags flags;
  bool loadFlagsCalled = false;

  _FakeFeatureFlagProvider({required this.flags});

  @override
  Future<FeatureFlags> loadFlags() async {
    loadFlagsCalled = true;
    return flags;
  }
}

class _RecordingCrashReporter implements CrashReporter {
  FlutterErrorDetails? flutterErrorDetails;
  Object? error;
  StackTrace? stackTrace;
  String? reason;
  bool? fatal;

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    flutterErrorDetails = details;
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    this.error = error;
    this.stackTrace = stackTrace;
    this.reason = reason;
    this.fatal = fatal;
  }
}

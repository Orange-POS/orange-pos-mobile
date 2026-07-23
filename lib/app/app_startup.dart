import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/crash/crash_reporter.dart';
import '../core/di/app_dependencies.dart';
import '../core/providers/app_dependencies_provider.dart';
import 'inventory_tracker_app.dart';

typedef AppRunner = void Function(Widget app);

Future<void> startOrangeOneApp({
  required AppDependencies dependencies,
  required CrashReporter crashReporter,
  AppRunner appRunner = runApp,
}) async {
  FlutterError.onError = crashReporter.recordFlutterError;

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    unawaited(
      crashReporter.recordError(
        error,
        stackTrace,
        reason: 'Uncaught platform dispatcher error',
        fatal: true,
      ),
    );

    return true;
  };

  await dependencies.featureFlags.refreshFromProvider(
    dependencies.featureFlagProvider,
  );

  appRunner(
    ProviderScope(
      overrides: [appDependenciesProvider.overrideWithValue(dependencies)],
      child: InventoryTrackerApp(dependencies: dependencies),
    ),
  );
}

Future<void> recordUncaughtAsyncError({
  required CrashReporter crashReporter,
  required Object error,
  required StackTrace stackTrace,
}) {
  return crashReporter.recordError(
    error,
    stackTrace,
    reason: 'Uncaught async error',
    fatal: true,
  );
}

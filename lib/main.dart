import 'dart:async';

import 'package:flutter/material.dart';

import 'app/inventory_tracker_app.dart';
import 'core/di/app_dependencies.dart';
import 'core/firebase/firebase_app_startup.dart';
import 'core/crash/crash_reporter_resolver.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = AppDependencies();
  final crashReporter = await CrashReporterResolver(
    firebaseAppStartup: const FirebaseAppStartup(),
    fallbackCrashReporter: dependencies.crashReporter,
  ).resolve();

  runZonedGuarded(
    () async {
      FlutterError.onError = crashReporter.recordFlutterError;

      await dependencies.featureFlags.refreshFromProvider(
        dependencies.featureFlagProvider,
      );

      runApp(InventoryTrackerApp(dependencies: dependencies));
    },
    (error, stackTrace) async {
      await crashReporter.recordError(
        error,
        stackTrace,
        reason: 'Uncaught async error',
        fatal: true,
      );
    },
  );
}

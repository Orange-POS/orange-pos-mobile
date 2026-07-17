import 'dart:async';

import 'package:flutter/material.dart';

import 'app/app_startup.dart';

import 'core/crash/crash_reporter_resolver.dart';
import 'core/di/app_dependencies.dart';
import 'core/firebase/firebase_app_startup.dart';
import 'services/crash_reporting_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final fallbackCrashReporter = CrashReportingService();

  runZonedGuarded(
    () async {
      final bootstrapDependencies = AppDependencies(
        crashReporter: fallbackCrashReporter,
      );

      final crashReporter = await CrashReporterResolver(
        firebaseAppStartup: const FirebaseAppStartup(),
        fallbackCrashReporter: fallbackCrashReporter,
      ).resolve();

      final dependencies = AppDependencies(
        config: bootstrapDependencies.config,
        crashReporter: crashReporter,
      );

      await startOrangeOneApp(
        dependencies: dependencies,
        crashReporter: crashReporter,
      );
    },
    (error, stackTrace) async {
      await recordUncaughtAsyncError(
        crashReporter: fallbackCrashReporter,
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}

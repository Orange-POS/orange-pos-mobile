import 'dart:async';

import 'package:flutter/material.dart';

import 'app/inventory_tracker_app.dart';
import 'core/di/app_dependencies.dart';

Future<void> main() async {
  final dependencies = AppDependencies();

  runZonedGuarded(
    () async {
      FlutterError.onError = dependencies.crashReporter.recordFlutterError;

      await dependencies.featureFlags.refreshFromProvider(
        dependencies.featureFlagProvider,
      );

      runApp(InventoryTrackerApp(dependencies: dependencies));
    },
    (error, stackTrace) async {
      await dependencies.crashReporter.recordError(
        error,
        stackTrace,
        reason: 'Uncaught async error',
        fatal: true,
      );
    },
  );
}

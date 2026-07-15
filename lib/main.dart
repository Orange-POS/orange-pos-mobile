import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'app/inventory_tracker_app.dart';
import 'core/di/app_dependencies.dart';
import 'core/providers/app_dependencies_provider.dart';

Future<void> main() async {
  final dependencies = AppDependencies();

  runZonedGuarded(
    () async {
      FlutterError.onError =
          dependencies.crashReportingService.recordFlutterError;

      await dependencies.featureFlags.refreshFromProvider(
        dependencies.featureFlagProvider,
      );

      runApp(
        ProviderScope(
          overrides: [appDependenciesProvider.overrideWithValue(dependencies)],
          child: InventoryTrackerApp(dependencies: dependencies),
        ),
      );
    },
    (error, stackTrace) async {
      await dependencies.crashReportingService.recordError(
        error,
        stackTrace,
        reason: 'Uncaught async error',
        fatal: true,
      );
    },
  );
}

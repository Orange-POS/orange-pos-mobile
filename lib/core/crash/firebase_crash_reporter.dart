import 'package:flutter/foundation.dart';

import 'crash_reporter.dart';
import 'crashlytics_client.dart';

class FirebaseCrashReporter implements CrashReporter {
  final CrashlyticsClient crashlyticsClient;

  const FirebaseCrashReporter({required this.crashlyticsClient});

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) {
    return crashlyticsClient.recordFlutterError(details);
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) {
    return crashlyticsClient.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }
}

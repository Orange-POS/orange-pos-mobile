import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'crashlytics_client.dart';

class FirebaseCrashlyticsClient implements CrashlyticsClient {
  final FirebaseCrashlytics crashlytics;

  FirebaseCrashlyticsClient({FirebaseCrashlytics? crashlytics})
    : crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) {
    return crashlytics.recordFlutterError(details);
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) {
    return crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) {
    return crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }
}

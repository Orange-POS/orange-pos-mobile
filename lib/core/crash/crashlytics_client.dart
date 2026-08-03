import 'package:flutter/foundation.dart';

abstract class CrashlyticsClient {
  Future<void> recordFlutterError(FlutterErrorDetails details);

  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  });

  Future<void> setCrashlyticsCollectionEnabled(bool enabled);
}

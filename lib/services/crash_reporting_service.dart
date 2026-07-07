import 'package:flutter/foundation.dart';

class CrashReportingService {
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    FlutterError.presentError(details);

    await recordError(
      details.exception,
      details.stack,
      reason: details.context?.toDescription(),
      fatal: false,
    );
  }

  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    debugPrint('Crash report captured');
    debugPrint('Fatal: $fatal');

    if (reason != null && reason.isNotEmpty) {
      debugPrint('Reason: $reason');
    }

    debugPrint('Error: $error');

    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }
}

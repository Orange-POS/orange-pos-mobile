import 'package:flutter/foundation.dart';

import '../core/crash/crash_reporter.dart';

typedef FlutterErrorPresenter = void Function(FlutterErrorDetails details);

class CrashReportingService implements CrashReporter {
  final FlutterErrorPresenter presentFlutterError;

  CrashReportingService({FlutterErrorPresenter? presentFlutterError})
    : presentFlutterError = presentFlutterError ?? FlutterError.presentError;

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    presentFlutterError(details);

    await recordError(
      details.exception,
      details.stack,
      reason: details.context?.toDescription(),
      fatal: false,
    );
  }

  @override
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

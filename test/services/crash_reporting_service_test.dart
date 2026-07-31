import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/crash/crash_reporter.dart';
import 'package:flutter_app/services/crash_reporting_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrashReportingService', () {
    test('implements CrashReporter', () {
      final service = CrashReportingService();

      expect(service, isA<CrashReporter>());
    });

    test('records non-fatal errors without throwing', () async {
      final service = CrashReportingService();

      await service.recordError(
        Exception('test error'),
        StackTrace.current,
        reason: 'unit test',
      );
    });

    test(
      'records Flutter errors as non-fatal reports with original details',
      () async {
        var didPresentError = false;
        final exception = Exception('flutter error');
        final stackTrace = StackTrace.current;
        final details = FlutterErrorDetails(
          exception: exception,
          stack: stackTrace,
          context: ErrorDescription('unit test context'),
        );

        final service = _RecordingCrashReportingService(
          presentFlutterError: (details) {
            didPresentError = true;
          },
        );

        await service.recordFlutterError(details);

        expect(didPresentError, isTrue);
        expect(service.recordedError, same(exception));
        expect(service.recordedStackTrace, same(stackTrace));
        expect(service.recordedReason, 'unit test context');
        expect(service.recordedFatal, isFalse);
      },
    );
  });
}

class _RecordingCrashReportingService extends CrashReportingService {
  Object? recordedError;
  StackTrace? recordedStackTrace;
  String? recordedReason;
  bool? recordedFatal;

  _RecordingCrashReportingService({required super.presentFlutterError});

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    recordedError = error;
    recordedStackTrace = stackTrace;
    recordedReason = reason;
    recordedFatal = fatal;
  }
}

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

    test('records Flutter errors without throwing', () async {
      var didPresentError = false;
      final service = CrashReportingService(
        presentFlutterError: (details) {
          didPresentError = true;
        },
      );

      await service.recordFlutterError(
        FlutterErrorDetails(
          exception: Exception('flutter error'),
          stack: StackTrace.current,
          context: ErrorDescription('unit test context'),
        ),
      );

      expect(didPresentError, isTrue);
    });
  });
}

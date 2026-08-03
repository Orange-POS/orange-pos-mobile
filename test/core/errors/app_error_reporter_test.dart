import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/config/app_config.dart';
import 'package:flutter_app/core/crash/crash_reporter.dart';
import 'package:flutter_app/core/errors/app_error_reporter.dart';
import 'package:flutter_app/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppErrorReporter', () {
    test(
      'reports generic errors as non-fatal with screen and action',
      () async {
        final crashReporter = _FakeCrashReporter();
        final reporter = AppErrorReporter(
          crashReporter: crashReporter,
          config: const AppConfig.production(),
        );

        await reporter.reportError(
          Exception('generic failure'),
          StackTrace.current,
          screen: 'scanner',
          action: 'lookup_product',
        );

        expect(crashReporter.recordedError, isA<Exception>());
        expect(crashReporter.recordedFatal, isFalse);
        expect(
          crashReporter.recordedReason,
          'screen=scanner action=lookup_product environment=production',
        );
      },
    );

    test('adds safe API context without leaking response body', () async {
      final crashReporter = _FakeCrashReporter();
      final reporter = AppErrorReporter(
        crashReporter: crashReporter,
        config: const AppConfig.production(),
      );

      await reporter.reportError(
        ApiClientException(
          uri: Uri.parse('https://example.com/mupi/mobile/api/products/find'),
          message: 'Request failed.',
          statusCode: 500,
          responseBody: 'secret backend response',
        ),
        StackTrace.current,
        screen: 'scanner',
        action: 'lookup_product',
      );

      expect(
        crashReporter.recordedReason,
        'screen=scanner action=lookup_product '
        'environment=production '
        'endpoint=/mupi/mobile/api/products/find '
        'httpStatus=500',
      );
      expect(crashReporter.recordedReason, isNot(contains('secret')));
      expect(crashReporter.recordedFatal, isFalse);
      expect(
        crashReporter.recordedError.toString(),
        contains('API request failed'),
      );
      expect(
        crashReporter.recordedError.toString(),
        isNot(contains('https://example.com')),
      );
      expect(crashReporter.recordedError.toString(), isNot(contains('secret')));
    });
  });
}

class _FakeCrashReporter implements CrashReporter {
  Object? recordedError;
  StackTrace? recordedStackTrace;
  String? recordedReason;
  bool? recordedFatal;

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

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {}
}

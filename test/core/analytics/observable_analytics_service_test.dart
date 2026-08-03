import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/analytics/observable_analytics_service.dart';
import 'package:flutter_app/core/config/app_config.dart';
import 'package:flutter_app/core/crash/crash_reporter.dart';
import 'package:flutter_app/core/errors/app_error_reporter.dart';
import 'package:flutter_app/services/analytics_service.dart';
import 'package:flutter_app/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ObservableAnalyticsService', () {
    test('reports event tracking failures as non-fatal errors', () async {
      final crashReporter = _FakeCrashReporter();
      final service = ObservableAnalyticsService(
        analyticsService: AnalyticsService(
          apiClient: _ThrowingApiClient(),
          swallowFailures: false,
        ),
        appErrorReporter: AppErrorReporter(
          crashReporter: crashReporter,
          config: const AppConfig.production(),
        ),
      );

      await service.trackEvent(
        authToken: 'secret-token',
        backendUrl: 'https://example.com',
        eventName: 'product_scanned',
        screen: 'scanner',
      );

      expect(crashReporter.recordedFatal, isFalse);
      expect(
        crashReporter.recordedReason,
        'screen=scanner action=analytics_event_product_scanned '
        'environment=production endpoint=/analytics httpStatus=none',
      );
      expect(crashReporter.recordedError.toString(), isNot(contains('token')));
      expect(
        crashReporter.recordedError.toString(),
        isNot(contains('https://example.com')),
      );
    });

    test('reports error tracking failures as non-fatal errors', () async {
      final crashReporter = _FakeCrashReporter();
      final service = ObservableAnalyticsService(
        analyticsService: AnalyticsService(
          apiClient: _ThrowingApiClient(),
          swallowFailures: false,
        ),
        appErrorReporter: AppErrorReporter(
          crashReporter: crashReporter,
          config: const AppConfig.production(),
        ),
      );

      await service.trackError(
        authToken: 'secret-token',
        backendUrl: 'https://example.com',
        errorType: 'network',
        screen: 'login',
        message: 'message',
        details: 'secret details',
      );

      expect(crashReporter.recordedFatal, isFalse);
      expect(
        crashReporter.recordedReason,
        'screen=login action=analytics_error_network '
        'environment=production endpoint=/analytics httpStatus=none',
      );
      expect(crashReporter.recordedError.toString(), isNot(contains('token')));
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

class _ThrowingApiClient extends ApiClient {
  @override
  Future<Map<String, dynamic>> postJson({
    required String baseUrl,
    required String endpoint,
    required Map<String, dynamic> body,
    String? authToken,
  }) {
    throw ApiClientException(
      uri: Uri(path: '/analytics'),
      message: 'analytics failed',
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/crash/crash_reporter.dart';
import 'package:flutter_app/core/crash/crashlytics_client.dart';
import 'package:flutter_app/core/crash/firebase_crash_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseCrashReporter', () {
    test('implements CrashReporter', () {
      final reporter = FirebaseCrashReporter(
        crashlyticsClient: _FakeCrashlyticsClient(),
      );

      expect(reporter, isA<CrashReporter>());
    });

    test('records Flutter errors through Crashlytics client', () async {
      final client = _FakeCrashlyticsClient();
      final reporter = FirebaseCrashReporter(crashlyticsClient: client);

      final details = FlutterErrorDetails(
        exception: Exception('flutter error'),
        stack: StackTrace.current,
        context: ErrorDescription('unit test context'),
      );

      await reporter.recordFlutterError(details);

      expect(client.flutterErrorDetails, same(details));
    });

    test('records non-fatal errors through Crashlytics client', () async {
      final client = _FakeCrashlyticsClient();
      final reporter = FirebaseCrashReporter(crashlyticsClient: client);
      final error = Exception('test error');
      final stackTrace = StackTrace.current;

      await reporter.recordError(error, stackTrace, reason: 'unit test');

      expect(client.error, same(error));
      expect(client.stackTrace, same(stackTrace));
      expect(client.reason, 'unit test');
      expect(client.fatal, isFalse);
    });

    test('records fatal errors through Crashlytics client', () async {
      final client = _FakeCrashlyticsClient();
      final reporter = FirebaseCrashReporter(crashlyticsClient: client);
      final error = Exception('fatal error');

      await reporter.recordError(
        error,
        null,
        reason: 'fatal unit test',
        fatal: true,
      );

      expect(client.error, same(error));
      expect(client.stackTrace, isNull);
      expect(client.reason, 'fatal unit test');
      expect(client.fatal, isTrue);
    });
  });
}

class _FakeCrashlyticsClient implements CrashlyticsClient {
  FlutterErrorDetails? flutterErrorDetails;
  Object? error;
  StackTrace? stackTrace;
  String? reason;
  bool? fatal;
  bool? collectionEnabled;

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    flutterErrorDetails = details;
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    this.error = error;
    this.stackTrace = stackTrace;
    this.reason = reason;
    this.fatal = fatal;
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    collectionEnabled = enabled;
  }
}

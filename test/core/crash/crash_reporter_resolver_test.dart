import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/crash/crash_reporter.dart';
import 'package:flutter_app/core/crash/crash_reporter_resolver.dart';
import 'package:flutter_app/core/firebase/firebase_app_startup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrashReporterResolver', () {
    test('returns Firebase reporter when startup succeeds', () async {
      final firebaseReporter = _FakeCrashReporter();
      final fallbackReporter = _FakeCrashReporter();

      final resolver = CrashReporterResolver(
        firebaseAppStartup: _FakeFirebaseAppStartup(
          crashReporter: firebaseReporter,
        ),
        fallbackCrashReporter: fallbackReporter,
      );

      final reporter = await resolver.resolve();

      expect(reporter, same(firebaseReporter));
      expect(fallbackReporter.error, isNull);
    });

    test(
      'falls back and records initialization failure when startup fails',
      () async {
        final fallbackReporter = _FakeCrashReporter();

        final resolver = CrashReporterResolver(
          firebaseAppStartup: _FakeFirebaseAppStartup(
            error: Exception('firebase unavailable'),
          ),
          fallbackCrashReporter: fallbackReporter,
        );

        final reporter = await resolver.resolve();

        expect(reporter, same(fallbackReporter));
        expect(fallbackReporter.error, isA<Exception>());
        expect(
          fallbackReporter.reason,
          'Firebase Crashlytics initialization failed',
        );
        expect(fallbackReporter.fatal, isFalse);
      },
    );
  });
}

class _FakeFirebaseAppStartup extends FirebaseAppStartup {
  final CrashReporter? crashReporter;
  final Object? error;

  const _FakeFirebaseAppStartup({this.crashReporter, this.error});

  @override
  Future<CrashReporter> initializeCrashReporter() async {
    final error = this.error;

    if (error != null) {
      throw error;
    }

    return crashReporter!;
  }
}

class _FakeCrashReporter implements CrashReporter {
  Object? error;
  StackTrace? stackTrace;
  String? reason;
  bool? fatal;
  FlutterErrorDetails? flutterErrorDetails;

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
}

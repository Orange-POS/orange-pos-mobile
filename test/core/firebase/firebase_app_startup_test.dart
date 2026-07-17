import 'package:flutter/foundation.dart';

import 'package:flutter_app/core/crash/crashlytics_client.dart';
import 'package:flutter_app/core/crash/firebase_crash_reporter.dart';
import 'package:flutter_app/core/firebase/firebase_app_startup.dart';
import 'package:flutter_app/core/firebase/firebase_bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseAppStartup', () {
    test('initializes Firebase and enables Crashlytics collection', () async {
      final bootstrap = _FakeFirebaseBootstrap();
      final crashlyticsClient = _FakeCrashlyticsClient();

      final startup = FirebaseAppStartup(
        bootstrap: bootstrap,
        crashlyticsClientFactory: () => crashlyticsClient,
      );

      final reporter = await startup.initializeCrashReporter();

      expect(bootstrap.initializeCalled, isTrue);
      expect(crashlyticsClient.collectionEnabled, isTrue);
      expect(reporter, isA<FirebaseCrashReporter>());
    });

    test('propagates Firebase initialization failure', () async {
      final error = Exception('firebase unavailable');

      final startup = FirebaseAppStartup(
        bootstrap: _FakeFirebaseBootstrap(error: error),
        crashlyticsClientFactory: () => _FakeCrashlyticsClient(),
      );

      await expectLater(
        startup.initializeCrashReporter(),
        throwsA(same(error)),
      );
    });
  });
}

class _FakeFirebaseBootstrap extends FirebaseBootstrap {
  final Object? error;
  bool initializeCalled = false;

  _FakeFirebaseBootstrap({this.error});

  @override
  Future<void> initialize() async {
    initializeCalled = true;

    final error = this.error;
    if (error != null) {
      throw error;
    }
  }
}

class _FakeCrashlyticsClient implements CrashlyticsClient {
  bool? collectionEnabled;

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {}

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    collectionEnabled = enabled;
  }
}

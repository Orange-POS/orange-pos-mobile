import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_app/core/firebase/firebase_bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseBootstrap', () {
    test('initializes Firebase with configured initializer', () async {
      var initializeCalled = false;

      final bootstrap = FirebaseBootstrap(
        initializeApp: () async {
          initializeCalled = true;
          return _FakeFirebaseApp();
        },
      );

      await bootstrap.initialize();

      expect(initializeCalled, isTrue);
    });

    test('propagates Firebase initialization failures', () async {
      final error = Exception('Firebase failed');

      final bootstrap = FirebaseBootstrap(
        initializeApp: () async {
          throw error;
        },
      );

      await expectLater(bootstrap.initialize(), throwsA(same(error)));
    });
  });
}

class _FakeFirebaseApp implements FirebaseApp {
  @override
  String get name => '[DEFAULT]';

  @override
  FirebaseOptions get options {
    return const FirebaseOptions(
      apiKey: 'test-api-key',
      appId: 'test-app-id',
      messagingSenderId: 'test-sender-id',
      projectId: 'test-project-id',
    );
  }

  @override
  bool get isAutomaticDataCollectionEnabled => false;

  @override
  Future<void> delete() async {}

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}

  @override
  T? getService<T extends FirebaseService>() {
    return null;
  }

  @override
  void registerService<T extends FirebaseService>(
    T service, {
    Future<void> Function(T)? dispose,
  }) {}
}

import 'package:flutter_app/core/firebase/firebase_app_startup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseAppStartup', () {
    test('can be constructed', () {
      const startup = FirebaseAppStartup();

      expect(startup, isA<FirebaseAppStartup>());
    });
  });
}

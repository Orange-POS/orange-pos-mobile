import 'package:flutter_app/core/firebase/firebase_bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseBootstrap', () {
    test('can be constructed', () {
      const bootstrap = FirebaseBootstrap();

      expect(bootstrap, isA<FirebaseBootstrap>());
    });
  });
}

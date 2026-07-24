import 'package:flutter_app/core/crash/crash_test_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DisabledCrashTestService', () {
    test('throws when crash testing is disabled', () {
      const service = DisabledCrashTestService();

      expect(service.triggerTestCrash, throwsA(isA<UnsupportedError>()));
    });
  });
}

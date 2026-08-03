import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'crash_test_service.dart';

typedef FirebaseCrashlyticsProvider = FirebaseCrashlytics Function();

class FirebaseCrashTestService implements CrashTestService {
  final FirebaseCrashlyticsProvider crashlyticsProvider;

  FirebaseCrashTestService({FirebaseCrashlyticsProvider? crashlyticsProvider})
    : crashlyticsProvider =
          crashlyticsProvider ?? (() => FirebaseCrashlytics.instance);

  @override
  void triggerTestCrash() {
    crashlyticsProvider().crash();
  }
}

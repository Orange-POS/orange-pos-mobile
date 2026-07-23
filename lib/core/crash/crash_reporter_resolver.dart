import '../firebase/firebase_app_startup.dart';
import 'crash_reporter.dart';

class CrashReporterResolver {
  final FirebaseAppStartup firebaseAppStartup;
  final CrashReporter fallbackCrashReporter;

  const CrashReporterResolver({
    required this.firebaseAppStartup,
    required this.fallbackCrashReporter,
  });

  Future<CrashReporter> resolve() async {
    try {
      return await firebaseAppStartup.initializeCrashReporter();
    } catch (error, stackTrace) {
      await fallbackCrashReporter.recordError(
        error,
        stackTrace,
        reason: 'Firebase Crashlytics initialization failed',
        fatal: false,
      );

      return fallbackCrashReporter;
    }
  }
}

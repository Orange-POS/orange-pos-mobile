import '../crash/crash_reporter.dart';
import '../crash/crashlytics_client.dart';
import '../crash/firebase_crash_reporter.dart';
import '../crash/firebase_crashlytics_client.dart';
import 'firebase_bootstrap.dart';

typedef CrashlyticsClientFactory = CrashlyticsClient Function();

class FirebaseAppStartup {
  final FirebaseBootstrap bootstrap;
  final CrashlyticsClientFactory crashlyticsClientFactory;

  const FirebaseAppStartup({
    this.bootstrap = const FirebaseBootstrap(),
    this.crashlyticsClientFactory = FirebaseCrashlyticsClient.new,
  });

  Future<CrashReporter> initializeCrashReporter() async {
    await bootstrap.initialize();

    final crashlyticsClient = crashlyticsClientFactory();
    await crashlyticsClient.setCrashlyticsCollectionEnabled(true);

    return FirebaseCrashReporter(crashlyticsClient: crashlyticsClient);
  }
}

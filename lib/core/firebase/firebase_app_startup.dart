import '../crash/crash_reporter.dart';
import '../crash/firebase_crash_reporter.dart';
import '../crash/firebase_crashlytics_client.dart';
import 'firebase_bootstrap.dart';

class FirebaseAppStartup {
  final FirebaseBootstrap bootstrap;

  const FirebaseAppStartup({this.bootstrap = const FirebaseBootstrap()});

  Future<CrashReporter> initializeCrashReporter() async {
    await bootstrap.initialize();

    final crashlyticsClient = FirebaseCrashlyticsClient();
    await crashlyticsClient.setCrashlyticsCollectionEnabled(true);

    return FirebaseCrashReporter(crashlyticsClient: crashlyticsClient);
  }
}

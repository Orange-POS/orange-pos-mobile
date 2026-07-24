abstract class CrashTestService {
  void triggerTestCrash();
}

class DisabledCrashTestService implements CrashTestService {
  const DisabledCrashTestService();

  @override
  void triggerTestCrash() {
    throw UnsupportedError('Crash test is disabled for this build.');
  }
}

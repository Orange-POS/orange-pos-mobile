class DemoMode {
  static const bool available = true;

  static bool enabled = false;

  static const String authToken = 'demo-auth-token';
  static const String backendUrl = 'demo://orange-one';

  static const String existingBarcode = '100001';
  static const String unknownBarcode = '999999';

  static void enable() {
    enabled = true;
  }

  static void disable() {
    enabled = false;
  }
}

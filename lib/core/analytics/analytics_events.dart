import '../errors/app_error.dart';

class AnalyticsEvents {
  const AnalyticsEvents._();

  static const String appOpened = 'app_opened';
  static const String loginSuccess = 'login_success';
  static const String logout = 'logout';

  static const String productScanned = 'product_scanned';
  static const String productFound = 'product_found';
  static const String productNotFound = 'product_not_found';
  static const String productAdded = 'product_added';
  static const String productUpdated = 'product_updated';

  static const String priceUpdated = 'price_updated';
}

class AnalyticsErrorTypes {
  const AnalyticsErrorTypes._();

  static const String validation = 'validation';
  static const String network = 'network';
  static const String authorization = 'authorization';
  static const String server = 'server';
  static const String unknown = 'unknown';

  static String fromAppErrorType(AppErrorType type) {
    return switch (type) {
      AppErrorType.validation => validation,
      AppErrorType.network => network,
      AppErrorType.authorization => authorization,
      AppErrorType.server => server,
      AppErrorType.unknown => unknown,
    };
  }
}

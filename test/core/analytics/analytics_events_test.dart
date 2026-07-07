import 'package:flutter_app/core/analytics/analytics_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/errors/app_error.dart';

void main() {
  group('AnalyticsEvents', () {
    test('keeps event names stable', () {
      expect(AnalyticsEvents.appOpened, 'app_opened');
      expect(AnalyticsEvents.loginSuccess, 'login_success');
      expect(AnalyticsEvents.logout, 'logout');

      expect(AnalyticsEvents.productScanned, 'product_scanned');
      expect(AnalyticsEvents.productFound, 'product_found');
      expect(AnalyticsEvents.productNotFound, 'product_not_found');
      expect(AnalyticsEvents.productAdded, 'product_added');
      expect(AnalyticsEvents.productUpdated, 'product_updated');

      expect(AnalyticsEvents.priceUpdated, 'price_updated');
    });
  });
  test('maps app error types to stable analytics error types', () {
    expect(
      AnalyticsErrorTypes.fromAppErrorType(AppErrorType.validation),
      'validation',
    );
    expect(
      AnalyticsErrorTypes.fromAppErrorType(AppErrorType.network),
      'network',
    );
    expect(
      AnalyticsErrorTypes.fromAppErrorType(AppErrorType.authorization),
      'authorization',
    );
    expect(AnalyticsErrorTypes.fromAppErrorType(AppErrorType.server), 'server');
    expect(
      AnalyticsErrorTypes.fromAppErrorType(AppErrorType.unknown),
      'unknown',
    );
  });
}

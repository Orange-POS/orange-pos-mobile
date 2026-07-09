import 'package:flutter_app/config/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiConfig', () {
    test('keeps product endpoints stable', () {
      expect(
        ApiConfig.productPriceUpdateEndpoint,
        '/mupi/mobile/api/products/price/update',
      );
      expect(
        ApiConfig.productNameUpdateEndpoint,
        '/mupi/mobile/api/products/name/update',
      );
      expect(ApiConfig.productFindEndpoint, '/mupi/mobile/api/products/find');
      expect(ApiConfig.productSaveEndpoint, '/mupi/mobile/api/products/save');
      expect(
        ApiConfig.productReferencesEndpoint,
        '/mupi/mobile/api/products/references',
      );
      expect(
        ApiConfig.productUpdateEndpoint,
        '/mupi/mobile/api/products/update',
      );
    });

    test('keeps system endpoints stable', () {
      expect(ApiConfig.pingEndpoint, '/mupi/mobile/api/ping');
      expect(
        ApiConfig.analyticsEventEndpoint,
        '/mupi/mobile/api/analytics/event',
      );
      expect(
        ApiConfig.analyticsErrorEndpoint,
        '/mupi/mobile/api/analytics/error',
      );
    });
  });
}

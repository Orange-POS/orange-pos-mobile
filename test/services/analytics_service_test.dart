import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/services/analytics_service.dart';
import 'package:flutter_app/services/api_client.dart';

void main() {
  group('AnalyticsService', () {
    test('can be created with default api client', () {
      final service = AnalyticsService();

      expect(service.apiClient, isA<ApiClient>());
    });

    test('can be created with injected api client', () {
      final apiClient = ApiClient();

      final service = AnalyticsService(apiClient: apiClient);

      expect(identical(service.apiClient, apiClient), isTrue);
    });
  });
}

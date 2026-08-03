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
    test('trackEvent swallows failures by default', () async {
      final service = AnalyticsService(apiClient: _ThrowingApiClient());

      await service.trackEvent(
        authToken: 'token',
        backendUrl: 'https://example.com',
        eventName: 'test_event',
        screen: 'test',
      );
    });

    test('trackEvent rethrows failures when configured', () async {
      final service = AnalyticsService(
        apiClient: _ThrowingApiClient(),
        swallowFailures: false,
      );

      expect(
        service.trackEvent(
          authToken: 'token',
          backendUrl: 'https://example.com',
          eventName: 'test_event',
          screen: 'test',
        ),
        throwsA(isA<ApiClientException>()),
      );
    });

    test('trackError swallows failures by default', () async {
      final service = AnalyticsService(apiClient: _ThrowingApiClient());

      await service.trackError(
        authToken: 'token',
        backendUrl: 'https://example.com',
        errorType: 'network',
        screen: 'test',
        message: 'message',
      );
    });

    test('trackError rethrows failures when configured', () async {
      final service = AnalyticsService(
        apiClient: _ThrowingApiClient(),
        swallowFailures: false,
      );

      expect(
        service.trackError(
          authToken: 'token',
          backendUrl: 'https://example.com',
          errorType: 'network',
          screen: 'test',
          message: 'message',
        ),
        throwsA(isA<ApiClientException>()),
      );
    });
  });
}

class _ThrowingApiClient extends ApiClient {
  @override
  Future<Map<String, dynamic>> postJson({
    required String baseUrl,
    required String endpoint,
    required Map<String, dynamic> body,
    String? authToken,
  }) {
    throw ApiClientException(
      uri: Uri(path: '/analytics'),
      message: 'analytics failed',
    );
  }
}

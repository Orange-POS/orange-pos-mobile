import '../config/api_config.dart';
import 'api_client.dart';

class AnalyticsService {
  final ApiClient apiClient;

  AnalyticsService({ApiClient? apiClient})
    : apiClient = apiClient ?? ApiClient();

  Future<void> trackEvent({
    required String authToken,
    required String backendUrl,
    required String eventName,
    required String screen,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      await apiClient.postJson(
        baseUrl: backendUrl,
        endpoint: ApiConfig.analyticsEventEndpoint,
        authToken: authToken,
        body: {
          'jsonrpc': '2.0',
          'params': {
            'event_name': eventName,
            'screen': screen,
            'metadata': metadata,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          },
        },
      );
    } catch (_) {
      // Analytics must never block app usage.
    }
  }

  Future<void> trackError({
    required String authToken,
    required String backendUrl,
    required String errorType,
    required String screen,
    required String message,
    String? details,
  }) async {
    try {
      await apiClient.postJson(
        baseUrl: backendUrl,
        endpoint: ApiConfig.analyticsErrorEndpoint,
        authToken: authToken,
        body: {
          'jsonrpc': '2.0',
          'params': {
            'error_type': errorType,
            'screen': screen,
            'message': message,
            'details': details,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          },
        },
      );
    } catch (_) {
      // Analytics must never block app usage.
    }
  }
}

import '../config/api_config.dart';
import 'api_client.dart';

class SessionService {
  final ApiClient apiClient = ApiClient();

  Future<bool> validateSession({
    required String authToken,
    required String backendUrl,
  }) async {
    try {
      final responseData = await apiClient.postJson(
        baseUrl: backendUrl,
        endpoint: ApiConfig.pingEndpoint,
        authToken: authToken,
        body: {'jsonrpc': '2.0', 'params': {}},
      );

      final result = responseData['result'] as Map<String, dynamic>?;

      return result != null && result['ok'] == true;
    } catch (_) {
      return false;
    }
  }
}

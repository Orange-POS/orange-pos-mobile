import '../config/api_config.dart';
import 'api_client.dart';

class SessionService {
  final ApiClient apiClient;

  SessionService({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<bool> validateSession({
    required String authToken,
    required String backendUrl,
  }) async {
    try {
      final responseData = await apiClient.postJson(
        baseUrl: backendUrl,
        endpoint: ApiConfig.sessionValidateEndpoint,
        authToken: authToken,
        body: {'jsonrpc': '2.0', 'params': {}},
      );

      final result = responseData['result'] as Map<String, dynamic>?;
      final valid = result?['valid'];

      if (valid is bool) {
        return valid;
      }

      throw const FormatException(
        'Session validation response did not include a valid flag.',
      );
    } on ApiClientException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        return false;
      }

      rethrow;
    }
  }
}

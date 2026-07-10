import '../models/qr_login_data.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<String> loginWithQr(QrLoginData qrLoginData) async {
    final requestBody = {
      'jsonrpc': '2.0',
      'method': 'call',
      'params': {
        'challenge': qrLoginData.challenge,
        'nonce': qrLoginData.nonce,
        'pos_session_id': qrLoginData.posSessionId,
        'pos_config_id': qrLoginData.posConfigId,
      },
    };

    final responseData = await apiClient.postJsonToUrl(
      url: qrLoginData.restEndpointUrl,
      body: requestBody,
    );

    final result = responseData['result'] as Map<String, dynamic>?;

    if (result == null || result['ok'] != true) {
      throw Exception(result?['error'] ?? 'QR login failed');
    }

    final token = result['access_token'];

    if (token == null || token.toString().isEmpty) {
      throw Exception('Login response did not include access_token');
    }

    return token.toString();
  }
}

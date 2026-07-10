import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/services/api_client.dart';
import 'package:flutter_app/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test('can be created with default api client', () {
      final service = AuthService();

      expect(service.apiClient, isA<ApiClient>());
    });

    test('can be created with injected api client', () {
      final apiClient = ApiClient();

      final service = AuthService(apiClient: apiClient);

      expect(identical(service.apiClient, apiClient), isTrue);
    });
  });
}

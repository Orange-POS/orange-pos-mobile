import 'package:flutter_app/config/api_config.dart';
import 'package:flutter_app/services/api_client.dart';
import 'package:flutter_app/services/session_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionService', () {
    test('can be created with default api client', () {
      final service = SessionService();

      expect(service.apiClient, isA<ApiClient>());
    });

    test('can be created with injected api client', () {
      final apiClient = ApiClient();

      final service = SessionService(apiClient: apiClient);

      expect(identical(service.apiClient, apiClient), isTrue);
    });

    test('uses dedicated session validation endpoint', () async {
      final apiClient = _FakeApiClient(
        responseData: {
          'result': {'valid': true},
        },
      );

      final service = SessionService(apiClient: apiClient);

      await service.validateSession(
        authToken: 'token',
        backendUrl: 'https://example.com',
      );

      expect(apiClient.endpoint, ApiConfig.sessionValidateEndpoint);
      expect(apiClient.authToken, 'token');
      expect(apiClient.baseUrl, 'https://example.com');
    });

    test('returns true when backend says session is valid', () async {
      final service = SessionService(
        apiClient: _FakeApiClient(
          responseData: {
            'result': {'valid': true},
          },
        ),
      );

      final result = await service.validateSession(
        authToken: 'token',
        backendUrl: 'https://example.com',
      );

      expect(result, isTrue);
    });

    test('returns false when backend says session is invalid', () async {
      final service = SessionService(
        apiClient: _FakeApiClient(
          responseData: {
            'result': {'valid': false},
          },
        ),
      );

      final result = await service.validateSession(
        authToken: 'token',
        backendUrl: 'https://example.com',
      );

      expect(result, isFalse);
    });

    test('returns false for unauthorized API responses', () async {
      final service = SessionService(
        apiClient: _FakeApiClient(
          error: ApiClientException(
            uri: Uri.parse(
              'https://example.com${ApiConfig.sessionValidateEndpoint}',
            ),
            message: 'Unauthorized',
            statusCode: 401,
          ),
        ),
      );

      final result = await service.validateSession(
        authToken: 'token',
        backendUrl: 'https://example.com',
      );

      expect(result, isFalse);
    });

    test('rethrows temporary API failures', () async {
      final error = ApiClientException(
        uri: Uri.parse(
          'https://example.com${ApiConfig.sessionValidateEndpoint}',
        ),
        message: 'Server unavailable',
        statusCode: 500,
      );

      final service = SessionService(apiClient: _FakeApiClient(error: error));

      await expectLater(
        service.validateSession(
          authToken: 'token',
          backendUrl: 'https://example.com',
        ),
        throwsA(same(error)),
      );
    });

    test(
      'throws when validation response does not include a boolean valid flag',
      () async {
        final service = SessionService(
          apiClient: _FakeApiClient(
            responseData: {
              'result': {'ok': true},
            },
          ),
        );

        await expectLater(
          service.validateSession(
            authToken: 'token',
            backendUrl: 'https://example.com',
          ),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}

class _FakeApiClient extends ApiClient {
  final Map<String, dynamic> responseData;
  final Object? error;

  String? baseUrl;
  String? endpoint;
  String? authToken;
  Map<String, dynamic>? body;

  _FakeApiClient({this.responseData = const {}, this.error});

  @override
  Future<Map<String, dynamic>> postJson({
    required String baseUrl,
    required String endpoint,
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    this.baseUrl = baseUrl;
    this.endpoint = endpoint;
    this.body = body;
    this.authToken = authToken;

    final error = this.error;
    if (error != null) {
      throw error;
    }

    return responseData;
  }
}

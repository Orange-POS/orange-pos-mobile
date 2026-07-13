import 'package:flutter_app/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiClientException', () {
    test('returns unauthorized user message for 401', () {
      final exception = ApiClientException(
        uri: Uri.parse('https://example.com/api'),
        message: 'Request failed.',
        statusCode: 401,
      );

      expect(
        exception.userMessage,
        'The saved login session is not authorized anymore.',
      );
    });

    test('returns unauthorized user message for 403', () {
      final exception = ApiClientException(
        uri: Uri.parse('https://example.com/api'),
        message: 'Request failed.',
        statusCode: 403,
      );

      expect(
        exception.userMessage,
        'The saved login session is not authorized anymore.',
      );
    });

    test('returns HTTP status user message for server errors', () {
      final exception = ApiClientException(
        uri: Uri.parse('https://example.com/api'),
        message: 'Request failed.',
        statusCode: 500,
      );

      expect(exception.userMessage, 'Server returned HTTP 500.');
    });

    test('returns original message when status code is missing', () {
      final exception = ApiClientException(
        uri: Uri.parse('https://example.com/api'),
        message: 'Could not connect to the server.',
      );

      expect(exception.userMessage, 'Could not connect to the server.');
    });

    test('includes diagnostic details', () {
      final exception = ApiClientException(
        uri: Uri.parse('https://example.com/api'),
        message: 'Request failed.',
        statusCode: 500,
        responseBody: '{"error":"server"}',
      );

      expect(exception.diagnosticDetails, contains('Request failed.'));
      expect(exception.diagnosticDetails, contains('https://example.com/api'));
      expect(exception.diagnosticDetails, contains('HTTP status: 500'));
      expect(exception.diagnosticDetails, contains('{"error":"server"}'));
    });
  });
}

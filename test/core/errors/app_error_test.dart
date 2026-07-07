import 'package:flutter_app/core/errors/app_error.dart';
import 'package:flutter_app/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppError', () {
    test('creates validation error', () {
      final error = AppError.validation('Product name is required.');

      expect(error.type, AppErrorType.validation);
      expect(error.userMessage, 'Product name is required.');
      expect(error.diagnosticDetails, 'Product name is required.');
    });

    test('maps unauthorized API exception to authorization error', () {
      final error = AppError.fromException(
        ApiClientException(
          uri: Uri.parse('https://example.com/api'),
          message: 'Request failed.',
          statusCode: 401,
        ),
      );

      expect(error.type, AppErrorType.authorization);
      expect(
        error.userMessage,
        'The saved login session is not authorized anymore.',
      );
      expect(error.diagnosticDetails, contains('HTTP status: 401'));
    });

    test('maps HTTP API exception to server error', () {
      final error = AppError.fromException(
        ApiClientException(
          uri: Uri.parse('https://example.com/api'),
          message: 'Request failed.',
          statusCode: 500,
          responseBody: '{"error":"server"}',
        ),
      );

      expect(error.type, AppErrorType.server);
      expect(error.userMessage, 'Server returned HTTP 500.');
      expect(error.diagnosticDetails, contains('{"error":"server"}'));
    });

    test('maps API exception without status to network error', () {
      final error = AppError.fromException(
        ApiClientException(
          uri: Uri.parse('https://example.com/api'),
          message: 'Could not connect.',
        ),
      );

      expect(error.type, AppErrorType.network);
      expect(error.userMessage, 'Could not connect.');
      expect(error.diagnosticDetails, contains('URL: https://example.com/api'));
    });

    test('maps unknown exception to unknown error', () {
      final error = AppError.fromException(Exception('Something went wrong.'));

      expect(error.type, AppErrorType.unknown);
      expect(error.userMessage, 'Something went wrong.');
      expect(error.diagnosticDetails, 'Exception: Something went wrong.');
    });
  });
}

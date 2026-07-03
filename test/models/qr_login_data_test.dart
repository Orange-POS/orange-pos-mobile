import 'dart:convert';

import 'package:flutter_app/models/qr_login_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QrLoginData', () {
    test('parses valid QR json', () {
      final rawValue = jsonEncode({
        'challenge': 'challenge-123',
        'nonce': 'nonce-123',
        'pos_session_id': 10,
        'pos_config_id': 20,
        'backend_url': 'https://example.com',
        'rest_endpoint_url': 'https://example.com/mupi/mobile/api',
        'expires_at': '2099-01-01T00:00:00Z',
      });

      final data = QrLoginData.fromRaw(rawValue);

      expect(data.rawValue, rawValue);
      expect(data.challenge, 'challenge-123');
      expect(data.nonce, 'nonce-123');
      expect(data.posSessionId, 10);
      expect(data.posConfigId, 20);
      expect(data.backendUrl, 'https://example.com');
      expect(data.restEndpointUrl, 'https://example.com/mupi/mobile/api');
      expect(data.isExpired, false);
    });

    test('parses Odoo datetime without T separator', () {
      final rawValue = jsonEncode({
        'challenge': 'challenge-123',
        'nonce': 'nonce-123',
        'pos_session_id': 10,
        'pos_config_id': 20,
        'backend_url': 'https://example.com',
        'rest_endpoint_url': 'https://example.com/mupi/mobile/api',
        'expires_at': '2099-01-01 00:00:00',
      });

      final data = QrLoginData.fromRaw(rawValue);

      expect(data.expiresAt.toUtc().year, 2099);
    });

    test('marks expired QR as expired', () {
      final rawValue = jsonEncode({
        'challenge': 'challenge-123',
        'nonce': 'nonce-123',
        'pos_session_id': 10,
        'pos_config_id': 20,
        'backend_url': 'https://example.com',
        'rest_endpoint_url': 'https://example.com/mupi/mobile/api',
        'expires_at': '2000-01-01T00:00:00Z',
      });

      final data = QrLoginData.fromRaw(rawValue);

      expect(data.isExpired, true);
    });

    test('throws FormatException for invalid backend url', () {
      final rawValue = jsonEncode({
        'challenge': 'challenge-123',
        'nonce': 'nonce-123',
        'pos_session_id': 10,
        'pos_config_id': 20,
        'backend_url': 'not-a-url',
        'rest_endpoint_url': 'https://example.com/mupi/mobile/api',
        'expires_at': '2099-01-01T00:00:00Z',
      });

      expect(
        () => QrLoginData.fromRaw(rawValue),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for invalid rest endpoint url', () {
      final rawValue = jsonEncode({
        'challenge': 'challenge-123',
        'nonce': 'nonce-123',
        'pos_session_id': 10,
        'pos_config_id': 20,
        'backend_url': 'https://example.com',
        'rest_endpoint_url': 'not-a-url',
        'expires_at': '2099-01-01T00:00:00Z',
      });

      expect(
        () => QrLoginData.fromRaw(rawValue),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
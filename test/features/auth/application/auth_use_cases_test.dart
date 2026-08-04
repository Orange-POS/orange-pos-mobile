import 'package:flutter_app/features/auth/application/auth_use_cases.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/services/session_service.dart';
import 'package:flutter_app/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthUseCases validateSession', () {
    test('returns valid when backend validates session', () async {
      final useCases = AuthUseCases(
        authService: AuthService(),
        sessionService: _FakeSessionService(result: true),
        tokenStorage: TokenStorage.instance,
      );

      final result = await useCases.validateSession(
        token: 'token',
        backendUrl: 'https://example.com',
      );

      expect(result, SessionValidationResult.valid);
    });

    test('returns invalid when backend rejects session', () async {
      final useCases = AuthUseCases(
        authService: AuthService(),
        sessionService: _FakeSessionService(result: false),
        tokenStorage: TokenStorage.instance,
      );

      final result = await useCases.validateSession(
        token: 'token',
        backendUrl: 'https://example.com',
      );

      expect(result, SessionValidationResult.invalid);
    });

    test('returns unavailable when session validation throws', () async {
      final useCases = AuthUseCases(
        authService: AuthService(),
        sessionService: _FakeSessionService(error: Exception('server offline')),
        tokenStorage: TokenStorage.instance,
      );

      final result = await useCases.validateSession(
        token: 'token',
        backendUrl: 'https://example.com',
      );

      expect(result, SessionValidationResult.unavailable);
    });

    test('returns unavailable when session validation times out', () async {
      final useCases = AuthUseCases(
        authService: AuthService(),
        sessionService: _FakeSessionService(delay: const Duration(seconds: 1)),
        tokenStorage: TokenStorage.instance,
        sessionValidationTimeout: const Duration(milliseconds: 10),
      );

      final result = await useCases.validateSession(
        token: 'token',
        backendUrl: 'https://example.com',
      );

      expect(result, SessionValidationResult.unavailable);
    });
  });
}

class _FakeSessionService extends SessionService {
  final bool result;
  final Object? error;
  final Duration delay;

  _FakeSessionService({
    this.result = true,
    this.error,
    this.delay = Duration.zero,
  });

  @override
  Future<bool> validateSession({
    required String authToken,
    required String backendUrl,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    final error = this.error;
    if (error != null) {
      throw error;
    }

    return result;
  }
}

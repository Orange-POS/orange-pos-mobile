import 'dart:async';

import '../../../models/qr_login_data.dart';
import '../../../services/auth_service.dart';
import '../../../services/session_service.dart';
import '../../../services/token_storage.dart';

enum SessionValidationResult { valid, invalid, unavailable }

class AuthUseCases {
  final AuthService authService;
  final SessionService sessionService;
  final TokenStorage tokenStorage;
  final Duration sessionValidationTimeout;

  const AuthUseCases({
    required this.authService,
    required this.sessionService,
    required this.tokenStorage,
    this.sessionValidationTimeout = const Duration(seconds: 5),
  });

  Future<String> loginWithQr(QrLoginData loginData) async {
    final token = await authService.loginWithQr(loginData);
    await tokenStorage.saveToken(token);
    await tokenStorage.saveBackendUrl(loginData.backendUrl);
    return token;
  }

  Future<SavedSession?> getSavedSession() async {
    final token = await tokenStorage.getToken();
    final backendUrl = await tokenStorage.getBackendUrl();

    if (token == null || backendUrl == null) {
      return null;
    }

    return SavedSession(token: token, backendUrl: backendUrl);
  }

  Future<SessionValidationResult> validateSession({
    required String token,
    required String backendUrl,
  }) async {
    try {
      final isValid = await sessionService
          .validateSession(authToken: token, backendUrl: backendUrl)
          .timeout(sessionValidationTimeout);

      return isValid
          ? SessionValidationResult.valid
          : SessionValidationResult.invalid;
    } on TimeoutException {
      return SessionValidationResult.unavailable;
    } catch (_) {
      return SessionValidationResult.unavailable;
    }
  }

  Future<void> clearSession() {
    return tokenStorage.clearSession();
  }
}

class SavedSession {
  final String token;
  final String backendUrl;

  const SavedSession({required this.token, required this.backendUrl});
}

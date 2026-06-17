import 'package:flutter/material.dart';

import '../widgets/app_page.dart';
import 'qr_login_scanner_screen.dart';
import 'scanner_screen.dart';
import '../models/qr_login_data.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';
import 'dart:async';
import '../services/analytics_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  QrLoginData? lastQrData;
  final AuthService authService = AuthService();
  final TokenStorage tokenStorage = TokenStorage.instance;
  final AnalyticsService analyticsService = AnalyticsService();
  bool isLoggingIn = false;
  String? authToken;
  String? errorMessage;

  Future<void> openScanner() async {
    final qrData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrLoginScannerScreen()),
    );

    if (!mounted || qrData == null) {
      return;
    }

    late QrLoginData loginData;

    try {
      loginData = QrLoginData.fromRaw(qrData.toString());
    } catch (error) {
      debugPrint('QR parse error: $error');

      setState(() {
        errorMessage =
            'Invalid QR code. Please scan the QR code from Odoo POS.';
      });
      return;
    }

    if (loginData.isExpired) {
      setState(() {
        errorMessage =
            'This QR code has expired. Please generate a new one from POS.';
      });
      return;
    }

    setState(() {
      lastQrData = loginData;
      isLoggingIn = true;
      errorMessage = null;
    });

    try {
      final token = await authService.loginWithQr(loginData);
      await tokenStorage.saveToken(token);
      await tokenStorage.saveBackendUrl(loginData.backendUrl);

      unawaited(
        analyticsService.trackEvent(
          authToken: token,
          backendUrl: loginData.backendUrl,
          eventName: 'login_success',
          screen: 'login',
          metadata: {
            'pos_session_id': loginData.posSessionId,
            'pos_config_id': loginData.posConfigId,
          },
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        authToken = token;
        isLoggingIn = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ScannerScreen(authToken: token, backendUrl: loginData.backendUrl),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoggingIn = false;
        errorMessage = 'Login failed. Please try again.';
      });

      debugPrint('Login failed: $error');

      if (lastQrData != null) {
        unawaited(
          analyticsService.trackError(
            authToken: '',
            backendUrl: lastQrData!.backendUrl,
            errorType: 'login_failed',
            screen: 'login',
            message: 'Login failed.',
            details: error.toString(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Inventory Tracker',
      child: Column(
        children: [
          const Spacer(),
          GestureDetector(
            onTap: isLoggingIn ? null : openScanner,
            child: Container(
              width: double.infinity,
              height: 230,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoggingIn
                  ? const Center(child: CircularProgressIndicator())
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 110,
                          color: Colors.black,
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Tap to Scan Login QR',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isLoggingIn
                ? 'Logging in...'
                : 'Scan the QR code shown in Odoo POS.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3F3),
                border: Border.all(color: const Color(0xFFFFB4B4)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const Spacer(),
        ],
      ),
    );
  }
}

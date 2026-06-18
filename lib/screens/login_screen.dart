import 'dart:async';

import 'package:flutter/material.dart';

import '../models/qr_login_data.dart';
import '../services/analytics_service.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';
import '../theme/app_brand.dart';

import 'qr_login_scanner_screen.dart';
import 'scanner_screen.dart';

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
    return Scaffold(
      backgroundColor: AppBrand.loginBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 24, 30, 24),
          child: Column(
            children: [
              const _LoginHeader(),
              const Spacer(),
              GestureDetector(
                onTap: isLoggingIn ? null : openScanner,
                child: Container(
                  width: 272,
                  height: 283,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: AppBrand.primary, width: 4),
                    borderRadius: BorderRadius.circular(45),
                  ),
                  child: isLoggingIn
                      ? const Center(child: CircularProgressIndicator())
                      : Image.asset(
                          AppBrand.loginScanIcon,
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Tap to Scan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppBrand.textPrimary,
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppBrand.errorBackground,
                    border: Border.all(color: AppBrand.errorBorder),
                    borderRadius: BorderRadius.circular(12),
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
              const _LoginFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _OrangeOneTitle(),
        Spacer(),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppBrand.white,
          child: Icon(Icons.person_outline, color: AppBrand.textPrimary),
        ),
      ],
    );
  }
}

class _OrangeOneTitle extends StatelessWidget {
  const _OrangeOneTitle();

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Orange',
            style: TextStyle(
              color: AppBrand.primary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: 'ONE',
            style: TextStyle(
              color: AppBrand.textDarkGrey,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Powered By',
          style: TextStyle(
            fontSize: 14,
            color: AppBrand.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Image.asset(
          AppBrand.orangePosLogo,
          width: 88,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Text(
              'OrangePOS',
              style: TextStyle(
                fontSize: 14,
                color: AppBrand.primary,
                fontWeight: FontWeight.w700,
              ),
            );
          },
        ),
      ],
    );
  }
}

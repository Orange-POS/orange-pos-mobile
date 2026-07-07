import 'dart:async';

import 'package:flutter/material.dart';

import '../models/qr_login_data.dart';
import '../services/analytics_service.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';
import '../theme/app_brand.dart';
import '../widgets/app_chrome.dart';

import 'qr_login_scanner_screen.dart';
import 'scanner_screen.dart';
import '../demo/demo_mode.dart';
import 'settings_screen.dart';
import '../core/di/app_dependencies.dart';

class LoginScreen extends StatefulWidget {
  final AppDependencies dependencies;

  const LoginScreen({super.key, required this.dependencies});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  QrLoginData? lastQrData;
  AuthService get authService => widget.dependencies.authService;
  TokenStorage get tokenStorage => widget.dependencies.tokenStorage;
  AnalyticsService get analyticsService => widget.dependencies.analyticsService;

  bool isLoggingIn = false;
  String? authToken;
  String? errorMessage;

  Future<void> openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void enterDemoLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(
          authToken: DemoMode.authToken,
          backendUrl: DemoMode.backendUrl,
          dependencies: widget.dependencies,
        ),
      ),
    );
  }

  Future<void> openScanner() async {
    if (DemoMode.available && DemoMode.enabled) {
      enterDemoLogin();
      return;
    }

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
          builder: (context) => ScannerScreen(
            authToken: token,
            backendUrl: loginData.backendUrl,
            dependencies: widget.dependencies,
          ),
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
      backgroundColor: AppBrand.white,
      body: SafeArea(
        child: Padding(
          padding: AppChrome.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader.brand(onProfilePressed: openSettings),
              const SizedBox(height: 31),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppBrand.textDarkGrey,
                ),
              ),
              const Spacer(flex: 3),
              Center(
                child: GestureDetector(
                  onTap: isLoggingIn ? null : openScanner,
                  child: Container(
                    width: 287,
                    height: 287,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF6EE),
                      borderRadius: BorderRadius.circular(49),
                      boxShadow: [
                        BoxShadow(
                          color: AppBrand.primaryDark.withValues(alpha: 0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: isLoggingIn
                        ? const Center(child: CircularProgressIndicator())
                        : Center(
                            child: Image.asset(
                              AppBrand.loginScanIcon,
                              width: 230,
                              height: 230,
                              fit: BoxFit.contain,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Tap to Scan',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppBrand.textDarkGrey,
                  ),
                ),
              ),
              if (DemoMode.available && DemoMode.enabled) ...[
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Demo Mode enabled. Tap to continue without Odoo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppBrand.primary,
                    ),
                  ),
                ),
              ],

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
              const Spacer(flex: 4),
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

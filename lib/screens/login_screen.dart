import 'dart:async';

import 'package:flutter/material.dart';

import '../models/qr_login_data.dart';
import '../services/analytics_service.dart';

import '../theme/app_brand.dart';
import '../widgets/app_chrome.dart';

import 'qr_login_scanner_screen.dart';

import '../demo/demo_mode.dart';
import 'settings_screen.dart';
import '../core/di/app_dependencies.dart';
import '../core/navigation/app_routes.dart';
import '../core/errors/app_error.dart';
import '../core/analytics/analytics_events.dart';
import '../core/widgets/app_error_state.dart';
import '../core/widgets/app_surface.dart';
import '../core/theme/app_radius.dart';
import '../features/auth/application/auth_use_cases.dart';

class LoginScreen extends StatefulWidget {
  final AppDependencies dependencies;

  const LoginScreen({super.key, required this.dependencies});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  QrLoginData? lastQrData;
  AuthUseCases get authUseCases => widget.dependencies.authUseCases;
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
      AppRoutes.scanner(
        authToken: DemoMode.authToken,
        backendUrl: DemoMode.backendUrl,
        dependencies: widget.dependencies,
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
      final token = await authUseCases.loginWithQr(loginData);

      unawaited(
        analyticsService.trackEvent(
          authToken: token,
          backendUrl: loginData.backendUrl,
          eventName: AnalyticsEvents.loginSuccess,
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
        AppRoutes.scanner(
          authToken: token,
          backendUrl: loginData.backendUrl,
          dependencies: widget.dependencies,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final appError = AppError.fromException(error);

      setState(() {
        isLoggingIn = false;
        errorMessage = appError.userMessage;
      });

      debugPrint('Login failed: ${appError.diagnosticDetails}');

      if (lastQrData != null) {
        unawaited(
          analyticsService.trackError(
            authToken: '',
            backendUrl: lastQrData!.backendUrl,
            errorType: AnalyticsErrorTypes.fromAppErrorType(appError.type),
            screen: 'login',
            message: appError.userMessage,
            details: appError.diagnosticDetails,
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
                  child: AppSurface(
                    width: 287,
                    height: 287,
                    borderRadius: AppRadius.heroCard,
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
                AppErrorState.box(
                  message: errorMessage!,
                  textAlign: TextAlign.center,
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

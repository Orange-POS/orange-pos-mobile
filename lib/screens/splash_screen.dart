import 'dart:async';

import 'package:flutter/material.dart';

import '../services/analytics_service.dart';
import '../services/session_service.dart';
import '../services/token_storage.dart';
import '../theme/app_brand.dart';
import 'login_screen.dart';
import 'scanner_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TokenStorage tokenStorage = TokenStorage.instance;
  final SessionService sessionService = SessionService();
  final AnalyticsService analyticsService = AnalyticsService();

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final token = await tokenStorage.getToken();
    final backendUrl = await tokenStorage.getBackendUrl();

    if (!mounted) {
      return;
    }

    if (token == null || backendUrl == null) {
      openLogin();
      return;
    }

    final isValidSession = await sessionService.validateSession(
      authToken: token,
      backendUrl: backendUrl,
    );

    if (!mounted) {
      return;
    }

    if (!isValidSession) {
      await tokenStorage.clearSession();

      if (!mounted) {
        return;
      }

      openLogin();
      return;
    }

    unawaited(
      analyticsService.trackEvent(
        authToken: token,
        backendUrl: backendUrl,
        eventName: 'app_opened',
        screen: 'splash',
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ScannerScreen(authToken: token, backendUrl: backendUrl),
      ),
    );
  }

  void openLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppBrand.loginBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 24, 30, 36),
          child: Column(
            children: [
              const Spacer(flex: 5),
              const _SplashWordmark(),
              const SizedBox(height: 92),
              const SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  color: AppBrand.primaryDark,
                ),
              ),
              const Spacer(flex: 4),
              const Text(
                'Powered By',
                style: TextStyle(
                  fontSize: 18,
                  color: AppBrand.textPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 14),
              Image.asset(
                AppBrand.orangePosLogo,
                width: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'Orange POS',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppBrand.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashWordmark extends StatelessWidget {
  const _SplashWordmark();

  @override
  Widget build(BuildContext context) {
    return const FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Orange',
              style: TextStyle(
                color: AppBrand.primary,
                fontSize: 58,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
              ),
            ),
            TextSpan(
              text: 'ONE',
              style: TextStyle(
                color: AppBrand.textDarkGrey,
                fontSize: 58,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
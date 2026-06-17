import 'package:flutter/material.dart';

import '../services/token_storage.dart';
import 'login_screen.dart';
import 'scanner_screen.dart';
import '../services/session_service.dart';
import 'dart:async';
import '../services/analytics_service.dart';

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
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../core/analytics/analytics_events.dart';
import '../core/di/app_dependencies.dart';
import '../core/navigation/app_routes.dart';
import '../features/auth/application/auth_use_cases.dart';
import '../services/analytics_service.dart';
import '../theme/app_brand.dart';

class SplashScreen extends StatefulWidget {
  final AppDependencies dependencies;

  const SplashScreen({super.key, required this.dependencies});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AuthUseCases get authUseCases => widget.dependencies.authUseCases;
  AnalyticsService get analyticsService => widget.dependencies.analyticsService;

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final savedSession = await authUseCases.getSavedSession();

    if (!mounted) {
      return;
    }

    if (savedSession == null) {
      openLogin();
      return;
    }

    final token = savedSession.token;
    final backendUrl = savedSession.backendUrl;

    final isValidSession = await authUseCases.validateSession(
      token: token,
      backendUrl: backendUrl,
    );

    if (!mounted) {
      return;
    }

    if (!isValidSession) {
      await authUseCases.clearSession();

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
        eventName: AnalyticsEvents.appOpened,
        screen: 'splash',
      ),
    );

    Navigator.pushReplacement(
      context,
      AppRoutes.scanner(
        authToken: token,
        backendUrl: backendUrl,
        dependencies: widget.dependencies,
      ),
    );
  }

  void openLogin() {
    Navigator.pushReplacement(
      context,
      AppRoutes.login(dependencies: widget.dependencies),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppBrand.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final scale = (width / 375).clamp(0.0, height / 812);
          final leftOffset = (width - (375 * scale)) / 2;
          final topOffset = (height - (812 * scale)) / 2;

          return Stack(
            children: [
              Positioned(
                left: leftOffset + (37.23 * scale),
                top: topOffset + (332.95 * scale),
                width: 300.54 * scale,
                height: 72.42 * scale,
                child: const _SplashWordmark(),
              ),
              Positioned(
                left: leftOffset + (157.69 * scale),
                top: topOffset + (479.91 * scale),
                width: 59.62 * scale,
                height: 59.62 * scale,
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppBrand.primary,
                ),
              ),
            ],
          );
        },
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
                fontSize: 50.69,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: 'ONE',
              style: TextStyle(
                color: AppBrand.textDarkGrey,
                fontSize: 50.69,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

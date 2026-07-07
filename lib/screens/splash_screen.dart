import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/analytics_service.dart';
import '../services/session_service.dart';
import '../services/token_storage.dart';
import '../theme/app_brand.dart';

import '../core/di/app_dependencies.dart';
import '../core/navigation/app_routes.dart';

class SplashScreen extends StatefulWidget {
  final AppDependencies dependencies;

  const SplashScreen({super.key, required this.dependencies});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  TokenStorage get tokenStorage => widget.dependencies.tokenStorage;
  SessionService get sessionService => widget.dependencies.sessionService;
  AnalyticsService get analyticsService => widget.dependencies.analyticsService;

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
                child: const _SplashLoader(),
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

class _SplashLoader extends StatelessWidget {
  static final Uint8List _loaderBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAEpUlEQVR4AexZTYgcRRR+r2e7J/szrogHUQQPhgWFiAdP7tEk/oAoYUN2JoiKeglERPQ68aqeFAIBAyLObEggEg9GVsFLThEUlCALEgTZgyDq7s7sZnp2unzfzvRmp7pqpsbpnjXJNlVTr773873XNbNdXevRLX7tFbDbC7i3ArYVUC/TvrVS8Ag6ZJvdsHgmK1A/nn++Hga/kKJr6JCBDZusyT/1Albn6d4oUu8rooeoc0EGBl0HSm1IvQCPg8OS3Yx0vc10dDo+1Dz1AlpE+20Z9dLZfPrhAxWwMp9/ujbvf7hSDE7Vj/mPm4KPefyDCQfWSwf9f+nOBSBpj9Vlxfy2OJVVjq8A00knP298yaS+0XFg0On4sHPJpX+IejH/rBiWd1oqRRPA/inlD+3EIXtjY6/IeJFI/dHudLGDCZxukxz6B4yIXrRZ5YgSP9iJzzaWC9XwSKHavK/dwyPAbDGGwR0LUMs2EkVR3aYbBe5UwFikLjHTuikhWYGfTfioMKcCJs81f2wp+kBPSr5a701Wmt/r+CjnTgUgoelqeKrFfJiYT5JSJ5qKHgMG3W525wKQ5N2VxmKh0vi4sNA8fc9C+BOw3e4DFbDbyZr4b98CVmVXuVYM5vC0zWorbLqjMQZOcCMH5BLj+mhcgZVS/hnm4IoYnxeDsmyFL9WK/uL6S+MPCJZpA0et6C+CE9xCdh65ICeRE01sujE1R+Os1EeCdj1hFfHB1mYLuKiya+AAl8Ywg5yQm4ZTooC/x4L9TPSwbtieqyfbY5afZg7khNx05kQBvkebulE8Z2LZ0sezbMZeHKbcEgVM+eF1JvqNDJciumqAU4VsHMgJuelkiQL4U7rBHr8phkvStxv287kod3IbyEgAB7i08EvICblpePI3AAO8eCgVzjLRcex3BDs6VW0emji38bvImTZwgEtIjoIbOSAX5CRYoiVWILa4a4H+nKqGFex3CtXwQoyPagQnuJEDcrHxWguwOfzf8DurgFpx31NrRf+N1ZL/ar3kP5HWaiAWYiI2OAaJ67wC2JfI66OcNvAZVnw2UnwV2CBkJlvEQCzEJOIz4FgrBmVyvJwKwBlQjukdPaY4l/+aDw7ouOscvoih28vr67vg1HHTXPxNcDcWMb2GY5RutD3zSc22pcE/bb7gAqdLRKcC5G/xhjUY27ceVp9Y0cO3J2fsL6NTAS3yvhVbY2PKXSftWj82/qB8j7+oFYNldMjANDNigy91rl6cHZOtwamA6YXG13gqbnl0PuR7ug5sqnojUVzkbZ4VsxdkX3M/OuQOJuLNBl/EQKybKBEwcO7EbLJTAXDGU9Ejfo6IP5FTidPcUrPASLvkbs8peXfQYPk/Bx+ETscRA7EQkyQ2OICR4+U52m2ZTVYbXxWqjdflVOIEzoq2QO1D7t6jGrQ9tekQCzERGxzbDg7CQAU4xMPu8JrNTsisOptPP1xi9jMZTC87x+/Eo2srLnO0pY4Ocmo99QKwc4yY31JEv8ZZQo4Egy7G0hpTLwCJTVcalwvN8ACOH9EhA4Mu7Z5JAUiSL9AGjh/RIQPLomdWQBbJmmLuFWC6K6PE/gUAAP//205gUQAAAAZJREFUAwCy4bVwYI58KQAAAABJRU5ErkJggg==',
  );

  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      _loaderBytes,
      fit: BoxFit.contain,
      gaplessPlayback: true,
    );
  }
}

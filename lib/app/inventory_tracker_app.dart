import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import '../screens/splash_screen.dart';
import '../theme/app_theme.dart';

class InventoryTrackerApp extends StatelessWidget {
  final AppConfig config;

  const InventoryTrackerApp({
    super.key,
    this.config = const AppConfig.production(),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}

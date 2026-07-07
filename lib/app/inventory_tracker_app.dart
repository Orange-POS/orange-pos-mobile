import 'package:flutter/material.dart';
import '../core/di/app_dependencies.dart';
import '../screens/splash_screen.dart';
import '../theme/app_theme.dart';

class InventoryTrackerApp extends StatelessWidget {
  final AppDependencies dependencies;

  const InventoryTrackerApp({super.key, required this.dependencies});

  factory InventoryTrackerApp.production({Key? key}) {
    return InventoryTrackerApp(key: key, dependencies: AppDependencies());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: dependencies.config.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: SplashScreen(dependencies: dependencies),
    );
  }
}

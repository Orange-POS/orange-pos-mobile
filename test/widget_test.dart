import 'package:flutter/material.dart';
import 'package:flutter_app/app/inventory_tracker_app.dart';
import 'package:flutter_app/core/config/app_config.dart';
import 'package:flutter_app/core/di/app_dependencies.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_app/core/feature_flags/feature_flags.dart';

void main() {
  testWidgets('OrangeONE app opens login screen', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(InventoryTrackerApp.production());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Tap to Scan'), findsOneWidget);
    expect(find.textContaining('OrangePos'), findsOneWidget);
  });

  testWidgets('app uses injected app name', (tester) async {
    final dependencies = AppDependencies(
      config: const AppConfig(
        appName: 'OrangeONE Test',
        environment: AppEnvironment.development,
        featureFlags: FeatureFlags.disabled(),
      ),
    );

    await tester.pumpWidget(InventoryTrackerApp(dependencies: dependencies));

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(materialApp.title, 'OrangeONE Test');
  });
}

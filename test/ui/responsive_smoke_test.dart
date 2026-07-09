import 'package:flutter/material.dart';
import 'package:flutter_app/core/di/app_dependencies.dart';
import 'package:flutter_app/demo/demo_mode.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/screens/product_screen.dart';
import 'package:flutter_app/screens/scanner_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('responsive smoke tests', () {
    final dependencies = AppDependencies();

    const product = Product(
      id: 1,
      name: 'Demo Orange Juice',
      barcode: '100001',
      price: 250,
      taxes: [],
    );

    Future<void> pumpAtSize(
      WidgetTester tester,
      Widget child,
      Size size,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(MaterialApp(home: child));

      await tester.pumpAndSettle();
    }

    testWidgets('login screen fits small phone size', (tester) async {
      await pumpAtSize(
        tester,
        LoginScreen(dependencies: dependencies),
        const Size(360, 740),
      );

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Tap to Scan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('scanner screen fits small phone size', (tester) async {
      DemoMode.enable();
      addTearDown(DemoMode.disable);

      await pumpAtSize(
        tester,
        ScannerScreen(
          authToken: DemoMode.authToken,
          backendUrl: DemoMode.backendUrl,
          dependencies: dependencies,
        ),
        const Size(360, 740),
      );

      expect(find.text('Scanner'), findsOneWidget);
      expect(find.text('Tap to Scan\nProducts'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('product screen fits small phone size', (tester) async {
      DemoMode.enable();
      addTearDown(DemoMode.disable);

      await pumpAtSize(
        tester,
        ProductScreen(
          product: product,
          authToken: DemoMode.authToken,
          backendUrl: DemoMode.backendUrl,
          dependencies: dependencies,
        ),
        const Size(360, 740),
      );

      expect(find.text('Product Details'), findsOneWidget);
      expect(find.text('Demo Orange Juice'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

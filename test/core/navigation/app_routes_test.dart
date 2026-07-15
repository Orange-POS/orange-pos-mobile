import 'package:flutter/material.dart';
import 'package:flutter_app/core/di/app_dependencies.dart';
import 'package:flutter_app/core/navigation/app_routes.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/screens/add_product_screen.dart';
import 'package:flutter_app/screens/edit_product_screen.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/screens/product_screen.dart';
import 'package:flutter_app/screens/scanner_screen.dart';
import 'package:flutter_app/screens/update_price_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/demo/demo_mode.dart';

void main() {
  group('AppRoutes', () {
    final dependencies = AppDependencies();

    const product = Product(
      id: 1,
      name: 'Orange Juice',
      barcode: '100001',
      price: 12.5,
      taxes: [],
    );

    setUp(() {
      DemoMode.enable();
    });

    tearDown(() {
      DemoMode.disable();
    });

    Widget buildRoute(MaterialPageRoute<Object?> route) {
      return MaterialApp(home: Builder(builder: route.builder));
    }

    testWidgets('creates login route', (tester) async {
      final route = AppRoutes.login(dependencies: dependencies);

      await tester.pumpWidget(buildRoute(route));

      final screen = tester.widget<LoginScreen>(find.byType(LoginScreen));
      expect(screen.dependencies, same(dependencies));
    });

    testWidgets('creates scanner route', (tester) async {
      final route = AppRoutes.scanner(
        authToken: DemoMode.authToken,
        backendUrl: DemoMode.backendUrl,
        dependencies: dependencies,
      );

      await tester.pumpWidget(buildRoute(route));

      final screen = tester.widget<ScannerScreen>(find.byType(ScannerScreen));
      expect(screen.authToken, DemoMode.authToken);
      expect(screen.backendUrl, DemoMode.backendUrl);
      expect(screen.dependencies, same(dependencies));
    });

    testWidgets('creates product route', (tester) async {
      final route = AppRoutes.product(
        product: product,
        authToken: DemoMode.authToken,
        backendUrl: DemoMode.backendUrl,
        dependencies: dependencies,
      );

      await tester.pumpWidget(buildRoute(route));

      final screen = tester.widget<ProductScreen>(find.byType(ProductScreen));
      expect(screen.product, same(product));
      expect(screen.authToken, DemoMode.authToken);
      expect(screen.backendUrl, DemoMode.backendUrl);
      expect(screen.dependencies, same(dependencies));
    });

    testWidgets('creates add product route', (tester) async {
      final route = AppRoutes.addProduct(
        barcode: '999999',
        authToken: DemoMode.authToken,
        backendUrl: DemoMode.backendUrl,
        dependencies: dependencies,
      );

      await tester.pumpWidget(buildRoute(route));

      final screen = tester.widget<AddProductScreen>(
        find.byType(AddProductScreen),
      );
      expect(screen.barcode, '999999');
      expect(screen.authToken, DemoMode.authToken);
      expect(screen.backendUrl, DemoMode.backendUrl);
      expect(screen.dependencies, same(dependencies));
    });

    testWidgets('creates update price route', (tester) async {
      final route = AppRoutes.updatePrice(
        product: product,
        authToken: DemoMode.authToken,
        backendUrl: DemoMode.backendUrl,
        dependencies: dependencies,
      );

      await tester.pumpWidget(buildRoute(route));

      final screen = tester.widget<UpdatePriceScreen>(
        find.byType(UpdatePriceScreen),
      );
      expect(screen.product, same(product));
      expect(screen.authToken, DemoMode.authToken);
      expect(screen.backendUrl, DemoMode.backendUrl);
      expect(screen.dependencies, same(dependencies));
    });

    testWidgets('creates edit product route', (tester) async {
      final route = AppRoutes.editProduct(
        product: product,
        authToken: DemoMode.authToken,
        backendUrl: DemoMode.backendUrl,
        dependencies: dependencies,
      );

      await tester.pumpWidget(buildRoute(route));

      final screen = tester.widget<EditProductScreen>(
        find.byType(EditProductScreen),
      );
      expect(screen.product, same(product));
      expect(screen.authToken, DemoMode.authToken);
      expect(screen.backendUrl, DemoMode.backendUrl);
      expect(screen.dependencies, same(dependencies));
    });
  });
}

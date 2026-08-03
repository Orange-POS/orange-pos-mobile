import 'package:flutter/material.dart';
import 'package:flutter_app/core/di/app_dependencies.dart';
import 'package:flutter_app/core/navigation/app_routes.dart';
import 'package:flutter_app/demo/demo_mode.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/screens/add_product_screen.dart';
import 'package:flutter_app/screens/edit_product_screen.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/screens/product_screen.dart';
import 'package:flutter_app/screens/scanner_screen.dart';
import 'package:flutter_app/screens/update_price_screen.dart';
import 'package:flutter_test/flutter_test.dart';

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

    setUp(DemoMode.enable);
    tearDown(DemoMode.disable);

    Widget buildRoute(MaterialPageRoute<Object?> route) {
      return MaterialApp(home: Builder(builder: route.builder));
    }

    Widget buildNavigationHarness(Widget home) {
      return MaterialApp(home: home);
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

    testWidgets('replaceWithLogin removes the previous screen', (tester) async {
      await tester.pumpWidget(
        buildNavigationHarness(_OldScreen(dependencies: dependencies)),
      );

      expect(find.byType(_OldScreen), findsOneWidget);

      await tester.tap(find.text('Replace with login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(_OldScreen), findsNothing);

      final didPop = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(didPop, isFalse);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(_OldScreen), findsNothing);
    });

    testWidgets('replaceWithScanner removes splash and passes session data', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildNavigationHarness(
          _FakeSplashNavigationScreen(dependencies: dependencies),
        ),
      );

      expect(find.byType(_FakeSplashNavigationScreen), findsOneWidget);

      await tester.tap(find.text('Replace with scanner'));
      await tester.pumpAndSettle();

      final screen = tester.widget<ScannerScreen>(find.byType(ScannerScreen));

      expect(screen.authToken, DemoMode.authToken);
      expect(screen.backendUrl, DemoMode.backendUrl);
      expect(screen.dependencies, same(dependencies));
      expect(find.byType(_FakeSplashNavigationScreen), findsNothing);

      final didPop = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(didPop, isFalse);
      expect(find.byType(ScannerScreen), findsOneWidget);
      expect(find.byType(_FakeSplashNavigationScreen), findsNothing);
    });

    testWidgets(
      'goToLoginAndClearStack removes splash scanner and product routes',
      (tester) async {
        await tester.pumpWidget(
          buildNavigationHarness(const _FakeSplashScreen()),
        );

        final navigator = tester.state<NavigatorState>(find.byType(Navigator));

        navigator.push(
          AppRoutes.scanner(
            authToken: DemoMode.authToken,
            backendUrl: DemoMode.backendUrl,
            dependencies: dependencies,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ScannerScreen), findsOneWidget);

        navigator.push(
          AppRoutes.product(
            product: product,
            authToken: DemoMode.authToken,
            backendUrl: DemoMode.backendUrl,
            dependencies: dependencies,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ProductScreen), findsOneWidget);

        navigator.push(
          MaterialPageRoute<void>(
            builder: (context) => _ClearStackScreen(dependencies: dependencies),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(_ClearStackScreen), findsOneWidget);

        await tester.tap(find.text('Clear stack to login'));
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(ProductScreen), findsNothing);
        expect(find.byType(ScannerScreen), findsNothing);
        expect(find.byType(_ClearStackScreen), findsNothing);
        expect(find.byType(_FakeSplashScreen), findsNothing);

        final didPop = await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(didPop, isFalse);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(ProductScreen), findsNothing);
        expect(find.byType(ScannerScreen), findsNothing);
        expect(find.byType(_FakeSplashScreen), findsNothing);
      },
    );
    testWidgets('creates settings route with dependencies', (tester) async {
      final dependencies = AppDependencies();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    AppRoutes.settings(dependencies: dependencies),
                  );
                },
                child: const Text('Open settings'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });
  });
}

class _OldScreen extends StatelessWidget {
  final AppDependencies dependencies;

  const _OldScreen({required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () {
            AppRoutes.replaceWithLogin(context, dependencies: dependencies);
          },
          child: const Text('Replace with login'),
        ),
      ),
    );
  }
}

class _FakeSplashNavigationScreen extends StatelessWidget {
  final AppDependencies dependencies;

  const _FakeSplashNavigationScreen({required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () {
            AppRoutes.replaceWithScanner(
              context,
              authToken: DemoMode.authToken,
              backendUrl: DemoMode.backendUrl,
              dependencies: dependencies,
            );
          },
          child: const Text('Replace with scanner'),
        ),
      ),
    );
  }
}

class _FakeSplashScreen extends StatelessWidget {
  const _FakeSplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Fake Splash')));
  }
}

class _ClearStackScreen extends StatelessWidget {
  final AppDependencies dependencies;

  const _ClearStackScreen({required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () {
            AppRoutes.goToLoginAndClearStack(
              context,
              dependencies: dependencies,
            );
          },
          child: const Text('Clear stack to login'),
        ),
      ),
    );
  }
}

import 'package:flutter_app/demo/demo_mode.dart';
import 'package:flutter_app/features/products/application/product_use_cases.dart';
import 'package:flutter_app/features/products/data/demo_product_repository.dart';
import 'package:flutter_app/features/products/data/odoo_product_repository.dart';
import 'package:flutter_app/features/products/data/product_repository_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductRepositoryFactory', () {
    tearDown(() {
      DemoMode.disable();
    });

    test('creates demo repository when demo mode is enabled', () {
      DemoMode.enable();

      const factory = ProductRepositoryFactory();

      final repository = factory.create(
        authToken: DemoMode.authToken,
        backendUrl: DemoMode.backendUrl,
      );

      expect(repository, isA<DemoProductRepository>());
    });

    test('creates Odoo repository when demo mode is disabled', () {
      DemoMode.disable();

      const factory = ProductRepositoryFactory();

      final repository = factory.create(
        authToken: DemoMode.authToken,
        backendUrl: DemoMode.backendUrl,
      );

      expect(repository, isA<OdooProductRepository>());
    });

    test('creates Odoo repository when token does not match demo token', () {
      DemoMode.enable();

      const factory = ProductRepositoryFactory();

      final repository = factory.create(
        authToken: 'real-token',
        backendUrl: DemoMode.backendUrl,
      );

      expect(repository, isA<OdooProductRepository>());
    });

    test(
      'creates Odoo repository when backend url does not match demo url',
      () {
        DemoMode.enable();

        const factory = ProductRepositoryFactory();

        final repository = factory.create(
          authToken: DemoMode.authToken,
          backendUrl: 'https://example.com',
        );

        expect(repository, isA<OdooProductRepository>());
      },
    );
    test('creates product use cases', () {
      const factory = ProductRepositoryFactory();

      final useCases = factory.createUseCases(
        authToken: DemoMode.authToken,
        backendUrl: DemoMode.backendUrl,
      );

      expect(useCases, isA<ProductUseCases>());
    });
  });
}

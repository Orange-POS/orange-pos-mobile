import 'package:flutter_app/demo/demo_mode.dart';
import 'package:flutter_app/features/products/application/product_use_cases.dart';
import 'package:flutter_app/features/products/data/demo_product_repository.dart';
import 'package:flutter_app/features/products/data/odoo_product_repository.dart';
import 'package:flutter_app/features/products/data/product_repository_factory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/services/product_service.dart';

void main() {
  group('ProductRepositoryFactory', () {
    tearDown(() {
      DemoMode.disable();
    });

    test('creates demo repository when demo mode is enabled', () {
      DemoMode.enable();

      final factory = ProductRepositoryFactory();

      final repository = factory.create(
        authToken: DemoMode.authToken,
        backendUrl: DemoMode.backendUrl,
      );

      expect(repository, isA<DemoProductRepository>());
    });

    test('creates Odoo repository when demo mode is disabled', () {
      DemoMode.disable();

      final factory = ProductRepositoryFactory();

      final repository = factory.create(
        authToken: DemoMode.authToken,
        backendUrl: DemoMode.backendUrl,
      );

      expect(repository, isA<OdooProductRepository>());
    });

    test('creates Odoo repository when token does not match demo token', () {
      DemoMode.enable();

      final factory = ProductRepositoryFactory();

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

        final factory = ProductRepositoryFactory();

        final repository = factory.create(
          authToken: DemoMode.authToken,
          backendUrl: 'https://example.com',
        );

        expect(repository, isA<OdooProductRepository>());
      },
    );
    test('creates product use cases', () {
      final factory = ProductRepositoryFactory();

      final useCases = factory.createUseCases(
        authToken: DemoMode.authToken,
        backendUrl: DemoMode.backendUrl,
      );

      expect(useCases, isA<ProductUseCases>());
    });

    test('uses injected product service for Odoo repository', () {
      final productService = ProductService();
      final factory = ProductRepositoryFactory(productService: productService);

      final repository = factory.create(
        authToken: 'real-token',
        backendUrl: 'https://example.com',
      );

      expect(repository, isA<OdooProductRepository>());
      expect(
        identical(
          (repository as OdooProductRepository).productService,
          productService,
        ),
        isTrue,
      );
    });
  });
}

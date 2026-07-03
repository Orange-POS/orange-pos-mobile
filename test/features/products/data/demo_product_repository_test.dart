import 'package:flutter_app/demo/demo_mode.dart';
import 'package:flutter_app/demo/demo_product_store.dart';
import 'package:flutter_app/features/products/data/demo_product_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DemoProductRepository', () {
    test('finds existing product by barcode', () async {
      final repository = DemoProductRepository(
        store: DemoProductStore.instance,
      );

      final product = await repository.findProductByBarcode(
        DemoMode.existingBarcode,
      );

      expect(product, isNotNull);
      expect(product!.barcode, DemoMode.existingBarcode);
    });

    test('returns null when barcode is unknown', () async {
      final repository = DemoProductRepository(
        store: DemoProductStore.instance,
      );

      final product = await repository.findProductByBarcode('444444');

      expect(product, isNull);
    });

    test('creates product', () async {
      final repository = DemoProductRepository(
        store: DemoProductStore.instance,
      );

      final product = await repository.createProduct(
        barcode: '444444',
        name: 'Repository Demo Product',
        price: 123.45,
        taxIds: const [1],
      );

      expect(product.barcode, '444444');
      expect(product.name, 'Repository Demo Product');
      expect(product.price, 123.45);
      expect(product.taxes.first.name, 'VAT 15%');
    });

    test('updates product price', () async {
      final repository = DemoProductRepository(
        store: DemoProductStore.instance,
      );

      final product = await repository.findProductByBarcode(
        DemoMode.existingBarcode,
      );

      final updatedProduct = await repository.updateProductPrice(
        product: product!,
        price: 555,
      );

      expect(updatedProduct.price, 555);
    });

    test('updates product name and tax', () async {
      final repository = DemoProductRepository(
        store: DemoProductStore.instance,
      );

      final product = await repository.findProductByBarcode(
        DemoMode.existingBarcode,
      );

      final updatedProduct = await repository.updateProduct(
        product: product!,
        name: 'Repository Updated Product',
        taxIds: const [2],
      );

      expect(updatedProduct.name, 'Repository Updated Product');
      expect(updatedProduct.taxes.first.name, 'Zero Tax');
    });

    test('loads product references', () async {
      final repository = DemoProductRepository(
        store: DemoProductStore.instance,
      );

      final references = await repository.loadProductReferences();

      expect(references.defaultTaxIds, [1]);
      expect(references.taxes.length, 2);
    });
  });
}
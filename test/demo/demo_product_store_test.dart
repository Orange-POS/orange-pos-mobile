import 'package:flutter_app/demo/demo_product_store.dart';
import 'package:flutter_app/demo/demo_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DemoProductStore', () {
    test('returns existing demo product by barcode', () {
      final product = DemoProductStore.instance.findByBarcode(
        DemoMode.existingBarcode,
      );

      expect(product, isNotNull);
      expect(product!.barcode, DemoMode.existingBarcode);
      expect(product.name, 'Demo Orange Juice');
      expect(product.price, 250);
    });

    test('returns null for unknown barcode before product is created', () {
      final product = DemoProductStore.instance.findByBarcode('555555');

      expect(product, isNull);
    });

    test('creates product and finds it by barcode', () {
      final product = DemoProductStore.instance.createProduct(
        barcode: '555555',
        name: 'Demo Created Product',
        price: 99.5,
        taxIds: const [1],
      );

      final foundProduct = DemoProductStore.instance.findByBarcode('555555');

      expect(foundProduct, isNotNull);
      expect(foundProduct!.id, product.id);
      expect(foundProduct.name, 'Demo Created Product');
      expect(foundProduct.price, 99.5);
      expect(foundProduct.taxes.length, 1);
      expect(foundProduct.taxes.first.name, 'VAT 15%');
    });

    test('updates product price', () {
      final product = DemoProductStore.instance.findByBarcode(
        DemoMode.existingBarcode,
      );

      final updatedProduct = DemoProductStore.instance.updatePrice(
        product: product!,
        price: 300,
      );

      expect(updatedProduct.price, 300);

      final foundProduct = DemoProductStore.instance.findByBarcode(
        DemoMode.existingBarcode,
      );

      expect(foundProduct!.price, 300);
    });

    test('updates product name and tax', () {
      final product = DemoProductStore.instance.findByBarcode(
        DemoMode.existingBarcode,
      );

      final updatedProduct = DemoProductStore.instance.updateProduct(
        product: product!,
        name: 'Updated Demo Product',
        taxIds: const [2],
      );

      expect(updatedProduct.name, 'Updated Demo Product');
      expect(updatedProduct.taxes.length, 1);
      expect(updatedProduct.taxes.first.name, 'Zero Tax');
    });

    test('returns references with taxes', () {
      final references = DemoProductStore.instance.references;

      expect(references.defaultTaxIds, [1]);
      expect(references.taxes.length, 2);
    });
  });
}

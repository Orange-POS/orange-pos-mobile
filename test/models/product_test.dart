import 'package:flutter_app/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product', () {
    test('parses valid json', () {
      final product = Product.fromJson({
        'id': 10,
        'name': 'Orange Juice',
        'price': 250.5,
        'barcode': '100001',
        'default_code': 'OJ-001',
        'uom': 'Units',
        'image': '',
        'stock_quantity': 12,
        'taxes': [
          {'id': 1, 'name': 'VAT 15%', 'amount': 15},
        ],
        'active': true,
      });

      expect(product.id, 10);
      expect(product.name, 'Orange Juice');
      expect(product.price, 250.5);
      expect(product.barcode, '100001');
      expect(product.defaultCode, 'OJ-001');
      expect(product.uom, 'Units');
      expect(product.stockQuantity, 12);
      expect(product.taxes.length, 1);
      expect(product.taxes.first.name, 'VAT 15%');
      expect(product.active, true);
    });

    test('uses safe fallback values for invalid json', () {
      final product = Product.fromJson({
        'id': 'invalid',
        'name': null,
        'price': 'invalid',
        'barcode': null,
        'stock_quantity': 'invalid',
        'taxes': 'invalid',
        'active': 'invalid',
      });

      expect(product.id, 0);
      expect(product.name, '');
      expect(product.price, 0);
      expect(product.barcode, '');
      expect(product.stockQuantity, 0);
      expect(product.taxes, isEmpty);
      expect(product.active, true);
    });

    test('formats price to two decimals', () {
      const product = Product(id: 1, name: 'Test Product', price: 25);

      expect(product.formattedPrice, '25.00');
    });

    test('returns default tax label when taxes are empty', () {
      const product = Product(id: 1, name: 'Test Product', price: 25);

      expect(product.taxLabel, 'Default');
    });

    test('returns comma separated tax label', () {
      final product = Product.fromJson({
        'id': 1,
        'name': 'Test Product',
        'price': 25,
        'taxes': [
          {'id': 1, 'name': 'VAT 15%', 'amount': 15},
          {'id': 2, 'name': 'City Tax', 'amount': 2},
        ],
      });

      expect(product.taxLabel, 'VAT 15%, City Tax');
    });

    test('copyWith updates selected fields', () {
      const product = Product(
        id: 1,
        name: 'Old Name',
        price: 10,
        barcode: '100001',
      );

      final updated = product.copyWith(name: 'New Name', price: 20);

      expect(updated.id, 1);
      expect(updated.name, 'New Name');
      expect(updated.price, 20);
      expect(updated.barcode, '100001');
    });
  });
}

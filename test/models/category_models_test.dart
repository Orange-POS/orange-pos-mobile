import 'package:flutter_app/models/pos_category.dart';
import 'package:flutter_app/models/product_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PosCategory', () {
    test('parses id and name from json', () {
      final category = PosCategory.fromJson({'id': '12', 'name': 'Beverages'});

      expect(category.id, 12);
      expect(category.name, 'Beverages');
    });

    test('uses fallback values for invalid json', () {
      final category = PosCategory.fromJson({'id': 'invalid', 'name': null});

      expect(category.id, 0);
      expect(category.name, '');
    });

    test('converts to json', () {
      const category = PosCategory(id: 7, name: 'Food');

      expect(category.toJson(), {'id': 7, 'name': 'Food'});
    });
  });

  group('ProductCategory', () {
    test('parses id and name from json', () {
      final category = ProductCategory.fromJson({
        'id': '22',
        'name': 'All Products',
      });

      expect(category.id, 22);
      expect(category.name, 'All Products');
    });

    test('uses fallback values for invalid json', () {
      final category = ProductCategory.fromJson({
        'id': 'invalid',
        'name': null,
      });

      expect(category.id, 0);
      expect(category.name, '');
    });

    test('converts to json', () {
      const category = ProductCategory(id: 3, name: 'Stockable');

      expect(category.toJson(), {'id': 3, 'name': 'Stockable'});
    });
  });
}

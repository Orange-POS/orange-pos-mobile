import 'package:flutter_app/models/product_references.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductReferences', () {
    test('uses empty defaults', () {
      const references = ProductReferences();

      expect(references.defaultTaxIds, isEmpty);
      expect(references.taxes, isEmpty);
    });

    test('parses default tax ids from int and string values', () {
      final references = ProductReferences.fromJson({
        'default_tax_ids': [1, '2', 'invalid', null, 3.0],
        'taxes': [],
      });

      expect(references.defaultTaxIds, [1, 2]);
    });
    test('returns empty default tax ids when value is not a list', () {
      final references = ProductReferences.fromJson({
        'default_tax_ids': 'not-a-list',
        'taxes': [],
      });

      expect(references.defaultTaxIds, isEmpty);
    });

    test('parses taxes from json list', () {
      final references = ProductReferences.fromJson({
        'default_tax_ids': [],
        'taxes': [
          {'id': 1, 'name': 'VAT 8.1%', 'amount': 8.1},
          {'id': '2', 'name': 'VAT 2.6%', 'amount': '2.6'},
        ],
      });

      expect(references.taxes, hasLength(2));
      expect(references.taxes[0].id, 1);
      expect(references.taxes[0].name, 'VAT 8.1%');
      expect(references.taxes[0].amount, 8.1);
      expect(references.taxes[1].id, 2);
      expect(references.taxes[1].name, 'VAT 2.6%');
      expect(references.taxes[1].amount, 2.6);
    });

    test('ignores non-map tax values', () {
      final references = ProductReferences.fromJson({
        'default_tax_ids': [],
        'taxes': [
          {'id': 1, 'name': 'VAT', 'amount': 8.1},
          'invalid',
          null,
        ],
      });

      expect(references.taxes, hasLength(1));
      expect(references.taxes.first.id, 1);
    });

    test('returns empty taxes when value is not a list', () {
      final references = ProductReferences.fromJson({
        'default_tax_ids': [],
        'taxes': 'not-a-list',
      });

      expect(references.taxes, isEmpty);
    });
  });
}

import 'package:flutter_app/models/product_tax.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductTax', () {
    test('parses valid json', () {
      final tax = ProductTax.fromJson({
        'id': 1,
        'name': 'VAT 15%',
        'amount': 15,
      });

      expect(tax.id, 1);
      expect(tax.name, 'VAT 15%');
      expect(tax.amount, 15);
    });

    test('uses safe fallback values for invalid json', () {
      final tax = ProductTax.fromJson({
        'id': 'invalid',
        'name': null,
        'amount': 'invalid',
      });

      expect(tax.id, 0);
      expect(tax.name, '');
      expect(tax.amount, 0);
    });

    test('converts to json', () {
      const tax = ProductTax(id: 2, name: 'Zero Tax', amount: 0);

      expect(tax.toJson(), {'id': 2, 'name': 'Zero Tax', 'amount': 0});
    });
  });
}

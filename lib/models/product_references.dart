import 'product_tax.dart';

class ProductReferences {
  final List<int> defaultTaxIds;
  final List<ProductTax> taxes;

  const ProductReferences({
    this.defaultTaxIds = const [],
    this.taxes = const [],
  });

  factory ProductReferences.fromJson(Map<String, dynamic> json) {
    return ProductReferences(
      defaultTaxIds: _parseIntList(json['default_tax_ids']),
      taxes: _parseTaxes(json['taxes']),
    );
  }

  static List<int> _parseIntList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .map((item) => int.tryParse(item.toString()))
        .whereType<int>()
        .toList();
  }

  static List<ProductTax> _parseTaxes(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map((item) => ProductTax.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}

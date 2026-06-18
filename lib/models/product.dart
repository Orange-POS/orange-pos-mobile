import 'pos_category.dart';
import 'product_category.dart';
import 'product_tax.dart';

class Product {
  final int id;
  final String name;
  final double price;
  final String barcode;
  final String defaultCode;
  final String uom;
  final String imageBase64;
  final double stockQuantity;
  final DateTime? priceUpdatedAt;
  final DateTime? stockUpdatedAt;
  final List<ProductTax> taxes;
  final List<PosCategory> posCategories;
  final ProductCategory? productCategory;
  final bool active;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.barcode = '',
    this.defaultCode = '',
    this.uom = '',
    this.imageBase64 = '',
    this.stockQuantity = 0,
    this.taxes = const [],
    this.posCategories = const [],
    this.productCategory,
    this.active = true,
    this.priceUpdatedAt,
    this.stockUpdatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      price: _parseDouble(json['price']),
      barcode: json['barcode']?.toString() ?? '',
      defaultCode: json['default_code']?.toString() ?? '',
      uom: json['uom']?.toString() ?? '',
      imageBase64: json['image']?.toString() ?? '',
      stockQuantity: _parseDouble(json['stock_quantity']),
      priceUpdatedAt: _parseDateTime(json['price_updated_at']),
      stockUpdatedAt: _parseDateTime(json['stock_updated_at']),
      taxes: _parseTaxes(json['taxes']),
      posCategories: _parsePosCategories(json['pos_categories']),
      productCategory: _parseProductCategory(json['product_category']),
      active: _parseBool(json['active'], fallback: true),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null || value == false || value.toString().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value.toString());
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

  static List<PosCategory> _parsePosCategories(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map((item) => PosCategory.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static ProductCategory? _parseProductCategory(dynamic value) {
    if (value is! Map) {
      return null;
    }

    return ProductCategory.fromJson(Map<String, dynamic>.from(value));
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _parseBool(dynamic value, {required bool fallback}) {
    if (value is bool) {
      return value;
    }

    if (value == 1 || value?.toString().toLowerCase() == 'true') {
      return true;
    }

    if (value == 0 || value?.toString().toLowerCase() == 'false') {
      return false;
    }

    return fallback;
  }

  String get formattedPrice {
    return price.toStringAsFixed(2);
  }

  String get formattedStock {
    final quantity = stockQuantity.toStringAsFixed(2);

    if (uom.isEmpty) {
      return quantity;
    }

    return '$quantity $uom';
  }

  String get taxLabel {
    if (taxes.isEmpty) {
      return 'Default';
    }

    return taxes.map((tax) => tax.name).join(', ');
  }

  String get posCategoryLabel {
    if (posCategories.isEmpty) {
      return 'Not assigned';
    }

    return posCategories.map((category) => category.name).join(', ');
  }

  String get productCategoryLabel {
    return productCategory?.name ?? 'Not assigned';
  }

  String get priceUpdatedLabel {
    return _formatDateTime(priceUpdatedAt);
  }

  String get stockUpdatedLabel {
    return _formatDateTime(stockUpdatedAt);
  }

  bool get hasImage {
    return imageBase64.isNotEmpty;
  }

  static String _formatDateTime(DateTime? value) {
    if (value == null) {
      return 'Not available';
    }

    final localValue = value.toLocal();

    final day = localValue.day.toString().padLeft(2, '0');
    final month = localValue.month.toString().padLeft(2, '0');
    final year = localValue.year.toString();

    final hour = localValue.hour.toString().padLeft(2, '0');
    final minute = localValue.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'barcode': barcode,
      'default_code': defaultCode,
      'uom': uom,
      'image': imageBase64,
      'stock_quantity': stockQuantity,
      'taxes': taxes.map((tax) => tax.toJson()).toList(),
      'pos_categories': posCategories
          .map((category) => category.toJson())
          .toList(),
      'product_category': productCategory?.toJson(),
      'active': active,
      'price_updated_at': priceUpdatedAt?.toIso8601String(),
      'stock_updated_at': stockUpdatedAt?.toIso8601String(),
    };
  }

  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? barcode,
    String? defaultCode,
    String? uom,
    String? imageBase64,
    double? stockQuantity,
    List<ProductTax>? taxes,
    List<PosCategory>? posCategories,
    ProductCategory? productCategory,
    DateTime? priceUpdatedAt,
    DateTime? stockUpdatedAt,
    bool? active,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      barcode: barcode ?? this.barcode,
      defaultCode: defaultCode ?? this.defaultCode,
      uom: uom ?? this.uom,
      imageBase64: imageBase64 ?? this.imageBase64,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      taxes: taxes ?? this.taxes,
      posCategories: posCategories ?? this.posCategories,
      productCategory: productCategory ?? this.productCategory,
      priceUpdatedAt: priceUpdatedAt ?? this.priceUpdatedAt,
      stockUpdatedAt: stockUpdatedAt ?? this.stockUpdatedAt,
      active: active ?? this.active,
    );
  }
}

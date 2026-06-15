import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/product.dart';

class ScannedProductStorage {
  static final ScannedProductStorage instance =
      ScannedProductStorage._internal();

  ScannedProductStorage._internal();

  static const String _productsKey = 'scanned_products';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveProducts(List<Product> products) async {
    final jsonList = products.map((product) => product.toJson()).toList();

    await _storage.write(
      key: _productsKey,
      value: jsonEncode(jsonList),
    );
  }

  Future<List<Product>> getProducts() async {
    final value = await _storage.read(key: _productsKey);

    if (value == null || value.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(value) as List<dynamic>;

    return decoded.map((item) {
      return Product.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  Future<void> clearProducts() async {
    await _storage.delete(key: _productsKey);
  }
}
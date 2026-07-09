import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/features/products/application/product_use_cases.dart';
import 'package:flutter_app/features/products/domain/product_repository.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/models/product_references.dart';

void main() {
  group('ProductUseCases', () {
    late _FakeProductRepository repository;
    late ProductUseCases useCases;

    setUp(() {
      repository = _FakeProductRepository();
      useCases = ProductUseCases(repository: repository);
    });

    test('findProductByBarcode delegates to repository', () async {
      final product = await useCases.findProductByBarcode('100001');

      expect(product?.barcode, '100001');
      expect(repository.lastBarcode, '100001');
    });

    test('createProduct delegates to repository', () async {
      final product = await useCases.createProduct(
        barcode: '200001',
        name: 'New Product',
        price: 12.5,
        taxIds: [1],
      );

      expect(product.name, 'New Product');
      expect(repository.createdBarcode, '200001');
      expect(repository.createdTaxIds, [1]);
    });

    test('updateProduct delegates to repository', () async {
      final original = _product(name: 'Old Product');

      final updated = await useCases.updateProduct(
        product: original,
        name: 'Updated Product',
        taxIds: [2],
      );

      expect(updated.name, 'Updated Product');
      expect(repository.updatedProduct?.id, original.id);
      expect(repository.updatedTaxIds, [2]);
    });

    test('updateProductPrice delegates to repository', () async {
      final original = _product(price: 5);

      final updated = await useCases.updateProductPrice(
        product: original,
        price: 9.95,
      );

      expect(updated.price, 9.95);
      expect(repository.updatedPrice, 9.95);
    });

    test('loadProductReferences delegates to repository', () async {
      final references = await useCases.loadProductReferences();

      expect(references.taxes, isEmpty);
      expect(repository.referencesLoaded, isTrue);
    });
  });
}

class _FakeProductRepository implements ProductRepository {
  String? lastBarcode;
  String? createdBarcode;
  List<int>? createdTaxIds;
  Product? updatedProduct;
  List<int>? updatedTaxIds;
  double? updatedPrice;
  bool referencesLoaded = false;

  @override
  Future<Product?> findProductByBarcode(String barcode) async {
    lastBarcode = barcode;
    return _product(barcode: barcode);
  }

  @override
  Future<Product> createProduct({
    required String barcode,
    required String name,
    required double price,
    List<int>? taxIds,
  }) async {
    createdBarcode = barcode;
    createdTaxIds = taxIds;

    return _product(barcode: barcode, name: name, price: price);
  }

  @override
  Future<Product> updateProduct({
    required Product product,
    required String name,
    List<int>? taxIds,
  }) async {
    updatedProduct = product;
    updatedTaxIds = taxIds;

    return product.copyWith(name: name);
  }

  @override
  Future<Product> updateProductPrice({
    required Product product,
    required double price,
  }) async {
    updatedProduct = product;
    updatedPrice = price;

    return product.copyWith(price: price);
  }

  @override
  Future<ProductReferences> loadProductReferences() async {
    referencesLoaded = true;
    return const ProductReferences();
  }
}

Product _product({
  int id = 1,
  String name = 'Demo Product',
  String barcode = '100001',
  double price = 10,
}) {
  return Product(
    id: id,
    name: name,
    barcode: barcode,
    price: price,
    taxes: const [],
  );
}

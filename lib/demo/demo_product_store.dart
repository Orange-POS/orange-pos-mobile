import '../models/product.dart';
import '../models/product_references.dart';
import '../models/product_tax.dart';

class DemoProductStore {
  DemoProductStore._();

  static final DemoProductStore instance = DemoProductStore._();

  final List<ProductTax> taxes = const [
    ProductTax(id: 1, name: 'VAT 15%', amount: 15),
    ProductTax(id: 2, name: 'Zero Tax', amount: 0),
  ];

  late final Map<String, Product> _products = {
    '100001': Product(
      id: 1,
      name: 'Demo Orange Juice',
      price: 250.00,
      barcode: '100001',
      taxes: [taxes.first],
    ),
    '100002': Product(
      id: 2,
      name: 'Demo Apple Pack',
      price: 480.00,
      barcode: '100002',
      taxes: [taxes.first],
    ),
  };

  int _nextProductId = 100;

  ProductReferences get references {
    return ProductReferences(defaultTaxIds: const [1], taxes: taxes);
  }

  Product? findByBarcode(String barcode) {
    return _products[barcode];
  }

  Product createProduct({
    required String barcode,
    required String name,
    required double price,
    List<int>? taxIds,
  }) {
    final product = Product(
      id: _nextProductId++,
      name: name,
      price: price,
      barcode: barcode,
      taxes: _taxesFromIds(taxIds),
    );

    _products[barcode] = product;
    return product;
  }

  Product updatePrice({required Product product, required double price}) {
    final updatedProduct = product.copyWith(price: price);

    _products[updatedProduct.barcode] = updatedProduct;
    return updatedProduct;
  }

  Product updateProduct({
    required Product product,
    required String name,
    List<int>? taxIds,
  }) {
    final updatedProduct = product.copyWith(
      name: name,
      taxes: _taxesFromIds(taxIds),
    );

    _products[updatedProduct.barcode] = updatedProduct;
    return updatedProduct;
  }

  List<ProductTax> _taxesFromIds(List<int>? taxIds) {
    if (taxIds == null || taxIds.isEmpty) {
      return [];
    }

    return taxes.where((tax) => taxIds.contains(tax.id)).toList();
  }
}

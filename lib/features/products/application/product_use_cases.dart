import '../../../models/product.dart';
import '../../../models/product_references.dart';
import '../domain/product_repository.dart';

class ProductUseCases {
  final ProductRepository repository;

  const ProductUseCases({required this.repository});

  Future<Product?> findProductByBarcode(String barcode) {
    return repository.findProductByBarcode(barcode);
  }

  Future<Product> createProduct({
    required String barcode,
    required String name,
    required double price,
    List<int>? taxIds,
  }) {
    return repository.createProduct(
      barcode: barcode,
      name: name,
      price: price,
      taxIds: taxIds,
    );
  }

  Future<Product> updateProduct({
    required Product product,
    required String name,
    List<int>? taxIds,
  }) {
    return repository.updateProduct(
      product: product,
      name: name,
      taxIds: taxIds,
    );
  }

  Future<Product> updateProductPrice({
    required Product product,
    required double price,
  }) {
    return repository.updateProductPrice(product: product, price: price);
  }

  Future<ProductReferences> loadProductReferences() {
    return repository.loadProductReferences();
  }
}

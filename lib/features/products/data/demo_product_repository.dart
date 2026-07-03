import '../../../../demo/demo_product_store.dart';
import '../../../../models/product.dart';
import '../../../../models/product_references.dart';
import '../domain/product_repository.dart';

class DemoProductRepository implements ProductRepository {
  final DemoProductStore store;

  const DemoProductRepository({required this.store});

  @override
  Future<Product?> findProductByBarcode(String barcode) async {
    return store.findByBarcode(barcode);
  }

  @override
  Future<Product> createProduct({
    required String barcode,
    required String name,
    required double price,
    List<int>? taxIds,
  }) async {
    return store.createProduct(
      barcode: barcode,
      name: name,
      price: price,
      taxIds: taxIds,
    );
  }

  @override
  Future<Product> updateProduct({
    required Product product,
    required String name,
    List<int>? taxIds,
  }) async {
    return store.updateProduct(product: product, name: name, taxIds: taxIds);
  }

  @override
  Future<Product> updateProductPrice({
    required Product product,
    required double price,
  }) async {
    return store.updatePrice(product: product, price: price);
  }

  @override
  Future<ProductReferences> loadProductReferences() async {
    return store.references;
  }
}

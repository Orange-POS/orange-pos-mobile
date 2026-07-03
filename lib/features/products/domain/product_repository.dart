import '../../../models/product.dart';
import '../../../models/product_references.dart';

abstract class ProductRepository {
  Future<Product?> findProductByBarcode(String barcode);

  Future<Product> createProduct({
    required String barcode,
    required String name,
    required double price,
    List<int>? taxIds,
  });

  Future<Product> updateProduct({
    required Product product,
    required String name,
    List<int>? taxIds,
  });

  Future<Product> updateProductPrice({
    required Product product,
    required double price,
  });

  Future<ProductReferences> loadProductReferences();
}

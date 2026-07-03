import '../../../models/product.dart';
import '../../../models/product_references.dart';
import '../../../services/product_service.dart';
import '../domain/product_repository.dart';

class OdooProductRepository implements ProductRepository {
  final ProductService productService;
  final String authToken;
  final String backendUrl;

  const OdooProductRepository({
    required this.productService,
    required this.authToken,
    required this.backendUrl,
  });

  @override
  Future<Product?> findProductByBarcode(String barcode) {
    return productService.findProductByBarcode(
      authToken: authToken,
      backendUrl: backendUrl,
      barcode: barcode,
    );
  }

  @override
  Future<Product> createProduct({
    required String barcode,
    required String name,
    required double price,
    List<int>? taxIds,
  }) {
    return productService.createProduct(
      authToken: authToken,
      backendUrl: backendUrl,
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
  }) {
    return productService.updateProduct(
      authToken: authToken,
      backendUrl: backendUrl,
      product: product,
      name: name,
      taxIds: taxIds,
    );
  }

  @override
  Future<Product> updateProductPrice({
    required Product product,
    required double price,
  }) {
    return productService.updateProductPrice(
      authToken: authToken,
      backendUrl: backendUrl,
      product: product,
      price: price.toString(),
    );
  }

  @override
  Future<ProductReferences> loadProductReferences() {
    return productService.loadProductReferences(
      authToken: authToken,
      backendUrl: backendUrl,
    );
  }
}

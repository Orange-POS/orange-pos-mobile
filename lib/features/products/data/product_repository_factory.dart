import '../../../demo/demo_mode.dart';
import '../../../demo/demo_product_store.dart';
import '../../../services/product_service.dart';
import '../domain/product_repository.dart';
import 'demo_product_repository.dart';
import 'odoo_product_repository.dart';

class ProductRepositoryFactory {
  const ProductRepositoryFactory();

  ProductRepository create({
    required String authToken,
    required String backendUrl,
  }) {
    final isDemoMode =
        DemoMode.available &&
        DemoMode.enabled &&
        authToken == DemoMode.authToken &&
        backendUrl == DemoMode.backendUrl;

    if (isDemoMode) {
      return DemoProductRepository(store: DemoProductStore.instance);
    }

    return OdooProductRepository(
      productService: ProductService(),
      authToken: authToken,
      backendUrl: backendUrl,
    );
  }
}

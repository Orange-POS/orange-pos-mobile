import '../../../demo/demo_mode.dart';
import '../../../demo/demo_product_store.dart';
import '../../../services/product_service.dart';
import '../domain/product_repository.dart';
import 'demo_product_repository.dart';
import 'odoo_product_repository.dart';
import '../application/product_use_cases.dart';

class ProductRepositoryFactory {
  final ProductService productService;

  ProductRepositoryFactory({ProductService? productService})
    : productService = productService ?? ProductService();

  ProductUseCases createUseCases({
    required String authToken,
    required String backendUrl,
  }) {
    return ProductUseCases(
      repository: create(authToken: authToken, backendUrl: backendUrl),
    );
  }

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
      productService: productService,
      authToken: authToken,
      backendUrl: backendUrl,
    );
  }
}

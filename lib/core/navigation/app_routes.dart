import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../models/product_references.dart';
import '../../screens/add_product_screen.dart';
import '../../screens/edit_product_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/product_screen.dart';
import '../../screens/scanner_screen.dart';
import '../../screens/update_price_screen.dart';
import '../di/app_dependencies.dart';

class AppRoutes {
  const AppRoutes._();

  static MaterialPageRoute<void> login({
    required AppDependencies dependencies,
  }) {
    return MaterialPageRoute(
      builder: (context) => LoginScreen(dependencies: dependencies),
    );
  }

  static MaterialPageRoute<void> scanner({
    required String authToken,
    required String backendUrl,
    required AppDependencies dependencies,
  }) {
    return MaterialPageRoute(
      builder: (context) => ScannerScreen(
        authToken: authToken,
        backendUrl: backendUrl,
        dependencies: dependencies,
      ),
    );
  }

  static MaterialPageRoute<Product> product({
    required Product product,
    required String authToken,
    required String backendUrl,
    required AppDependencies dependencies,
  }) {
    return MaterialPageRoute(
      builder: (context) => ProductScreen(
        product: product,
        authToken: authToken,
        backendUrl: backendUrl,
        dependencies: dependencies,
      ),
    );
  }

  static MaterialPageRoute<Product> addProduct({
    required String barcode,
    required String authToken,
    required String backendUrl,
    required AppDependencies dependencies,
  }) {
    return MaterialPageRoute(
      builder: (context) => AddProductScreen(
        barcode: barcode,
        authToken: authToken,
        backendUrl: backendUrl,
        dependencies: dependencies,
      ),
    );
  }

  static MaterialPageRoute<Product> updatePrice({
    required Product product,
    required String authToken,
    required String backendUrl,
    required AppDependencies dependencies,
  }) {
    return MaterialPageRoute(
      builder: (context) => UpdatePriceScreen(
        product: product,
        authToken: authToken,
        backendUrl: backendUrl,
        dependencies: dependencies,
      ),
    );
  }

  static MaterialPageRoute<Product> editProduct({
    required Product product,
    required String authToken,
    required String backendUrl,
    required AppDependencies dependencies,
    ProductReferences? initialReferences,
  }) {
    return MaterialPageRoute(
      builder: (context) => EditProductScreen(
        product: product,
        authToken: authToken,
        backendUrl: backendUrl,
        dependencies: dependencies,
        initialReferences: initialReferences,
      ),
    );
  }
}

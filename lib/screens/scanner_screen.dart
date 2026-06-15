import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../services/token_storage.dart';
import '../widgets/app_page.dart';
import 'barcode_not_found_screen.dart';
import 'barcode_scanner_screen.dart';
import 'login_screen.dart';
import 'product_screen.dart';
import 'add_product_screen.dart';

class ScannerScreen extends StatefulWidget {
  final String authToken;
  final String backendUrl;

  const ScannerScreen({
    super.key,
    required this.authToken,
    required this.backendUrl,
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ProductService productService = ProductService();
  final TokenStorage tokenStorage = TokenStorage.instance;

  bool isLoading = false;
  String? errorMessage;

  Future<void> scanBarcode() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(),
      ),
    );

    if (!mounted || barcode == null || barcode.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final product = await productService.findProductByBarcode(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        barcode: barcode,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      if (product == null) {
        await openBarcodeNotFound(barcode);
        return;
      }

      await openProduct(product);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage = 'Could not find product. Please try again.';
      });

      debugPrint('Product lookup failed: $error');
    }
  }

  

  Future<void> openProduct(Product product) async {
    await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductScreen(
          product: product,
          authToken: widget.authToken,
          backendUrl: widget.backendUrl,
        ),
      ),
    );
  }

  Future<void> logout() async {
    await tokenStorage.clearSession();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> openBarcodeNotFound(String barcode) async {
  final shouldAddProduct = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) => BarcodeNotFoundScreen(
        barcode: barcode,
      ),
    ),
  );

  if (!mounted || shouldAddProduct != true) {
    return;
  }

  final createdProduct = await Navigator.push<Product>(
    context,
    MaterialPageRoute(
      builder: (context) => AddProductScreen(
        barcode: barcode,
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
      ),
    ),
  );

  if (!mounted || createdProduct == null) {
    return;
  }

  await openProduct(createdProduct);
}

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Scanner',
      leadingIcon: Icons.view_week,
      onProfilePressed: logout,
      child: Column(
        children: [
          const Spacer(),
          GestureDetector(
            onTap: isLoading ? null : scanBarcode,
            child: Container(
              width: 190,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : const Icon(
                      Icons.barcode_reader,
                      size: 110,
                      color: Colors.black,
                    ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Scan Products',
            style: TextStyle(fontSize: 17),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 20),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
              ),
            ),
          ],
          const Spacer(),
        ],
      ),
    );
  }
}
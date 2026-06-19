import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';
import '../services/analytics_service.dart';
import '../services/api_client.dart';
import '../services/product_service.dart';
import '../services/token_storage.dart';
import '../theme/app_brand.dart';
import '../widgets/app_chrome.dart';

import 'add_product_screen.dart';

import 'barcode_scanner_screen.dart';
import 'login_screen.dart';
import 'product_screen.dart';

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
  final AnalyticsService analyticsService = AnalyticsService();

  bool isLoading = false;
  bool isScannerOpen = false;
  bool isLookingUpProduct = false;

  String? errorMessage;
  String? errorDetails;

  String? lastScannedBarcode;
  DateTime? lastScanTime;

  bool shouldIgnoreDuplicateScan(String barcode) {
    final previousBarcode = lastScannedBarcode;
    final previousScanTime = lastScanTime;

    if (previousBarcode == null || previousScanTime == null) {
      return false;
    }

    final isSameBarcode = previousBarcode == barcode;
    final isTooSoon =
        DateTime.now().difference(previousScanTime) <
        const Duration(seconds: 2);

    return isSameBarcode && isTooSoon;
  }

  void rememberScan(String barcode) {
    lastScannedBarcode = barcode;
    lastScanTime = DateTime.now();
  }

  void clearLastScan() {
    lastScannedBarcode = null;
    lastScanTime = null;
  }

  Future<void> scanBarcode() async {
    if (isScannerOpen || isLookingUpProduct || isLoading) {
      return;
    }

    isScannerOpen = true;

    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    isScannerOpen = false;

    final scannedBarcode = barcode?.trim();

    if (!mounted || scannedBarcode == null || scannedBarcode.isEmpty) {
      return;
    }

    if (shouldIgnoreDuplicateScan(scannedBarcode)) {
      return;
    }

    rememberScan(scannedBarcode);

    if (isLookingUpProduct) {
      return;
    }

    isLookingUpProduct = true;

    unawaited(
      analyticsService.trackEvent(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        eventName: 'product_scanned',
        screen: 'scanner',
        metadata: {'barcode': scannedBarcode},
      ),
    );

    setState(() {
      isLoading = true;
      errorMessage = null;
      errorDetails = null;
    });

    try {
      final product = await productService.findProductByBarcode(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        barcode: scannedBarcode,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      if (product == null) {
        unawaited(
          analyticsService.trackEvent(
            authToken: widget.authToken,
            backendUrl: widget.backendUrl,
            eventName: 'product_not_found',
            screen: 'scanner',
            metadata: {'barcode': scannedBarcode},
          ),
        );

        final createdProduct = await openAddProduct(scannedBarcode);

        if (createdProduct != null) {
          await openProduct(createdProduct);
        }

        clearLastScan();
        return;
      }

      unawaited(
        analyticsService.trackEvent(
          authToken: widget.authToken,
          backendUrl: widget.backendUrl,
          eventName: 'product_found',
          screen: 'scanner',
          metadata: {'barcode': scannedBarcode, 'product_id': product.id},
        ),
      );

      await openProduct(product);
      clearLastScan();
    } catch (error) {
      if (!mounted) {
        return;
      }

      final lookupError = error is ApiClientException
          ? error.userMessage
          : error.toString().replaceFirst('Exception: ', '');

      final details = error is ApiClientException
          ? error.diagnosticDetails
          : error.toString();

      setState(() {
        errorMessage = lookupError;
        errorDetails = details;
      });

      unawaited(
        analyticsService.trackError(
          authToken: widget.authToken,
          backendUrl: widget.backendUrl,
          errorType: 'api_error',
          screen: 'scanner',
          message: lookupError,
          details: details,
        ),
      );

      debugPrint('Product lookup failed: $error');
    } finally {
      isLookingUpProduct = false;

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> copyErrorDetails() async {
    final details = errorDetails;

    if (details == null || details.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: details));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product lookup error copied.')),
    );
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
    unawaited(
      analyticsService.trackEvent(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        eventName: 'logout',
        screen: 'scanner',
      ),
    );

    await tokenStorage.clearSession();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<Product?> openAddProduct(String barcode) async {
    return Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          barcode: barcode,
          authToken: widget.authToken,
          backendUrl: widget.backendUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppBrand.white,
      body: SafeArea(
        child: Padding(
          padding: AppChrome.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader.brand(onProfilePressed: logout),
              const SizedBox(height: 34),
              const Text(
                'Scanner',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppBrand.textDarkGrey,
                ),
              ),
              const Spacer(flex: 2),
              Center(
                child: GestureDetector(
                  onTap: isLoading ? null : scanBarcode,
                  child: Container(
                    width: 305,
                    height: 334,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF6EE),
                      borderRadius: BorderRadius.circular(49),
                      boxShadow: [
                        BoxShadow(
                          color: AppBrand.primaryDark.withValues(alpha: 0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _ScannerBarcodeGraphic(),
                              SizedBox(height: 18),
                              Text(
                                'Tap to Scan\nProducts',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  height: 1.42,
                                  color: AppBrand.textPrimary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 18),
                _ScannerErrorBox(
                  errorMessage: errorMessage!,
                  errorDetails: errorDetails,
                  onCopyDetails: copyErrorDetails,
                ),
              ],
              const Spacer(flex: 3),
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerBarcodeGraphic extends StatelessWidget {
  const _ScannerBarcodeGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 130,
      child: CustomPaint(painter: _ScannerBarcodePainter()),
    );
  }
}

class _ScannerBarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppBrand.primary
      ..style = PaintingStyle.fill;

    final barTop = size.height * 0.12;
    final barHeight = size.height * 0.76;
    final radius = Radius.circular(size.width * 0.025);

    final bars = <double>[9, 5, 15, 5, 8, 20, 6, 15, 5, 14];
    final gaps = <double>[8, 9, 8, 9, 9, 8, 8, 9, 8];

    var totalWidth = bars.fold<double>(0, (sum, width) => sum + width);
    totalWidth += gaps.fold<double>(0, (sum, gap) => sum + gap);

    var x = (size.width - totalWidth) / 2;

    for (var i = 0; i < bars.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, barTop, bars[i], barHeight),
          radius,
        ),
        paint,
      );

      if (i < gaps.length) {
        x += bars[i] + gaps[i];
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _ScannerErrorBox extends StatelessWidget {
  final String errorMessage;
  final String? errorDetails;
  final VoidCallback onCopyDetails;

  const _ScannerErrorBox({
    required this.errorMessage,
    required this.errorDetails,
    required this.onCopyDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppBrand.errorBackground,
        border: Border.all(color: AppBrand.errorBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Lookup Failed',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: const TextStyle(color: AppBrand.textPrimary, fontSize: 13),
          ),
          if (errorDetails != null) ...[
            const SizedBox(height: 10),
            SelectableText(
              errorDetails!,
              style: const TextStyle(
                fontSize: 10,
                color: AppBrand.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onCopyDetails,
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy Error Details'),
            ),
          ],
        ],
      ),
    );
  }
}

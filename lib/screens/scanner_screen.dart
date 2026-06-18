import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';
import '../services/analytics_service.dart';
import '../services/api_client.dart';
import '../services/product_service.dart';
import '../services/token_storage.dart';

import 'add_product_screen.dart';
import 'barcode_not_found_screen.dart';
import 'barcode_scanner_screen.dart';
import 'login_screen.dart';
import 'product_screen.dart';
import '../theme/app_brand.dart';

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

        await openBarcodeNotFound(scannedBarcode);
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

  Future<void> openBarcodeNotFound(String barcode) async {
    final shouldAddProduct = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeNotFoundScreen(barcode: barcode),
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
    return Scaffold(
      backgroundColor: AppBrand.loginBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 24, 30, 24),
          child: Column(
            children: [
              _ScannerHeader(onProfilePressed: logout),
              const SizedBox(height: 210),
              GestureDetector(
                onTap: isLoading ? null : scanBarcode,
                child: Container(
                  width: 280,
                  height: 177,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: AppBrand.primary, width: 4),
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const Icon(
                          Icons.barcode_reader,
                          size: 135,
                          color: AppBrand.primary,
                        ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Tap to Scan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppBrand.textPrimary,
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
              const Spacer(),
              const _ScannerFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerHeader extends StatelessWidget {
  final VoidCallback onProfilePressed;

  const _ScannerHeader({required this.onProfilePressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 48),
        const Expanded(
          child: Text(
            'Scanner',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppBrand.textDarkGrey,
            ),
          ),
        ),
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton.filledTonal(
            onPressed: onProfilePressed,
            icon: const Icon(Icons.person_outline),
            color: AppBrand.textPrimary,
            style: IconButton.styleFrom(backgroundColor: AppBrand.white),
          ),
        ),
      ],
    );
  }
}

class _ScannerFooter extends StatelessWidget {
  const _ScannerFooter();

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Powered By ',
            style: TextStyle(
              color: AppBrand.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: 'OrangePos',
            style: TextStyle(
              color: AppBrand.primary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
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

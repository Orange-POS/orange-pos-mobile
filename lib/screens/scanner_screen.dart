import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../demo/demo_mode.dart';
import '../features/products/data/product_repository_factory.dart';
import '../models/product.dart';
import '../services/analytics_service.dart';

import '../services/token_storage.dart';
import '../theme/app_brand.dart';
import '../widgets/app_chrome.dart';

import 'barcode_scanner_screen.dart';

import '../core/di/app_dependencies.dart';
import '../core/navigation/app_routes.dart';
import '../core/errors/app_error.dart';
import '../core/analytics/analytics_events.dart';
import '../core/widgets/app_error_state.dart';

class ScannerScreen extends StatefulWidget {
  final String authToken;
  final String backendUrl;
  final AppDependencies dependencies;

  const ScannerScreen({
    super.key,
    required this.authToken,
    required this.backendUrl,
    required this.dependencies,
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  TokenStorage get tokenStorage => widget.dependencies.tokenStorage;
  AnalyticsService get analyticsService => widget.dependencies.analyticsService;

  ProductRepositoryFactory get productRepositoryFactory {
    return widget.dependencies.productRepositoryFactory;
  }

  bool isLoading = false;
  bool isScannerOpen = false;
  bool isLookingUpProduct = false;

  String? errorMessage;
  String? errorDetails;

  String? lastScannedBarcode;
  DateTime? lastScanTime;

  bool get isDemoMode {
    return DemoMode.available &&
        DemoMode.enabled &&
        widget.authToken == DemoMode.authToken &&
        widget.backendUrl == DemoMode.backendUrl;
  }

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

  Future<String?> pickDemoBarcode() async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppBrand.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Demo Barcode',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppBrand.textDarkGrey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose a sample barcode for Apple review testing.',
                  style: TextStyle(fontSize: 14, color: AppBrand.textSecondary),
                ),
                const SizedBox(height: 18),
                _DemoBarcodeOption(
                  title: 'Existing product',
                  subtitle: 'Barcode 100001',
                  onTap: () => Navigator.pop(context, DemoMode.existingBarcode),
                ),
                const SizedBox(height: 10),
                _DemoBarcodeOption(
                  title: 'Unknown product',
                  subtitle: 'Barcode 999999',
                  onTap: () => Navigator.pop(context, DemoMode.unknownBarcode),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> scanBarcode() async {
    if (isScannerOpen || isLookingUpProduct || isLoading) {
      return;
    }

    isScannerOpen = true;

    final barcode = isDemoMode
        ? await pickDemoBarcode()
        : await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (context) => const BarcodeScannerScreen(),
            ),
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
        eventName: AnalyticsEvents.productScanned,
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
      final productRepository = productRepositoryFactory.create(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
      );

      final product = await productRepository.findProductByBarcode(
        scannedBarcode,
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
            eventName: AnalyticsEvents.productNotFound,
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
          eventName: AnalyticsEvents.productFound,
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

      final appError = AppError.fromException(error);

      setState(() {
        errorMessage = appError.userMessage;
        errorDetails = appError.diagnosticDetails;
      });

      unawaited(
        analyticsService.trackError(
          authToken: widget.authToken,
          backendUrl: widget.backendUrl,
          errorType: AnalyticsErrorTypes.fromAppErrorType(appError.type),
          screen: 'scanner',
          message: appError.userMessage,
          details: appError.diagnosticDetails,
        ),
      );

      debugPrint('Product lookup failed: ${appError.diagnosticDetails}');
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
      AppRoutes.product(
        product: product,
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        dependencies: widget.dependencies,
      ),
    );
  }

  Future<void> logout() async {
    unawaited(
      analyticsService.trackEvent(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        eventName: AnalyticsEvents.logout,
        screen: 'scanner',
      ),
    );

    if (isDemoMode) {
      DemoMode.disable();
    }

    await tokenStorage.clearSession();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      AppRoutes.login(dependencies: widget.dependencies),
      (route) => false,
    );
  }

  Future<Product?> openAddProduct(String barcode) async {
    return Navigator.push<Product>(
      context,
      AppRoutes.addProduct(
        barcode: barcode,
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        dependencies: widget.dependencies,
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
              if (isDemoMode) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppBrand.primaryLight,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppBrand.primary),
                  ),
                  child: const Text(
                    'Demo Mode',
                    style: TextStyle(
                      color: AppBrand.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
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
                AppErrorState.box(
                  title: 'Product Lookup Failed',
                  message: errorMessage!,
                  details: errorDetails,
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

class _DemoBarcodeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DemoBarcodeOption({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppBrand.primaryLight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              const Icon(
                Icons.qr_code_scanner,
                color: AppBrand.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppBrand.textDarkGrey,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppBrand.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppBrand.primary),
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

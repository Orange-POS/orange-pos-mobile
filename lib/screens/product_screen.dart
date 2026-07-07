import 'package:flutter/material.dart';

import '../demo/demo_mode.dart';
import '../models/product.dart';
import '../theme/app_brand.dart';
import '../widgets/app_chrome.dart';

import '../core/di/app_dependencies.dart';
import '../core/navigation/app_routes.dart';

class ProductScreen extends StatefulWidget {
  final Product product;
  final String authToken;
  final String backendUrl;
  final AppDependencies dependencies;
  const ProductScreen({
    super.key,
    required this.product,
    required this.authToken,
    required this.backendUrl,
    required this.dependencies,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Product product;
  bool isSaving = false;

  bool get isDemoMode {
    return DemoMode.available &&
        DemoMode.enabled &&
        widget.authToken == DemoMode.authToken &&
        widget.backendUrl == DemoMode.backendUrl;
  }

  @override
  void initState() {
    super.initState();
    product = widget.product;
  }

  Future<void> openUpdatePrice() async {
    final updatedProduct = await Navigator.push<Product>(
      context,
      AppRoutes.updatePrice(
        product: widget.product,
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        dependencies: widget.dependencies,
      ),
    );

    if (!mounted || updatedProduct == null) {
      return;
    }

    setState(() {
      product = updatedProduct;
    });
  }

  Future<void> openEditProduct() async {
    final updatedProduct = await Navigator.push<Product>(
      context,
      AppRoutes.editProduct(
        product: widget.product,
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        dependencies: widget.dependencies,
      ),
    );

    if (!mounted || updatedProduct == null) {
      return;
    }

    setState(() {
      product = updatedProduct;
    });
  }

  void closeScreen() {
    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          closeScreen();
        }
      },
      child: Scaffold(
        backgroundColor: AppBrand.white,
        body: SafeArea(
          child: Padding(
            padding: AppChrome.pagePadding,
            child: Column(
              children: [
                AppHeader.title(
                  title: 'Product Details',
                  onBackPressed: closeScreen,
                ),
                const SizedBox(height: 13),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (isDemoMode) ...[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: _DemoBadge(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        _ProductNameCard(productName: product.name),
                        const SizedBox(height: 24),
                        _ProductInfoSection(product: product),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _ProductButton(
                  icon: Icons.sell_outlined,
                  label: 'Update Price',
                  onPressed: isSaving ? null : openUpdatePrice,
                ),
                const SizedBox(height: 10),
                _ProductButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit Name & Tax',
                  onPressed: isSaving ? null : openEditProduct,
                ),
                const SizedBox(height: 10),
                const AppFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoBadge extends StatelessWidget {
  const _DemoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppBrand.primaryLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppBrand.primary),
      ),
      child: const Text(
        'Demo Product',
        style: TextStyle(color: AppBrand.primary, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ProductNameCard extends StatelessWidget {
  final String productName;

  const _ProductNameCard({required this.productName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 141,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF6EE),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(
              255,
              248,
              170,
              153,
            ).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Scrollbar(
        thumbVisibility: false,
        child: SingleChildScrollView(
          child: Text(
            productName,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.18,
              color: Color.fromARGB(255, 246, 96, 46),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductInfoSection extends StatelessWidget {
  final Product product;

  const _ProductInfoSection({required this.product});

  String get priceWithoutCurrency {
    return product.formattedPrice.replaceFirst('CHF', '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(
          icon: const _BarcodeIcon(),
          label: 'Barcode',
          value: product.barcode.isEmpty ? 'Not available' : product.barcode,
          valueFontSize: 22,
          valueWeight: FontWeight.w800,
        ),
        const SizedBox(height: 16),
        const _OrangeDivider(),
        const SizedBox(height: 26),
        _PriceRow(price: priceWithoutCurrency),
        const SizedBox(height: 16),
        const _OrangeDivider(),
        const SizedBox(height: 26),
        _InfoRow(
          icon: const Icon(Icons.percent, size: 34, color: AppBrand.primary),
          label: 'Tax',
          value: product.taxLabel,
          valueFontSize: 32,
          valueWeight: FontWeight.w400,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final double valueFontSize;
  final FontWeight valueWeight;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueFontSize,
    required this.valueWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 56, child: Center(child: icon)),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: _labelStyle),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: valueFontSize,
                  fontWeight: valueWeight,
                  color: AppBrand.textDarkGrey,
                  height: 1.08,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String price;

  const _PriceRow({required this.price});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 56,
          child: Center(
            child: Icon(Icons.sell, size: 34, color: AppBrand.primary),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Price', style: _labelStyle),
              const SizedBox(height: 12),
              const Text(
                'CHF',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppBrand.textDarkGrey,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                price,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppBrand.textDarkGrey,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

const TextStyle _labelStyle = TextStyle(
  fontSize: 17,
  color: AppBrand.textDarkGrey,
  fontWeight: FontWeight.w400,
);

class _OrangeDivider extends StatelessWidget {
  const _OrangeDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 74),
      height: 3,
      width: double.infinity,
      color: AppBrand.primary,
    );
  }
}

class _ProductButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ProductButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 76,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppBrand.primaryDark,
          foregroundColor: AppBrand.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          children: [
            const Spacer(),
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 36),
          ],
        ),
      ),
    );
  }
}

class _BarcodeIcon extends StatelessWidget {
  const _BarcodeIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 34,
      child: CustomPaint(painter: _BarcodeIconPainter()),
    );
  }
}

class _BarcodeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppBrand.primary
      ..style = PaintingStyle.fill;

    final bars = <double>[3, 2, 4, 2, 3, 5, 2, 4, 2, 3, 4, 2];
    final gaps = <double>[2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2];

    var totalWidth = bars.fold<double>(0, (sum, width) => sum + width);
    totalWidth += gaps.fold<double>(0, (sum, gap) => sum + gap);

    var x = (size.width - totalWidth) / 2;
    final top = size.height * 0.12;
    final height = size.height * 0.76;

    for (var i = 0; i < bars.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, top, bars[i], height),
          const Radius.circular(1),
        ),
        paint,
      );

      if (i < gaps.length) {
        x += bars[i] + gaps[i];
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

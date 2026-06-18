import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_brand.dart';
import 'edit_product_screen.dart';
import 'update_price_screen.dart';

class ProductScreen extends StatefulWidget {
  final Product product;
  final String authToken;
  final String backendUrl;

  const ProductScreen({
    super.key,
    required this.product,
    required this.authToken,
    required this.backendUrl,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Product product;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    product = widget.product;
  }

  Future<void> openUpdatePrice() async {
    final updatedProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (context) => UpdatePriceScreen(
          product: product,
          authToken: widget.authToken,
          backendUrl: widget.backendUrl,
        ),
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
      MaterialPageRoute(
        builder: (context) => EditProductScreen(
          product: product,
          authToken: widget.authToken,
          backendUrl: widget.backendUrl,
        ),
      ),
    );

    if (!mounted || updatedProduct == null) {
      return;
    }

    setState(() {
      product = updatedProduct;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, product);
        }
      },
      child: Scaffold(
        backgroundColor: AppBrand.loginBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
            child: Column(
              children: [
                const _ProductHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 34),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProductTopSection(product: product),
                        const SizedBox(height: 42),
                        _PriceTaxSection(product: product),
                        const SizedBox(height: 54),
                        _ProductButton(
                          icon: Icons.sell_outlined,
                          label: 'Update Price',
                          onPressed: isSaving ? null : openUpdatePrice,
                        ),
                        const SizedBox(height: 14),
                        _ProductButton(
                          icon: Icons.edit_outlined,
                          label: 'Edit Name & Tax',
                          onPressed: isSaving ? null : openEditProduct,
                        ),
                      ],
                    ),
                  ),
                ),
                const _ProductFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  const _ProductHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(width: 48),
        Expanded(
          child: Text(
            'Product Detail',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppBrand.textDarkGrey,
            ),
          ),
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppBrand.white,
          child: Icon(Icons.person_outline, color: AppBrand.textPrimary),
        ),
      ],
    );
  }
}

class _ProductTopSection extends StatelessWidget {
  final Product product;

  const _ProductTopSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
      decoration: BoxDecoration(
        color: AppBrand.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppBrand.loginBackground, width: 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w800,
              height: 1.05,
              color: AppBrand.primary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Barcode',
            style: TextStyle(
              fontSize: 16,
              color: AppBrand.textDarkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.barcode.isEmpty ? 'Not available' : product.barcode,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              color: AppBrand.textDarkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceTaxSection extends StatelessWidget {
  final Product product;

  const _PriceTaxSection({required this.product});

  String get priceWithoutCurrency {
    return product.formattedPrice.replaceFirst('CHF', '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProductMetricRow(
          icon: Icons.local_offer,
          title: 'Current Price',
          value: 'CHF $priceWithoutCurrency',
          valueFontSize: 32,
          valueWeight: FontWeight.w800,
        ),
        const SizedBox(height: 10),
        const _OrangeDivider(),
        const SizedBox(height: 20),
        _ProductMetricRow(
          icon: Icons.percent,
          title: 'Sales Tax',
          value: product.taxLabel,
          valueFontSize: 30,
          valueWeight: FontWeight.w400,
        ),
        const SizedBox(height: 8),
        const _OrangeDivider(),
      ],
    );
  }
}

class _ProductMetricRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final double valueFontSize;
  final FontWeight valueWeight;

  const _ProductMetricRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.valueFontSize,
    required this.valueWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 62,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              icon,
              size: 34,
              color: AppBrand.primary,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppBrand.textDarkGrey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: valueFontSize,
                  fontWeight: valueWeight,
                  color: AppBrand.textDarkGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrangeDivider extends StatelessWidget {
  const _OrangeDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
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
      height: 74,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(label),
      ),
    );
  }
}

class _ProductFooter extends StatelessWidget {
  const _ProductFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 10),
      child: Text.rich(
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
      ),
    );
  }
}
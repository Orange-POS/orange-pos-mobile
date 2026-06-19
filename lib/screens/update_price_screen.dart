import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/analytics_service.dart';
import '../services/api_client.dart';
import '../services/product_service.dart';
import '../theme/app_brand.dart';
import '../widgets/app_chrome.dart';

class UpdatePriceScreen extends StatefulWidget {
  final Product product;
  final String authToken;
  final String backendUrl;

  const UpdatePriceScreen({
    super.key,
    required this.product,
    required this.authToken,
    required this.backendUrl,
  });

  @override
  State<UpdatePriceScreen> createState() => _UpdatePriceScreenState();
}

class _UpdatePriceScreenState extends State<UpdatePriceScreen> {
  final ProductService productService = ProductService();
  final AnalyticsService analyticsService = AnalyticsService();

  late final TextEditingController priceController;

  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    priceController = TextEditingController();
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  String get priceWithoutCurrency {
    return widget.product.formattedPrice.replaceFirst('CHF', '').trim();
  }

  Future<void> savePrice() async {
    final newPrice = double.tryParse(priceController.text.trim());

    if (newPrice == null || newPrice < 0) {
      setState(() {
        errorMessage = 'Enter a valid price.';
      });
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      final updatedProduct = await productService.updateProductPrice(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        product: widget.product,
        price: newPrice.toString(),
      );

      unawaited(
        analyticsService.trackEvent(
          authToken: widget.authToken,
          backendUrl: widget.backendUrl,
          eventName: 'price_updated',
          screen: 'update_price',
          metadata: {
            'product_id': updatedProduct.id,
            'old_price': widget.product.price,
            'new_price': newPrice,
          },
        ),
      );

      if (!mounted) return;

      Navigator.pop(context, updatedProduct);
    } catch (error) {
      if (!mounted) return;

      final updateError = error is ApiClientException
          ? error.userMessage
          : error.toString().replaceFirst('Exception: ', '');

      unawaited(
        analyticsService.trackError(
          authToken: widget.authToken,
          backendUrl: widget.backendUrl,
          errorType: 'api_error',
          screen: 'update_price',
          message: updateError,
          details: error.toString(),
        ),
      );

      setState(() {
        isSaving = false;
        errorMessage = updateError;
      });

      debugPrint('Price update failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppBrand.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: AppChrome.scrollPadding(context),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 43,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      AppHeader.title(
                        title: 'Update Price',
                        onBackPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 13),
                      _ProductNameCard(productName: widget.product.name),
                      const SizedBox(height: 34),
                      _CurrentPriceSection(price: priceWithoutCurrency),
                      const SizedBox(height: 34),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'New Price',
                          style: TextStyle(
                            fontSize: 17,
                            color: AppBrand.textDarkGrey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priceController,
                        enabled: !isSaving,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          color: AppBrand.textDarkGrey,
                        ),
                        decoration: InputDecoration(
                          hintText: 'CHF  XXX.XX',
                          hintStyle: const TextStyle(
                            fontSize: 21,
                            color: Color(0xFF535353),
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppBrand.primaryDark,
                              width: 4,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppBrand.primaryDark,
                              width: 4,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppBrand.primaryDark,
                              width: 4,
                            ),
                          ),
                        ),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 82),
                      _UpdatePriceButton(
                        isSaving: isSaving,
                        onPressed: isSaving ? null : savePrice,
                      ),
                      const Spacer(),
                      const AppFooter(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
            color: AppBrand.primaryDark.withValues(alpha: 0.18),
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
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1.18,
              color: AppBrand.primaryDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentPriceSection extends StatelessWidget {
  final String price;

  const _CurrentPriceSection({required this.price});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 50,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(Icons.sell, size: 34, color: AppBrand.primary),
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Price',
                style: TextStyle(
                  fontSize: 17,
                  color: AppBrand.textDarkGrey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'CHF',
                style: TextStyle(
                  fontSize: 18,
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
                  fontSize: 32,
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

class _UpdatePriceButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback? onPressed;

  const _UpdatePriceButton({required this.isSaving, required this.onPressed});

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
            isSaving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppBrand.white,
                    ),
                  )
                : const Icon(Icons.edit_square, size: 24),
            const SizedBox(width: 12),
            Text(
              isSaving ? 'Saving...' : 'Update Price',
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

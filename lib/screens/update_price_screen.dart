import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/analytics_service.dart';
import '../services/api_client.dart';
import '../services/product_service.dart';
import '../theme/app_brand.dart';

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

      if (!mounted) {
        return;
      }

      Navigator.pop(context, updatedProduct);
    } catch (error) {
      if (!mounted) {
        return;
      }

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
      backgroundColor: AppBrand.loginBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                22,
                24,
                22,
                MediaQuery.viewInsetsOf(context).bottom + 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const _UpdatePriceHeader(),
                      const SizedBox(height: 32),
                      _CurrentPriceCard(
                        productName: widget.product.name,
                        currentPrice: priceWithoutCurrency,
                      ),
                      const SizedBox(height: 34),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'New Price',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppBrand.textDarkGrey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: priceController,
                        enabled: !isSaving,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppBrand.textDarkGrey,
                        ),
                        decoration: InputDecoration(
                          hintText: 'CHF',
                          hintStyle: const TextStyle(
                            fontSize: 24,
                            color: AppBrand.textSecondary,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 22,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppBrand.primary,
                              width: 3,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppBrand.primary,
                              width: 3,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppBrand.primary,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 14),
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
                      const SizedBox(height: 80),
                      SizedBox(
                        width: double.infinity,
                        height: 74,
                        child: FilledButton.icon(
                          onPressed: isSaving ? null : savePrice,
                          icon: isSaving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save, size: 24),
                          label: Text(isSaving ? 'Saving...' : 'Save Price'),
                        ),
                      ),
                      const Spacer(),
                      const _UpdatePriceFooter(),
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

class _UpdatePriceHeader extends StatelessWidget {
  const _UpdatePriceHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(width: 48),
        Expanded(
          child: Text(
            'Update Price',
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
          backgroundColor: AppBrand.primaryLight,
          child: Icon(Icons.person_outline, color: AppBrand.primary),
        ),
      ],
    );
  }
}

class _CurrentPriceCard extends StatelessWidget {
  final String productName;
  final String currentPrice;

  const _CurrentPriceCard({
    required this.productName,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 24),
      decoration: BoxDecoration(
        color: AppBrand.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppBrand.loginBackground, width: 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            productName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1,
              color: AppBrand.primary,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Current Price',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: AppBrand.textDarkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'CHF ',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AppBrand.textDarkGrey,
                  ),
                ),
                TextSpan(
                  text: currentPrice,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w400,
                    color: AppBrand.textDarkGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdatePriceFooter extends StatelessWidget {
  const _UpdatePriceFooter();

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

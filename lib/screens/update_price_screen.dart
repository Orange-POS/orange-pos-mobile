import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/analytics_service.dart';
import '../services/api_client.dart';
import '../services/product_service.dart';

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

    priceController = TextEditingController(
      text: widget.product.formattedPrice,
    );
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _UpdatePriceHeader(),
                      const SizedBox(height: 32),
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Current Price',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 26),
                      const Text(
                        'New Price',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: priceController,
                        enabled: !isSaving,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Enter new price',
                          prefixText: 'CHF ',
                        ),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
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
                              : const Icon(Icons.save_outlined, size: 20),
                          label: Text(isSaving ? 'Saving...' : 'Save Price'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: isSaving
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.black12,
          child: Icon(Icons.person_outline, color: Colors.black),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../models/product.dart';
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
  State<UpdatePriceScreen> createState() =>
      _UpdatePriceScreenState();
}

class _UpdatePriceScreenState extends State<UpdatePriceScreen> {
  final ProductService productService = ProductService();
  final TextEditingController priceController =
      TextEditingController();

  bool isSaving = false;
  String? errorMessage;

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  Future<void> savePrice() async {
    final newPrice =
        double.tryParse(priceController.text.trim());

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
      final updatedProduct =
          await productService.updateProductPrice(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        product: widget.product,
        price: newPrice.toString(),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, updatedProduct);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
        errorMessage =
            'Could not update the price. Please try again.';
      });
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
              padding: const EdgeInsets.fromLTRB(34, 16, 34, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 44,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _UpdatePriceHeader(),
                      const SizedBox(height: 30),
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Current Price',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'New Price',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: priceController,
                        autofocus: false,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: 'New Price',
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(6),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(6),
                            borderSide: const BorderSide(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Center(
                        child: SizedBox(
                          width: 245,
                          height: 44,
                          child: FilledButton.icon(
                            onPressed:
                                isSaving ? null : savePrice,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(5),
                              ),
                            ),
                            icon: isSaving
                                ? const SizedBox.square(
                                    dimension: 17,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.save_outlined,
                                    size: 18,
                                  ),
                            label: Text(
                              isSaving
                                  ? 'Saving...'
                                  : 'Save Price Change',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: SizedBox(
                          width: 245,
                          height: 44,
                          child: OutlinedButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(
                                color: Colors.black54,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
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
    return Row(
      children: [
        const SizedBox(width: 42),
        const Expanded(
          child: Text(
            'Update Price',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
        CircleAvatar(
          radius: 21,
          backgroundColor: Colors.black12,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.person_outline,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
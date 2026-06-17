

import 'package:flutter/material.dart';

import '../models/product.dart';
import 'update_price_screen.dart';
import 'edit_product_screen.dart';

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
  final TextEditingController nameController = TextEditingController();

  late Product product;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    product = widget.product;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
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
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(
          product: product,
          authToken: widget.authToken,
          backendUrl: widget.backendUrl,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (result is Product) {
      setState(() {
        product = result;
      });
    }
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const _ProductHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(34, 28, 34, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _ProductValue(
                                  label: 'Barcode',
                                  value: product.barcode.isEmpty
                                      ? 'Not available'
                                      : product.barcode,
                                ),
                                _ProductValue(
                                  label: 'Current Price',
                                  value: product.formattedPrice,
                                ),
                                _ProductValue(
                                  label: 'Sales Tax',
                                  value: product.taxLabel,
                                ),
                              ],
                            ),
                          ),
                        
                        ],
                      ),
                      const SizedBox(height: 36),

                      const SizedBox(height: 28),
                      _ProductButton(
                        icon: Icons.edit_outlined,
                        label: 'Update Price',
                        onPressed: isSaving ? null : openUpdatePrice,
                      ),
                      const SizedBox(height: 12),
                      _ProductButton(
                        icon: Icons.edit,
                        label: 'Edit Name & Tax',
                        onPressed: isSaving ? null : openEditProduct,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          const SizedBox(width: 42),
          const Expanded(
            child: Text(
              'Product Details',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
          CircleAvatar(
            radius: 21,
            backgroundColor: Colors.black12,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.person_outline, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductValue extends StatelessWidget {
  final String label;
  final String value;

  const _ProductValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 17)),
        ],
      ),
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
    return Center(
      child: SizedBox(
        width: 245,
        height: 44,
        child: FilledButton.icon(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.black38,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          icon: Icon(icon, size: 19),
          label: Text(label),
        ),
      ),
    );
  }
}

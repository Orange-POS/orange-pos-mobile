import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/product.dart';
import 'update_price_screen.dart';
import 'update_stock_screen.dart';
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
  
  final TextEditingController nameController =
      TextEditingController();

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

  Future<void> openUpdateStock() async {
    final updatedProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateStockScreen(
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

  

  Uint8List? decodeProductImage() {
    if (!product.hasImage) {
      return null;
    }

    try {
      final value = product.imageBase64.contains(',')
          ? product.imageBase64.split(',').last
          : product.imageBase64;

      return base64Decode(value);
    } catch (_) {
      return null;
    }
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

  if (result == 'archived') {
    Navigator.pop(context);
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
    final imageBytes = decodeProductImage();

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
                  padding:
                      const EdgeInsets.fromLTRB(34, 28, 34, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                                  label: 'QTY',
                                  value: product.formattedStock,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Container(
                            width: 105,
                            height: 105,
                            color: const Color(0xFFE0E0E0),
                            child: imageBytes == null
                                ? const Icon(
                                    Icons.image_outlined,
                                    size: 36,
                                  )
                                : Image.memory(
                                    imageBytes,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Audit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Audit history is not available yet.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      
                      const SizedBox(height: 36),
                      _ProductButton(
                        icon: Icons.edit_outlined,
                        label: 'Update Price',
                        onPressed:
                            isSaving ? null : openUpdatePrice,
                      ),
                      const SizedBox(height: 12),
                      _ProductButton(
                        icon: Icons.add,
                        label: 'Add Stock',
                        onPressed:
                            isSaving ? null : openUpdateStock,
                      ),
                      const SizedBox(height: 12),
                      _ProductButton(
                        icon: Icons.auto_fix_high,
                        label: 'Edit Product',
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
              icon: const Icon(
                Icons.person_outline,
                color: Colors.black,
              ),
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

  const _ProductValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 17),
          ),
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
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
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _ProductValue(
                        label: 'Barcode',
                        value: product.barcode.isEmpty
                            ? 'Not available'
                            : product.barcode,
                      ),
                      _ProductValue(
                        label: 'Current Price',
                        value: product.formattedPrice,
                        isPrimary: true,
                      ),
                      _ProductValue(
                        label: 'Sales Tax',
                        value: product.taxLabel,
                      ),
                      const SizedBox(height: 36),
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
    return const Padding(
      padding: EdgeInsets.fromLTRB(28, 16, 28, 0),
      child: Row(
        children: [
          SizedBox(width: 48),
          Expanded(
            child: Text(
              'Product Details',
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
      ),
    );
  }
}

class _ProductValue extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrimary;

  const _ProductValue({
    required this.label,
    required this.value,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isPrimary ? 28 : 18,
              fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w500,
              color: Colors.black,
            ),
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
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 21),
        label: Text(label),
      ),
    );
  }
}

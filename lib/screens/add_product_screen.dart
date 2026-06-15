import 'package:flutter/material.dart';

import '../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  final String barcode;
  final String authToken;
  final String backendUrl;

  const AddProductScreen({
    super.key,
    required this.barcode,
    required this.authToken,
    required this.backendUrl,
  });

  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController =
      TextEditingController();
  final TextEditingController priceController =
      TextEditingController();

  final ProductService productService = ProductService();

  String selectedTax = 'Default';
  String selectedPosCategory = 'Not assigned';
  String selectedProductCategory = 'Not assigned';

  bool isSaving = false;
  String? errorMessage;

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> saveProduct() async {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim());

    if (name.isEmpty) {
      setState(() {
        errorMessage = 'Product name is required.';
      });
      return;
    }

    if (price == null || price < 0) {
      setState(() {
        errorMessage = 'Enter a valid product price.';
      });
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      final createdProduct =
          await productService.createProduct(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        barcode: widget.barcode,
        name: name,
        price: price,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, createdProduct);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
        errorMessage =
            'Could not create the product. Please try again.';
      });

      debugPrint('Product creation failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(34, 16, 34, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 42),
                  Expanded(
                    child: Text(
                      widget.barcode,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 21,
                    backgroundColor: Colors.black12,
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              const _FieldLabel(
                label: 'Product Name',
                secondary: 'Required',
              ),
              TextField(
                controller: nameController,
                enabled: !isSaving,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const _FieldLabel(
                label: 'Product Price',
                secondary: 'Required',
              ),
              TextField(
                controller: priceController,
                enabled: !isSaving,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'Price',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const _FieldLabel(
                label: 'Tax',
                secondary: 'Default',
              ),
              DropdownButtonFormField<String>(
                initialValue: selectedTax,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Default',
                    child: Text('Default'),
                  ),
                ],
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            selectedTax = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 32),
              const _FieldLabel(label: 'POS Category'),
              DropdownButtonFormField<String>(
                initialValue: selectedPosCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Not assigned',
                    child: Text('Not assigned'),
                  ),
                ],
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            selectedPosCategory = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 20),
              const _FieldLabel(label: 'Product Category'),
              DropdownButtonFormField<String>(
                initialValue: selectedProductCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Not assigned',
                    child: Text('Not assigned'),
                  ),
                ],
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            selectedProductCategory = value;
                          });
                        }
                      },
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 50),
              _ActionButton(
                label: isSaving ? 'Saving...' : 'Add Product',
                icon: isSaving ? null : Icons.add,
                filled: true,
                onPressed: isSaving ? null : saveProduct,
              ),
              const SizedBox(height: 12),
              _ActionButton(
                label: 'Cancel',
                filled: false,
                onPressed: isSaving
                    ? null
                    : () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final String? secondary;

  const _FieldLabel({
    required this.label,
    this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          if (secondary != null)
            Text(
              secondary!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool filled;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.filled,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    return Center(
      child: SizedBox(
        width: 245,
        height: 44,
        child: filled
            ? FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.black38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: child,
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: child,
              ),
      ),
    );
  }
}
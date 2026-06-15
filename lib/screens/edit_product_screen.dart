import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  final String authToken;
  final String backendUrl;

  const EditProductScreen({
    super.key,
    required this.product,
    required this.authToken,
    required this.backendUrl,
  });

  @override
  State<EditProductScreen> createState() =>
      _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final ProductService productService = ProductService();

  late final TextEditingController nameController;
  late final TextEditingController priceController;

  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.product.name,
    );

    priceController = TextEditingController(
      text: widget.product.formattedPrice,
    );
  }

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
      final updatedProduct = await productService.createProduct(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        barcode: widget.product.barcode,
        name: name,
        price: price,
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
        errorMessage = 'Could not update the product.';
      });

      debugPrint('Product update failed: $error');
    }
  }

  Future<void> archiveProduct() async {
  final shouldArchive = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Archive Product'),
        content: Text(
          'Archive "${widget.product.name}"? '
          'This product will no longer appear in the POS.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Archive'),
          ),
        ],
      );
    },
  );

  if (shouldArchive != true || !mounted) {
    return;
  }

  setState(() {
    isSaving = true;
    errorMessage = null;
  });

  try {
    await productService.archiveProduct(
      authToken: widget.authToken,
      backendUrl: widget.backendUrl,
      product: widget.product,
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context, 'archived');
  } catch (error) {
    if (!mounted) {
      return;
    }

    setState(() {
      isSaving = false;
      errorMessage = 'Could not archive the product.';
    });

    debugPrint('Product archive failed: $error');
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
            const _EditProductHeader(),
            const SizedBox(height: 36),
            const _FieldLabel(
              label: 'Product Name',
              secondary: 'Required',
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _FieldLabel(
              label: 'Product Price',
              secondary: 'Required',
            ),
            TextField(
              controller: priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: 'Price',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _FieldLabel(label: 'Barcode'),
            TextFormField(
              initialValue: widget.product.barcode,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _FieldLabel(
              label: 'Tax',
              secondary: 'Current',
            ),
            TextFormField(
              initialValue: widget.product.taxLabel,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _FieldLabel(label: 'POS Category'),
            TextFormField(
              initialValue: widget.product.posCategoryLabel,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _FieldLabel(label: 'Product Category'),
            TextFormField(
              initialValue: widget.product.productCategoryLabel,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 42),
            _ActionButton(
              label: isSaving
                  ? 'Saving...'
                  : 'Save Product',
              icon: Icons.save_outlined,
              filled: true,
              onPressed: isSaving ? null : saveProduct,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'Archive Product',
              icon: Icons.archive_outlined,
              filled: false,
              onPressed: isSaving ? null : archiveProduct,
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

class _EditProductHeader extends StatelessWidget {
  const _EditProductHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 42),
        const Expanded(
          child: Text(
            'Edit Product',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
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
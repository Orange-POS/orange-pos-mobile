import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product_references.dart';
import '../models/product_tax.dart';
import '../services/analytics_service.dart';
import '../services/api_client.dart';
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
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final AnalyticsService analyticsService = AnalyticsService();
  final ProductService productService = ProductService();

  ProductReferences references = const ProductReferences();

  int? selectedTaxId;
  bool isLoadingReferences = true;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadReferences();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> loadReferences() async {
    try {
      final loadedReferences = await productService.loadProductReferences(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
      );

      if (!mounted) {
        return;
      }

      final uniqueTaxes = _uniqueTaxesFrom(loadedReferences.taxes);

      final defaultTaxId = loadedReferences.defaultTaxIds.isNotEmpty
          ? loadedReferences.defaultTaxIds.first
          : null;

      final hasDefaultTax =
          defaultTaxId != null &&
          uniqueTaxes.any((tax) => tax.id == defaultTaxId);

      setState(() {
        references = ProductReferences(
          defaultTaxIds: loadedReferences.defaultTaxIds,
          taxes: uniqueTaxes,
        );
        selectedTaxId = hasDefaultTax ? defaultTaxId : null;
        isLoadingReferences = false;
      });
    } catch (error) {
      debugPrint('Product references failed to load: $error');

      if (!mounted) {
        return;
      }

      setState(() {
        references = const ProductReferences();
        selectedTaxId = null;
        isLoadingReferences = false;
      });
    }
  }

  Future<void> saveProduct() async {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim());
    final safeTaxId = _safeSelectedTaxId();

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
      final createdProduct = await productService.createProduct(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        barcode: widget.barcode,
        name: name,
        price: price,
        taxIds: safeTaxId == null ? null : [safeTaxId],
      );

      unawaited(
        analyticsService.trackEvent(
          authToken: widget.authToken,
          backendUrl: widget.backendUrl,
          eventName: 'product_added',
          screen: 'add_product',
          metadata: {
            'barcode': widget.barcode,
            'product_id': createdProduct.id,
            'tax_id': safeTaxId,
          },
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, createdProduct);
    } catch (error) {
      if (!mounted) {
        return;
      }

      final createError = error is ApiClientException
          ? error.userMessage
          : error.toString().replaceFirst('Exception: ', '');

      unawaited(
        analyticsService.trackError(
          authToken: widget.authToken,
          backendUrl: widget.backendUrl,
          errorType: 'api_error',
          screen: 'add_product',
          message: createError,
          details: error.toString(),
        ),
      );

      setState(() {
        isSaving = false;
        errorMessage = createError;
      });

      debugPrint('Product creation failed: $error');
    }
  }

  List<ProductTax> _uniqueTaxesFrom(List<ProductTax> taxes) {
    final seenIds = <int>{};

    return taxes.where((tax) {
      return seenIds.add(tax.id);
    }).toList();
  }

  List<ProductTax> _uniqueTaxes() {
    return _uniqueTaxesFrom(references.taxes);
  }

  int? _safeSelectedTaxId() {
    final selectedId = selectedTaxId;

    if (selectedId == null) {
      return null;
    }

    final taxExists = _uniqueTaxes().any((tax) => tax.id == selectedId);

    return taxExists ? selectedId : null;
  }

  @override
  Widget build(BuildContext context) {
    final referenceFieldsDisabled = isSaving || isLoadingReferences;

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
                    child: Icon(Icons.person_outline, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              const _FieldLabel(label: 'Product Name', secondary: 'Required'),
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
              const _FieldLabel(label: 'Product Price', secondary: 'Required'),
              TextField(
                controller: priceController,
                enabled: !isSaving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'Price',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              _FieldLabel(
                label: 'Sales Tax',
                secondary: isLoadingReferences ? 'Loading...' : 'Default',
              ),
              DropdownButtonFormField<int?>(
                initialValue: _safeSelectedTaxId(),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Default'),
                  ),
                  ..._uniqueTaxes().map(
                    (tax) => DropdownMenuItem<int?>(
                      value: tax.id,
                      child: Text(tax.name),
                    ),
                  ),
                ],
                onChanged: referenceFieldsDisabled
                    ? null
                    : (value) {
                        setState(() {
                          selectedTaxId = value;
                        });
                      },
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 50),
              _ActionButton(
                label: isSaving ? 'Saving...' : 'Add New Product',
                icon: isSaving ? null : Icons.add_circle_outline,
                filled: true,
                onPressed: isSaving ? null : saveProduct,
              ),
              const SizedBox(height: 12),
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

  const _FieldLabel({required this.label, this.secondary});

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
              style: const TextStyle(fontSize: 12, color: Colors.black54),
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
        if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
        Text(label),
      ],
    );

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: filled
          ? FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.black38,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: child,
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: child,
            ),
    );
  }
}

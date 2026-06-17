import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/product_references.dart';
import '../models/product_tax.dart';
import '../services/analytics_service.dart';
import '../services/api_client.dart';
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
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final ProductService productService = ProductService();
  final AnalyticsService analyticsService = AnalyticsService();

  late final TextEditingController nameController;

  ProductReferences references = const ProductReferences();

  int? selectedTaxId;
  bool isLoadingReferences = true;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.product.name);
    selectedTaxId = widget.product.taxes.isNotEmpty
        ? widget.product.taxes.first.id
        : null;

    loadReferences();
  }

  @override
  void dispose() {
    nameController.dispose();
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

      final hasSelectedTax =
          selectedTaxId != null &&
          uniqueTaxes.any((tax) => tax.id == selectedTaxId);

      setState(() {
        references = ProductReferences(
          defaultTaxIds: loadedReferences.defaultTaxIds,
          taxes: uniqueTaxes,
        );
        selectedTaxId = hasSelectedTax ? selectedTaxId : null;
        isLoadingReferences = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      final referenceError = error is ApiClientException
          ? error.userMessage
          : error.toString().replaceFirst('Exception: ', '');

      setState(() {
        references = const ProductReferences();
        selectedTaxId = null;
        isLoadingReferences = false;
        errorMessage = referenceError;
      });

      debugPrint('Product references failed to load: $error');
    }
  }

  Future<void> saveProduct() async {
    final name = nameController.text.trim();
    final safeTaxId = _safeSelectedTaxId();

    if (name.isEmpty) {
      setState(() {
        errorMessage = 'Product name is required.';
      });
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      final updatedProduct = await productService.updateProduct(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        product: widget.product,
        name: name,
        taxIds: safeTaxId == null ? null : [safeTaxId],
      );

      unawaited(
        analyticsService.trackEvent(
          authToken: widget.authToken,
          backendUrl: widget.backendUrl,
          eventName: 'product_updated',
          screen: 'edit_product',
          metadata: {'product_id': updatedProduct.id, 'tax_id': safeTaxId},
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, updatedProduct);
    } catch (error) {
      final updateError = error is ApiClientException
          ? error.userMessage
          : error.toString().replaceFirst('Exception: ', '');

      unawaited(
        analyticsService.trackError(
          authToken: widget.authToken,
          backendUrl: widget.backendUrl,
          errorType: 'api_error',
          screen: 'edit_product',
          message: updateError,
          details: error.toString(),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
        errorMessage = updateError;
      });

      debugPrint('Product update failed: $error');
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
              const _EditProductHeader(),
              const SizedBox(height: 36),
              const _FieldLabel(label: 'Product Name', secondary: 'Required'),
              TextField(
                controller: nameController,
                enabled: !isSaving,
                decoration: InputDecoration(
                  hintText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _FieldLabel(
                label: 'Sales Tax',
                secondary: isLoadingReferences ? 'Loading...' : 'Current',
              ),
              DropdownButtonFormField<int?>(
                initialValue: _safeSelectedTaxId(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
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
              const SizedBox(height: 42),
              _ActionButton(
                label: isSaving ? 'Saving...' : 'Save Product',
                icon: isSaving ? null : Icons.save_outlined,
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
          child: Icon(Icons.person_outline, color: Colors.black),
        ),
      ],
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

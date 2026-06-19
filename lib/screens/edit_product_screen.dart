import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/product_references.dart';
import '../models/product_tax.dart';
import '../services/analytics_service.dart';
import '../services/api_client.dart';
import '../services/product_service.dart';
import '../theme/app_brand.dart';
import '../widgets/app_chrome.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  final String authToken;
  final String backendUrl;
  final ProductReferences? initialReferences;

  const EditProductScreen({
    super.key,
    required this.product,
    required this.authToken,
    required this.backendUrl,
    this.initialReferences,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final ProductService productService = ProductService();
  final AnalyticsService analyticsService = AnalyticsService();

  late final TextEditingController nameController;

  ProductReferences? references;
  int? selectedTaxId;
  bool isLoadingReferences = false;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.product.name);

    references = widget.initialReferences;
    selectedTaxId = widget.product.taxes.isNotEmpty
        ? widget.product.taxes.first.id
        : null;

    if (references == null) {
      unawaited(loadReferences());
    } else {
      selectedTaxId = _safeSelectedTaxId();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> loadReferences() async {
    setState(() {
      isLoadingReferences = true;
      errorMessage = null;
    });

    try {
      final loadedReferences = await productService.loadProductReferences(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
      );

      if (!mounted) return;

      setState(() {
        references = loadedReferences;
        selectedTaxId = _safeSelectedTaxId();
      });
    } on ApiClientException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.userMessage;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Could not load product references.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoadingReferences = false;
        });
      }
    }
  }

  Future<void> saveProduct() async {
    final name = nameController.text.trim();

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
      final safeTaxId = _safeSelectedTaxId();

      final updatedProduct = await productService.updateProduct(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        product: widget.product,
        name: name,
        taxIds: safeTaxId == null ? null : [safeTaxId],
      );

      await analyticsService.trackEvent(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        eventName: 'product_updated',
        screen: 'edit_product',
        metadata: {
          'product_id': widget.product.id,
          'barcode': widget.product.barcode,
        },
      );

      if (!mounted) return;

      Navigator.of(context).pop(updatedProduct);
    } on ApiClientException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.userMessage;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Could not update product.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  List<ProductTax> _uniqueTaxes() {
    return _uniqueTaxesFrom(references?.taxes ?? widget.product.taxes);
  }

  List<ProductTax> _uniqueTaxesFrom(List<ProductTax> taxes) {
    final seenIds = <int>{};
    final uniqueTaxes = <ProductTax>[];

    for (final tax in taxes) {
      if (seenIds.add(tax.id)) {
        uniqueTaxes.add(tax);
      }
    }

    return uniqueTaxes;
  }

  int? _safeSelectedTaxId() {
    final currentTaxId = selectedTaxId;
    if (currentTaxId == null) return null;

    final exists = _uniqueTaxes().any((tax) => tax.id == currentTaxId);
    return exists ? currentTaxId : null;
  }

  @override
  Widget build(BuildContext context) {
    final taxes = _uniqueTaxes();
    final safeTaxId = _safeSelectedTaxId();
    final referenceFieldsDisabled = isSaving || isLoadingReferences;

    return Scaffold(
      backgroundColor: AppBrand.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: AppChrome.scrollPadding(context),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 43,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      AppHeader.title(
                        title: widget.product.barcode.isEmpty
                            ? 'Edit Product'
                            : widget.product.barcode,
                        onBackPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 54),
                      const _FieldLabel(
                        label: 'Product Name',
                        secondary: 'Required',
                      ),
                      const SizedBox(height: 10),
                      _OrangeTextField(
                        controller: nameController,
                        enabled: !isSaving,
                        hintText: 'Name',
                      ),
                      const SizedBox(height: 20),
                      _FieldLabel(
                        label: 'Tax',
                        secondary: isLoadingReferences
                            ? 'Loading...'
                            : 'Default',
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int?>(
                        initialValue: safeTaxId,
                        isExpanded: true,
                        decoration: _orangeInputDecoration(),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF535353),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('No tax selected'),
                          ),
                          ...taxes.map(
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
                        const SizedBox(height: 12),
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
                      const SizedBox(height: 240),
                      _EditProductButton(
                        isSaving: isSaving,
                        onPressed: isSaving ? null : saveProduct,
                      ),
                      const Spacer(),
                      const AppFooter(),
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

class _FieldLabel extends StatelessWidget {
  final String label;
  final String secondary;

  const _FieldLabel({required this.label, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppBrand.textDarkGrey,
          ),
        ),
        const Spacer(),
        Text(
          secondary,
          style: const TextStyle(
            fontSize: 14,
            color: AppBrand.textDarkGrey,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _OrangeTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String hintText;

  const _OrangeTextField({
    required this.controller,
    required this.enabled,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textInputAction: TextInputAction.done,
      style: const TextStyle(fontSize: 16, color: AppBrand.textDarkGrey),
      decoration: _orangeInputDecoration(hintText: hintText),
    );
  }
}

InputDecoration _orangeInputDecoration({String? hintText}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF535353)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppBrand.primaryDark, width: 4),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppBrand.primaryDark, width: 4),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppBrand.primaryDark, width: 4),
    ),
  );
}

class _EditProductButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback? onPressed;

  const _EditProductButton({required this.isSaving, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 76,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppBrand.primaryDark,
          foregroundColor: AppBrand.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          children: [
            const Spacer(),
            isSaving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppBrand.white,
                    ),
                  )
                : const Icon(Icons.edit, size: 24),
            const SizedBox(width: 12),
            Text(
              isSaving ? 'Saving...' : 'Edite Product',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

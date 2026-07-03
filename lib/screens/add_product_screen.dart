import 'dart:async';

import 'package:flutter/material.dart';

import '../features/products/data/product_repository_factory.dart';
import '../features/products/domain/product_repository.dart';
import '../models/product_references.dart';
import '../models/product_tax.dart';
import '../services/analytics_service.dart';
import '../services/api_client.dart';
import '../theme/app_brand.dart';
import '../widgets/app_chrome.dart';

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
  final ProductRepositoryFactory productRepositoryFactory =
      const ProductRepositoryFactory();

  ProductReferences references = const ProductReferences();

  int? selectedTaxId;
  bool isLoadingReferences = true;
  bool isSaving = false;
  String? errorMessage;

  ProductRepository get productRepository {
    return productRepositoryFactory.create(
      authToken: widget.authToken,
      backendUrl: widget.backendUrl,
    );
  }

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
      final loadedReferences = await productRepository.loadProductReferences();

      if (!mounted) return;

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

      if (!mounted) return;

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
      final createdProduct = await productRepository.createProduct(
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

      if (!mounted) return;

      Navigator.pop(context, createdProduct);
    } catch (error) {
      if (!mounted) return;

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

    if (selectedId == null) return null;

    final taxExists = _uniqueTaxes().any((tax) => tax.id == selectedId);

    return taxExists ? selectedId : null;
  }

  @override
  Widget build(BuildContext context) {
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
                        title: 'Product Not Found',
                        onBackPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 36),
                      _ProductNotFoundBanner(barcode: widget.barcode),
                      const SizedBox(height: 38),
                      const _FieldLabel(label: 'Product Name', secondary: null),
                      const SizedBox(height: 10),
                      _OrangeTextField(
                        controller: nameController,
                        enabled: !isSaving,
                        hintText: 'Name',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      const _FieldLabel(
                        label: 'Product Price',
                        secondary: 'Required',
                      ),
                      const SizedBox(height: 10),
                      _OrangeTextField(
                        controller: priceController,
                        enabled: !isSaving,
                        hintText: 'Price',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
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
                        initialValue: _safeSelectedTaxId(),
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
                      const SizedBox(height: 58),
                      _AddProductButton(
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

class _ProductNotFoundBanner extends StatelessWidget {
  final String barcode;

  const _ProductNotFoundBanner({required this.barcode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 67,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC6C6).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFFF6464).withValues(alpha: 0.2),
              width: 4,
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFBD0A0A), size: 30),
              SizedBox(width: 18),
              Expanded(
                child: Text(
                  'Product Not Found',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFBD0A0A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Scanned Barcode',
            style: TextStyle(
              fontSize: 16,
              color: AppBrand.textDarkGrey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(
              Icons.qr_code_scanner,
              color: AppBrand.primary,
              size: 46,
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Text(
                barcode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  color: AppBrand.textDarkGrey,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final String? secondary;

  const _FieldLabel({required this.label, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppBrand.textDarkGrey,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        if (secondary != null)
          Text(
            secondary!,
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
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const _OrangeTextField({
    required this.controller,
    required this.enabled,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
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
      borderSide: const BorderSide(color: AppBrand.primaryDark, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppBrand.primaryDark, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppBrand.primaryDark, width: 2),
    ),
  );
}

class _AddProductButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback? onPressed;

  const _AddProductButton({required this.isSaving, required this.onPressed});

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
                : const Icon(Icons.add_circle, size: 24),
            const SizedBox(width: 12),
            Text(
              isSaving ? 'Saving...' : 'Add New Product',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

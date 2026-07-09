import 'dart:async';

import 'package:flutter/material.dart';
import '../core/di/app_dependencies.dart';

import '../models/product.dart';
import '../models/product_references.dart';
import '../models/product_tax.dart';
import '../services/analytics_service.dart';

import '../theme/app_brand.dart';
import '../widgets/app_chrome.dart';

import '../features/products/data/product_repository_factory.dart';

import '../core/errors/app_error.dart';

import '../core/analytics/analytics_events.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/app_text_field.dart';
import '../core/widgets/app_error_state.dart';
import '../features/products/application/product_use_cases.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  final String authToken;
  final String backendUrl;
  final ProductReferences? initialReferences;
  final AppDependencies dependencies;

  const EditProductScreen({
    super.key,
    required this.product,
    required this.authToken,
    required this.backendUrl,
    required this.dependencies,
    this.initialReferences,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  ProductRepositoryFactory get productRepositoryFactory {
    return widget.dependencies.productRepositoryFactory;
  }

  AnalyticsService get analyticsService => widget.dependencies.analyticsService;

  late final TextEditingController nameController;

  ProductReferences? references;
  int? selectedTaxId;
  bool isLoadingReferences = false;
  bool isSaving = false;
  String? errorMessage;

  ProductUseCases get productUseCases {
    return productRepositoryFactory.createUseCases(
      authToken: widget.authToken,
      backendUrl: widget.backendUrl,
    );
  }

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
      final loadedReferences = await productUseCases.loadProductReferences();

      if (!mounted) return;

      setState(() {
        references = loadedReferences;
        selectedTaxId = _safeSelectedTaxId();
      });
    } catch (error) {
      if (!mounted) return;

      final appError = AppError.fromException(error);

      setState(() {
        isLoadingReferences = false;
        errorMessage = appError.userMessage;
      });

      debugPrint(
        'Product references failed to load: ${appError.diagnosticDetails}',
      );
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

      final updatedProduct = await productUseCases.updateProduct(
        product: widget.product,
        name: name,
        taxIds: safeTaxId == null ? null : [safeTaxId],
      );

      await analyticsService.trackEvent(
        authToken: widget.authToken,
        backendUrl: widget.backendUrl,
        eventName: AnalyticsEvents.productUpdated,
        screen: 'edit_product',
        metadata: {
          'product_id': widget.product.id,
          'barcode': widget.product.barcode,
        },
      );

      if (!mounted) return;

      Navigator.of(context).pop(updatedProduct);
    } catch (error) {
      if (!mounted) return;

      final appError = AppError.fromException(error);

      unawaited(
        analyticsService.trackError(
          authToken: widget.authToken,
          backendUrl: widget.backendUrl,
          errorType: AnalyticsErrorTypes.fromAppErrorType(appError.type),
          screen: 'edit_product',
          message: appError.userMessage,
          details: appError.diagnosticDetails,
        ),
      );

      setState(() {
        isSaving = false;
        errorMessage = appError.userMessage;
      });

      debugPrint('Product update failed: ${appError.diagnosticDetails}');
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
                      AppTextField(
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
                        decoration: AppTextField.decoration(borderWidth: 4),
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
                        AppErrorState(message: errorMessage!),
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

class _EditProductButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback? onPressed;

  const _EditProductButton({required this.isSaving, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: isSaving ? 'Saving...' : 'Edit Name & Tax',
      icon: Icons.edit_square,
      isLoading: isSaving,
      onPressed: onPressed,
    );
  }
}

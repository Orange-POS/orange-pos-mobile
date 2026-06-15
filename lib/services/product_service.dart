import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient apiClient = ApiClient();

  Future<Product?> findProductByBarcode({
    required String authToken,
    required String backendUrl,
    required String barcode,
  }) async {
    final responseData = await apiClient.postJson(
      baseUrl: backendUrl,
      endpoint: ApiConfig.productFindEndpoint,
      authToken: authToken,
      body: {
        'jsonrpc': '2.0',
        'params': {
          'barcode': barcode,
        },
      },
    );

    final result = _readResult(
      responseData,
      fallbackError: 'Product lookup failed',
    );

    final productData = result['product'];

    if (productData == null) {
      return null;
    }

    if (productData is! Map) {
      throw Exception('Invalid product data');
    }

    return Product.fromJson(
      Map<String, dynamic>.from(productData),
    );
  }

  Future<Product> updateProductName({
    required String authToken,
    required String backendUrl,
    required Product product,
    required String name,
  }) async {
    final responseData = await apiClient.postJson(
      baseUrl: backendUrl,
      endpoint: ApiConfig.productNameUpdateEndpoint,
      authToken: authToken,
      body: {
        'jsonrpc': '2.0',
        'params': {
          'product_id': product.id,
          'name': name,
        },
      },
    );

    final result = _readResult(
      responseData,
      fallbackError: 'Product name update failed',
    );

    return _readProduct(result);
  }

  Future<Product> updateProductPrice({
    required String authToken,
    required String backendUrl,
    required Product product,
    required String price,
  }) async {
    final responseData = await apiClient.postJson(
      baseUrl: backendUrl,
      endpoint: ApiConfig.productPriceUpdateEndpoint,
      authToken: authToken,
      body: {
        'jsonrpc': '2.0',
        'params': {
          'product_id': product.id,
          'price': price,
        },
      },
    );

    final result = _readResult(
      responseData,
      fallbackError: 'Product price update failed',
    );

    return _readProduct(result);
  }

  Future<Product> createProduct({
    required String authToken,
    required String backendUrl,
    required String barcode,
    required String name,
    required double price,
    List<int>? taxIds,
    List<int>? posCategoryIds,
    int? productCategoryId,
  }) async {
    final params = <String, dynamic>{
      'barcode': barcode,
      'name': name,
      'price': price,
    };

    if (taxIds != null && taxIds.isNotEmpty) {
      params['tax_ids'] = taxIds;
    }

    if (posCategoryIds != null && posCategoryIds.isNotEmpty) {
      params['pos_category_ids'] = posCategoryIds;
    }

    if (productCategoryId != null) {
      params['product_category_id'] = productCategoryId;
    }

    final responseData = await apiClient.postJson(
      baseUrl: backendUrl,
      endpoint: ApiConfig.productSaveEndpoint,
      authToken: authToken,
      body: {
        'jsonrpc': '2.0',
        'params': params,
      },
    );

    final result = _readResult(
      responseData,
      fallbackError: 'Product creation failed',
    );

    return _readProduct(result);
  }

  Future<void> archiveProduct({
    required String authToken,
    required String backendUrl,
    required Product product,
  }) async {
    if (product.barcode.isEmpty) {
      throw Exception('Product barcode is unavailable');
    }

    final responseData = await apiClient.postJson(
      baseUrl: backendUrl,
      endpoint: ApiConfig.productArchiveEndpoint,
      authToken: authToken,
      body: {
        'jsonrpc': '2.0',
        'params': {
          'barcode': product.barcode,
        },
      },
    );

    debugPrint('Archive response: $responseData');

    final result = _readResult(
      responseData,
      fallbackError: 'Product archive failed',
    );

    final archivedCount = result['archived'];

    if (archivedCount is! num || archivedCount < 1) {
      throw Exception('Product was not found or already archived');
    }
  }

  Map<String, dynamic> _readResult(
    Map<String, dynamic> responseData, {
    required String fallbackError,
  }) {
    final rpcError = responseData['error'];

    if (rpcError != null) {
      throw Exception('Odoo error: $rpcError');
    }

    final rawResult = responseData['result'];

    if (rawResult is! Map) {
      throw Exception(
        '$fallbackError: invalid server response',
      );
    }

    final result = Map<String, dynamic>.from(rawResult);

    if (result['ok'] != true) {
      throw Exception(
        result['error']?.toString() ?? fallbackError,
      );
    }

    return result;
  }

  Product _readProduct(Map<String, dynamic> result) {
    final productData = result['product'];

    if (productData is! Map) {
      throw Exception('Product data was not returned');
    }

    return Product.fromJson(
      Map<String, dynamic>.from(productData),
    );
  }
}
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  Future<Map<String, dynamic>> postJsonToUrl({
    required String url,
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    return postJsonToUri(
      uri: Uri.parse(url),
      body: body,
      authToken: authToken,
    );
  }

  Future<Map<String, dynamic>> postJson({
    required String baseUrl,
    required String endpoint,
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    return postJsonToUri(
      uri: Uri.parse('$baseUrl$endpoint'),
      body: body,
      authToken: authToken,
    );
  }

  Future<Map<String, dynamic>> postJsonToUri({
    required Uri uri,
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
  throw Exception(
    'Request failed with status ${response.statusCode}: ${response.body}',
  );
}

    if (response.body.isEmpty) {
      return {};
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClientException implements Exception {
  final Uri uri;
  final String message;
  final int? statusCode;
  final String? responseBody;

  const ApiClientException({
    required this.uri,
    required this.message,
    this.statusCode,
    this.responseBody,
  });

  String get userMessage {
    if (statusCode == 401 || statusCode == 403) {
      return 'The saved login session is not authorized anymore.';
    }

    if (statusCode != null) {
      return 'Server returned HTTP $statusCode.';
    }

    return message;
  }

  String get diagnosticDetails {
    final buffer = StringBuffer()
      ..writeln(message)
      ..writeln('URL: $uri');

    if (statusCode != null) {
      buffer.writeln('HTTP status: $statusCode');
    }

    if (responseBody != null && responseBody!.isNotEmpty) {
      buffer.writeln('Response: $responseBody');
    }

    return buffer.toString().trim();
  }

  @override
  String toString() {
    return diagnosticDetails;
  }
}

class ApiClient {
  static const Duration requestTimeout = Duration(seconds: 60);

  Future<Map<String, dynamic>> postJsonToUrl({
    required String url,
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    return postJsonToUri(uri: Uri.parse(url), body: body, authToken: authToken);
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
    late final http.Response response;

    try {
      response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (authToken != null) 'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode(body),
          )
          .timeout(requestTimeout);
    } on TimeoutException {
      throw ApiClientException(
        uri: uri,
        message:
            'The server did not respond. Please check the network and try again.',
      );
    } catch (error) {
      throw ApiClientException(
        uri: uri,
        message:
            'Could not connect to the server. Please check the network and try again.',
        responseBody: error.toString(),
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiClientException(
        uri: uri,
        message: 'Request failed.',
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }

    if (response.body.isEmpty) {
      return {};
    }

    late final Object? decodedBody;

    try {
      decodedBody = jsonDecode(response.body);
    } catch (_) {
      throw ApiClientException(
        uri: uri,
        message: 'Server response was not valid JSON.',
        responseBody: response.body,
      );
    }

    if (decodedBody is Map<String, dynamic>) {
      return decodedBody;
    }

    throw ApiClientException(
      uri: uri,
      message: 'Server response was not a JSON object.',
      responseBody: response.body,
    );
  }
}

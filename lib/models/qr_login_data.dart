import 'dart:convert';

class QrLoginData {
  final String rawValue;
  final String challenge;
  final String nonce;
  final int posSessionId;
  final int posConfigId;
  final String backendUrl;
  final String restEndpointUrl;
  final DateTime expiresAt;

  const QrLoginData({
    required this.rawValue,
    required this.challenge,
    required this.nonce,
    required this.posSessionId,
    required this.posConfigId,
    required this.backendUrl,
    required this.restEndpointUrl,
    required this.expiresAt,
  });

  factory QrLoginData.fromRaw(String rawValue) {
    final Map<String, dynamic> data = jsonDecode(rawValue);

    final backendUrl = data['backend_url'].toString();
    final restEndpointUrl = data['rest_endpoint_url'].toString();

    if (!_isValidUrl(backendUrl)) {
      throw FormatException('Invalid backend_url');
    }

    if (!_isValidUrl(restEndpointUrl)) {
      throw FormatException('Invalid rest_endpoint_url');
    }

    return QrLoginData(
      rawValue: rawValue,
      challenge: data['challenge'].toString(),
      nonce: data['nonce'].toString(),
      posSessionId: data['pos_session_id'] as int,
      posConfigId: data['pos_config_id'] as int,
      backendUrl: backendUrl,
      restEndpointUrl: restEndpointUrl,
      expiresAt: _parseExpiresAt(data['expires_at'].toString()),
    );
  }

  static DateTime _parseExpiresAt(String value) {
  final normalizedValue = value.contains('T')
      ? value
      : '${value.replaceFirst(' ', 'T')}Z';

  return DateTime.parse(normalizedValue);
}

  static bool _isValidUrl(String value) {
    final uri = Uri.tryParse(value);

    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  bool get isExpired {
    return DateTime.now().toUtc().isAfter(expiresAt);
  }
}
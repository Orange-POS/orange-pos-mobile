import '../../services/api_client.dart';

enum AppErrorType { validation, network, authorization, server, unknown }

class AppError {
  final AppErrorType type;
  final String userMessage;
  final String diagnosticDetails;

  const AppError({
    required this.type,
    required this.userMessage,
    required this.diagnosticDetails,
  });

  factory AppError.validation(String message) {
    return AppError(
      type: AppErrorType.validation,
      userMessage: message,
      diagnosticDetails: message,
    );
  }

  factory AppError.fromException(Object error) {
    if (error is ApiClientException) {
      return AppError(
        type: _typeFromApiException(error),
        userMessage: error.userMessage,
        diagnosticDetails: error.diagnosticDetails,
      );
    }

    final details = error.toString();

    return AppError(
      type: AppErrorType.unknown,
      userMessage: details.replaceFirst('Exception: ', ''),
      diagnosticDetails: details,
    );
  }

  static AppErrorType _typeFromApiException(ApiClientException error) {
    final statusCode = error.statusCode;

    if (statusCode == 401 || statusCode == 403) {
      return AppErrorType.authorization;
    }

    if (statusCode != null) {
      return AppErrorType.server;
    }

    return AppErrorType.network;
  }
}

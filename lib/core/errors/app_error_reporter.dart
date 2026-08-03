import '../../services/api_client.dart';
import '../config/app_config.dart';
import '../crash/crash_reporter.dart';

class AppErrorReporter {
  final CrashReporter crashReporter;
  final AppConfig config;

  const AppErrorReporter({required this.crashReporter, required this.config});

  Object _sanitizeError(Object error) {
    if (error is ApiClientException) {
      return Exception('API request failed: ${error.userMessage}');
    }

    return error;
  }

  Future<void> reportError(
    Object error,
    StackTrace? stackTrace, {
    required String screen,
    required String action,
  }) {
    return crashReporter.recordError(
      _sanitizeError(error),
      stackTrace,
      reason: _buildReason(screen: screen, action: action, error: error),
      fatal: false,
    );
  }

  String _buildReason({
    required String screen,
    required String action,
    required Object error,
  }) {
    final buffer = StringBuffer()
      ..write('screen=$screen')
      ..write(' action=$action')
      ..write(' environment=${config.environment.name}');

    if (error is ApiClientException) {
      buffer
        ..write(' endpoint=${error.uri.path}')
        ..write(' httpStatus=${error.statusCode ?? 'none'}');
    }

    return buffer.toString();
  }
}

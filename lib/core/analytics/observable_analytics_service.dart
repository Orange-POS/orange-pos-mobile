import '../../services/analytics_service.dart';
import '../errors/app_error_reporter.dart';

class ObservableAnalyticsService {
  final AnalyticsService analyticsService;
  final AppErrorReporter appErrorReporter;

  const ObservableAnalyticsService({
    required this.analyticsService,
    required this.appErrorReporter,
  });

  Future<void> trackEvent({
    required String authToken,
    required String backendUrl,
    required String eventName,
    required String screen,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      await analyticsService.trackEvent(
        authToken: authToken,
        backendUrl: backendUrl,
        eventName: eventName,
        screen: screen,
        metadata: metadata,
      );
    } catch (error, stackTrace) {
      await appErrorReporter.reportError(
        error,
        stackTrace,
        screen: screen,
        action: 'analytics_event_$eventName',
      );
    }
  }

  Future<void> trackError({
    required String authToken,
    required String backendUrl,
    required String errorType,
    required String screen,
    required String message,
    String? details,
  }) async {
    try {
      await analyticsService.trackError(
        authToken: authToken,
        backendUrl: backendUrl,
        errorType: errorType,
        screen: screen,
        message: message,
        details: details,
      );
    } catch (error, stackTrace) {
      await appErrorReporter.reportError(
        error,
        stackTrace,
        screen: screen,
        action: 'analytics_error_$errorType',
      );
    }
  }
}

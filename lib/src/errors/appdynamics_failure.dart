import 'failures.dart';

/// Base class for AppDynamics-related failures.
///
/// This failure is returned when operations on [AppDynamicsService] fail.
///
/// ## Common Error Scenarios
///
/// - Initialization failure (SDK not initialized, invalid app key)
/// - Network issues (can't send data to collector)
/// - Invalid configuration (missing required settings)
/// - SDK-specific errors (provider limitations, rate limiting)
///
/// ## Usage Example
///
/// ```dart
/// final result = await appDynamics.initialize(config);
/// result.fold(
///   (failure) {
///     if (failure is AppDynamicsFailure) {
///       print('AppDynamics error: ${failure.message}');
///       print('Error code: ${failure.code}');
///       // Handle AppDynamics failure
///     }
///   },
///   (_) => print('AppDynamics initialized successfully'),
/// );
/// ```
class AppDynamicsFailure extends Failure {
  /// Stack trace for debugging
  final StackTrace? stackTrace;

  const AppDynamicsFailure({
    required super.message,
    super.code,
    super.details,
    this.stackTrace,
  });

  /// Creates an AppDynamics failure from an exception.
  factory AppDynamicsFailure.fromException(
    dynamic exception, {
    String? code,
    StackTrace? stackTrace,
  }) {
    return AppDynamicsFailure(
      message: exception.toString(),
      code: code,
      details: exception,
      stackTrace: stackTrace,
    );
  }

  /// AppDynamics service is not initialized.
  factory AppDynamicsFailure.notInitialized() {
    return const AppDynamicsFailure(
      message: 'AppDynamics service is not initialized. Call initialize() first.',
      code: 'not_initialized',
    );
  }

  /// Invalid configuration provided.
  factory AppDynamicsFailure.invalidConfiguration(String reason) {
    return AppDynamicsFailure(
      message: 'Invalid configuration: $reason',
      code: 'invalid_configuration',
    );
  }

  /// Network error occurred.
  factory AppDynamicsFailure.network(String reason) {
    return AppDynamicsFailure(
      message: 'Network error: $reason',
      code: 'network_error',
    );
  }

  /// Initialization error.
  factory AppDynamicsFailure.initialization(String reason) {
    return AppDynamicsFailure(
      message: 'Initialization error: $reason',
      code: 'initialization_error',
    );
  }

  /// Invalid app key provided.
  factory AppDynamicsFailure.invalidAppKey() {
    return const AppDynamicsFailure(
      message: 'Invalid AppDynamics app key provided',
      code: 'invalid_app_key',
    );
  }

  /// Collector URL error.
  factory AppDynamicsFailure.collectorUrl(String reason) {
    return AppDynamicsFailure(
      message: 'Collector URL error: $reason',
      code: 'collector_url_error',
    );
  }

  /// Screenshot URL error.
  factory AppDynamicsFailure.screenshotUrl(String reason) {
    return AppDynamicsFailure(
      message: 'Screenshot URL error: $reason',
      code: 'screenshot_url_error',
    );
  }

  /// Session frame error.
  factory AppDynamicsFailure.sessionFrame(String reason) {
    return AppDynamicsFailure(
      message: 'Session frame error: $reason',
      code: 'session_frame_error',
    );
  }

  /// Breadcrumb error.
  factory AppDynamicsFailure.breadcrumb(String reason) {
    return AppDynamicsFailure(
      message: 'Breadcrumb error: $reason',
      code: 'breadcrumb_error',
    );
  }

  /// Timer error.
  factory AppDynamicsFailure.timer(String reason) {
    return AppDynamicsFailure(
      message: 'Timer error: $reason',
      code: 'timer_error',
    );
  }

  /// Custom metric error.
  factory AppDynamicsFailure.customMetric(String reason) {
    return AppDynamicsFailure(
      message: 'Custom metric error: $reason',
      code: 'custom_metric_error',
    );
  }

  /// User data error.
  factory AppDynamicsFailure.userData(String reason) {
    return AppDynamicsFailure(
      message: 'User data error: $reason',
      code: 'user_data_error',
    );
  }

  /// Network request tracking error.
  factory AppDynamicsFailure.networkRequest(String reason) {
    return AppDynamicsFailure(
      message: 'Network request tracking error: $reason',
      code: 'network_request_error',
    );
  }

  @override
  String toString() {
    if (code != null) {
      return 'AppDynamicsFailure(code: $code, message: $message)';
    }
    return 'AppDynamicsFailure(message: $message)';
  }
}


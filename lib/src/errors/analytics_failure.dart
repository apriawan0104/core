import 'failures.dart';

/// Failure class for analytics-related errors.
///
/// This failure is returned when operations on [AnalyticsService] fail.
///
/// ## Common Error Scenarios
///
/// - Initialization failure (SDK not initialized, invalid API key)
/// - Network issues (can't send events to server)
/// - Invalid event data (malformed properties, invalid event names)
/// - Configuration errors (missing required settings)
/// - SDK-specific errors (provider limitations, rate limiting)
///
/// ## Usage Example
///
/// ```dart
/// final result = await analytics.trackEvent(event);
/// result.fold(
///   (failure) {
///     if (failure is AnalyticsFailure) {
///       print('Analytics error: ${failure.message}');
///       print('Error code: ${failure.code}');
///       // Handle analytics failure
///     }
///   },
///   (_) => print('Event tracked successfully'),
/// );
/// ```
class AnalyticsFailure extends Failure {
  const AnalyticsFailure({
    required super.message,
    super.code,
    super.details,
  });

  /// Creates an analytics failure from an exception.
  factory AnalyticsFailure.fromException(
    dynamic exception, {
    String? code,
  }) {
    return AnalyticsFailure(
      message: exception.toString(),
      code: code,
      details: exception,
    );
  }

  /// Analytics service is not initialized.
  factory AnalyticsFailure.notInitialized() {
    return const AnalyticsFailure(
      message: 'Analytics service is not initialized. Call initialize() first.',
      code: 'not_initialized',
    );
  }

  /// Invalid event data provided.
  factory AnalyticsFailure.invalidEvent(String reason) {
    return AnalyticsFailure(
      message: 'Invalid event: $reason',
      code: 'invalid_event',
    );
  }

  /// Invalid user data provided.
  factory AnalyticsFailure.invalidUser(String reason) {
    return AnalyticsFailure(
      message: 'Invalid user: $reason',
      code: 'invalid_user',
    );
  }

  /// Network error occurred.
  factory AnalyticsFailure.network(String reason) {
    return AnalyticsFailure(
      message: 'Network error: $reason',
      code: 'network_error',
    );
  }

  /// Configuration error.
  factory AnalyticsFailure.configuration(String reason) {
    return AnalyticsFailure(
      message: 'Configuration error: $reason',
      code: 'configuration_error',
    );
  }

  /// Analytics tracking is disabled.
  factory AnalyticsFailure.disabled() {
    return const AnalyticsFailure(
      message: 'Analytics tracking is disabled',
      code: 'disabled',
    );
  }

  /// Rate limit exceeded.
  factory AnalyticsFailure.rateLimit() {
    return const AnalyticsFailure(
      message: 'Rate limit exceeded. Too many requests.',
      code: 'rate_limit',
    );
  }

  @override
  String toString() {
    if (code != null) {
      return 'AnalyticsFailure(code: $code, message: $message)';
    }
    return 'AnalyticsFailure(message: $message)';
  }
}

/// Failure class for crash reporter-related errors.
///
/// This failure is returned when operations on [CrashReporterService] fail.
///
/// ## Common Error Scenarios
///
/// - Initialization failure (SDK not initialized, invalid API key)
/// - Network issues (can't upload crash reports)
/// - Invalid crash data (malformed stack traces, invalid custom data)
/// - Configuration errors (missing required settings)
/// - SDK-specific errors (provider limitations, storage issues)
///
/// ## Usage Example
///
/// ```dart
/// final result = await crashReporter.recordError(
///   exception: exception,
///   stackTrace: stackTrace,
/// );
/// result.fold(
///   (failure) {
///     if (failure is CrashReporterFailure) {
///       print('Crash reporter error: ${failure.message}');
///       // Handle crash reporter failure
///     }
///   },
///   (_) => print('Error recorded successfully'),
/// );
/// ```
class CrashReporterFailure extends Failure {
  const CrashReporterFailure({
    required super.message,
    super.code,
    super.details,
  });

  /// Creates a crash reporter failure from an exception.
  factory CrashReporterFailure.fromException(
    dynamic exception, {
    String? code,
  }) {
    return CrashReporterFailure(
      message: exception.toString(),
      code: code,
      details: exception,
    );
  }

  /// Crash reporter service is not initialized.
  factory CrashReporterFailure.notInitialized() {
    return const CrashReporterFailure(
      message:
          'Crash reporter service is not initialized. Call initialize() first.',
      code: 'not_initialized',
    );
  }

  /// Invalid crash report data provided.
  factory CrashReporterFailure.invalidReport(String reason) {
    return CrashReporterFailure(
      message: 'Invalid crash report: $reason',
      code: 'invalid_report',
    );
  }

  /// Network error occurred.
  factory CrashReporterFailure.network(String reason) {
    return CrashReporterFailure(
      message: 'Network error: $reason',
      code: 'network_error',
    );
  }

  /// Configuration error.
  factory CrashReporterFailure.configuration(String reason) {
    return CrashReporterFailure(
      message: 'Configuration error: $reason',
      code: 'configuration_error',
    );
  }

  /// Crash reporting is disabled.
  factory CrashReporterFailure.disabled() {
    return const CrashReporterFailure(
      message: 'Crash reporting is disabled',
      code: 'disabled',
    );
  }

  /// Storage error (couldn't save/retrieve crash reports).
  factory CrashReporterFailure.storage(String reason) {
    return CrashReporterFailure(
      message: 'Storage error: $reason',
      code: 'storage_error',
    );
  }

  /// Upload error (couldn't send crash reports to server).
  factory CrashReporterFailure.upload(String reason) {
    return CrashReporterFailure(
      message: 'Upload error: $reason',
      code: 'upload_error',
    );
  }

  @override
  String toString() {
    if (code != null) {
      return 'CrashReporterFailure(code: $code, message: $message)';
    }
    return 'CrashReporterFailure(message: $message)';
  }
}


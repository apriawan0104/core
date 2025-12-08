import 'package:dartz/dartz.dart';

import '../../../errors/network_failure.dart';
import '../../../foundation/domain/entities/network/http_response.entity.dart';
import '../../logging/contract/log.service.dart';
import '../contract/crash_reporter.service.dart';

/// Interceptor for automatic crash reporting of network errors
///
/// This interceptor automatically reports certain network failures
/// to the crash reporter service without requiring manual intervention.
///
/// ## Design Philosophy
///
/// Following the Dependency Independence principle:
/// - ✅ Optional - Consumer apps can choose to use it or not
/// - ✅ Configurable - Control which errors to report
/// - ✅ Safe - Never throws, only logs failures
/// - ✅ Non-intrusive - Doesn't modify the error flow
///
/// ## Usage
///
/// ```dart
/// // Setup in DI or main.dart
/// final httpClient = getIt<HttpClient>();
/// final crashReporter = getIt<CrashReporterService>();
///
/// // Add the interceptor
/// httpClient.addErrorInterceptor(
///   CrashReportingInterceptor(
///     crashReporter: crashReporter,
///     logger: getIt<LogService>(),
///   ).call,
/// );
/// ```
///
/// ## Configuration
///
/// ```dart
/// CrashReportingInterceptor(
///   crashReporter: crashReporter,
///   logger: logger,
///   reportClientErrors: false,     // Don't report 4xx errors
///   reportTimeoutErrors: true,     // Report timeout errors
///   reportConnectionErrors: true,  // Report connection errors
/// )
/// ```
///
/// ## What Gets Reported
///
/// By default:
/// - ✅ Server errors (5xx) - Always reported
/// - ✅ Timeout errors - Reported (configurable)
/// - ✅ Connection errors - Reported (configurable)
/// - ❌ Client errors (4xx) - Not reported (configurable)
///
/// ## Best Practices
///
/// 1. Don't report client errors (4xx) - they're usually user input issues
/// 2. Always report server errors (5xx) - they indicate backend problems
/// 3. Report timeout/connection errors to track network quality
/// 4. Add custom context for better debugging
class CrashReportingInterceptor {
  /// The crash reporter service to send errors to
  final CrashReporterService crashReporter;

  /// Optional logging service for debug output
  final LogService? logger;

  /// Whether to report client errors (4xx)
  ///
  /// Default: false (client errors are usually user input issues)
  final bool reportClientErrors;

  /// Whether to report timeout errors
  ///
  /// Default: true (useful for tracking network quality)
  final bool reportTimeoutErrors;

  /// Whether to report connection errors
  ///
  /// Default: true (useful for tracking network issues)
  final bool reportConnectionErrors;

  /// Whether to report server errors (5xx)
  ///
  /// Default: true (always report server errors)
  final bool reportServerErrors;

  /// Custom context to add to error reports
  ///
  /// This will be included in the crash report for debugging
  final String? context;

  CrashReportingInterceptor({
    required this.crashReporter,
    this.logger,
    this.reportClientErrors = false,
    this.reportTimeoutErrors = true,
    this.reportConnectionErrors = true,
    this.reportServerErrors = true,
    this.context,
  });

  /// Call method to be used as ErrorInterceptor
  ///
  /// This method is called by the HTTP client when a network error occurs.
  /// It decides whether to report the error to the crash reporter based on
  /// the error type and configuration.
  ///
  /// Returns the original failure unchanged, so error handling continues normally.
  Future<Either<NetworkFailure, HttpResponseEntity<dynamic>>> call(
    NetworkFailure failure,
  ) async {
    if (_shouldReport(failure)) {
      await _reportError(failure);
    }

    // Always return the original failure - don't modify error flow
    return Left(failure);
  }

  /// Determine if this failure should be reported
  bool _shouldReport(NetworkFailure failure) {
    if (failure is ServerFailure && reportServerErrors) {
      return true;
    }
    if (failure is TimeoutFailure && reportTimeoutErrors) {
      return true;
    }
    if (failure is ConnectionFailure && reportConnectionErrors) {
      return true;
    }
    if (failure is ClientFailure && reportClientErrors) {
      return true;
    }
    return false;
  }

  /// Report the error to the crash reporter
  Future<void> _reportError(NetworkFailure failure) async {
    try {
      final errorType = failure.runtimeType.toString();
      final statusCode = _getStatusCode(failure);

      await crashReporter.recordError(
        exception: failure,
        stackTrace: StackTrace.current,
        reason: context ?? 'Network error: $errorType',
        information: [
          'Error Type: $errorType',
          'Message: ${failure.message}',
          'Code: ${failure.code ?? 'N/A'}',
          if (statusCode != null) 'Status Code: $statusCode',
          if (context != null) 'Context: $context',
        ],
        fatal: false, // Network errors are not fatal crashes
      );

      logger?.debug(
        'Network error reported to crash reporter: ${failure.message}',
      );
    } catch (e) {
      // CRITICAL: Never throw from error reporting
      // This could cause infinite loops or crash the app
      logger?.warning(
        'Failed to report network error to crash reporter: $e',
      );
    }
  }

  /// Extract status code from failure if available
  int? _getStatusCode(NetworkFailure failure) {
    if (failure is ServerFailure) {
      return failure.statusCode;
    }
    if (failure is ClientFailure) {
      return failure.statusCode;
    }
    return null;
  }
}

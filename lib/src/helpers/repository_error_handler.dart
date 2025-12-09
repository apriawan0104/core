import 'package:injectable/injectable.dart';
import '../foundation/domain/typedef/value_guard.typedef.dart';
import '../errors/failures.dart';
import '../infrastructure/analytics/contract/crash_reporter.service.dart';

/// Repository Error Handler - Centralized error handling for all BUMA apps
///
/// This service provides centralized error handling for all repository operations
/// across all applications using buma_core_plus.
///
/// Features:
/// 1. Dual-path error handling (User feedback + Crashlytics monitoring)
/// 2. Smart error filtering (user errors vs system errors)
/// 3. Automatic user-friendly error messages
/// 4. Consistent error handling pattern
/// 5. Highly customizable per operation
///
/// Benefits:
/// - DRY: No repetitive try-catch blocks in repositories
/// - Centralized: One place to modify error handling logic for ALL apps
/// - Reusable: All BUMA apps use the same handler
/// - Testable: Easy to mock and test
/// - Standard: Consistent error handling across organization
///
/// Usage in any app:
/// ```dart
/// @LazySingleton(as: AuthRepository)
/// class AuthRepositoryImpl implements AuthRepository {
///   final AuthRemoteDataSource remoteDataSource;
///   final RepositoryErrorHandler errorHandler;
///
///   AuthRepositoryImpl(this.remoteDataSource, this.errorHandler);
///
///   @override
///   Future<ValueGuard<void>> signOut() async {
///     return errorHandler.execute(
///       operation: () => remoteDataSource.signOut(),
///       feature: 'authentication',
///       operationName: 'signOut',
///     );
///   }
///
///   @override
///   Future<ValueGuard<User>> signIn(String email, String password) async {
///     return errorHandler.execute(
///       operation: () => remoteDataSource.signIn(email, password),
///       feature: 'authentication',
///       operationName: 'signIn',
///       extras: {'email': email},
///       userMessageBuilder: (error) {
///         if (error.toString().contains('invalid credentials')) {
///           return 'Invalid email or password';
///         }
///         return 'Sign in failed. Please try again';
///       },
///     );
///   }
/// }
/// ```
///
/// See also:
/// - [CrashReporterService] - For error reporting configuration
/// - [ValueGuard] - For result type
/// - [ErrorHandlerHelper] - For additional error handling utilities
@lazySingleton
class RepositoryErrorHandler {
  /// Crash reporter service for error monitoring
  ///
  /// If null, errors will not be reported to Crashlytics
  /// but will still be handled and returned to users.
  final CrashReporterService? crashReporter;

  /// Create a repository error handler
  ///
  /// [crashReporter] is optional - if not provided, errors will not be
  /// reported to Crashlytics but will still be handled properly.
  RepositoryErrorHandler(this.crashReporter);

  /// Execute repository operation with automatic error handling
  ///
  /// This method wraps any repository operation and provides:
  /// 1. Success path: Returns ValueGuard.success with result
  /// 2. Error path: Catches errors, reports to Crashlytics (filtered),
  ///    and returns ValueGuard.failure with user-friendly message
  ///
  /// Parameters:
  /// - [operation]: The async operation to execute
  /// - [feature]: Feature name (e.g., 'authentication', 'profile', 'payment')
  /// - [operationName]: Operation name (e.g., 'signOut', 'signIn', 'updateProfile')
  /// - [extras]: Additional context to send to Crashlytics (e.g., user ID, request data)
  /// - [shouldReport]: Custom function to determine if error should be reported.
  ///   If not provided, uses default filtering logic.
  /// - [userMessageBuilder]: Custom function to build user-friendly message.
  ///   If not provided, uses default message mapping.
  /// - [forceReport]: Force reporting to Crashlytics regardless of filter.
  ///   Useful for critical operations like initialization.
  ///
  /// Returns [ValueGuard] containing the result on success or failure with message
  ///
  /// Example:
  /// ```dart
  /// // Basic usage (automatic everything)
  /// return errorHandler.execute(
  ///   operation: () => dataSource.getData(),
  ///   feature: 'profile',
  ///   operationName: 'getData',
  /// );
  ///
  /// // With custom message
  /// return errorHandler.execute(
  ///   operation: () => dataSource.purchase(productId),
  ///   feature: 'payment',
  ///   operationName: 'purchase',
  ///   userMessageBuilder: (error) => 'Payment failed. Card declined.',
  /// );
  ///
  /// // With extra context for Crashlytics
  /// return errorHandler.execute(
  ///   operation: () => dataSource.sendMoney(amount, toUserId),
  ///   feature: 'payment',
  ///   operationName: 'sendMoney',
  ///   extras: {
  ///     'amount': amount.toString(),
  ///     'toUserId': toUserId,
  ///     'currency': 'IDR',
  ///   },
  /// );
  ///
  /// // Force reporting for critical operations
  /// return errorHandler.execute(
  ///   operation: () => dataSource.initialize(),
  ///   feature: 'app',
  ///   operationName: 'initialize',
  ///   forceReport: true,
  /// );
  /// ```
  Future<ValueGuard<T>> execute<T>({
    required Future<T> Function() operation,
    required String feature,
    required String operationName,
    Map<String, dynamic>? extras,
    bool Function(dynamic error)? shouldReport,
    String Function(dynamic error)? userMessageBuilder,
    bool forceReport = false,
  }) async {
    try {
      final result = await operation();
      return ValueGuards.success(result);
    } catch (error, stackTrace) {
      // ═══════════════════════════════════════════════════════════════
      // PATH 2: Report to Crashlytics (FILTERED)
      // ═══════════════════════════════════════════════════════════════
      await _reportIfNeeded(
        error: error,
        stackTrace: stackTrace,
        feature: feature,
        operationName: operationName,
        extras: extras,
        shouldReport: shouldReport,
        forceReport: forceReport,
      );

      // ═══════════════════════════════════════════════════════════════
      // PATH 1: Return Failure to User (ALWAYS)
      // ═══════════════════════════════════════════════════════════════
      final userMessage = userMessageBuilder?.call(error) ??
          _getDefaultUserMessage(operationName, error);

      return ValueGuards.failure(Failure(message: userMessage));
    }
  }

  /// Report error to Crashlytics if needed
  ///
  /// This method determines whether an error should be reported to Crashlytics
  /// and performs the reporting if needed.
  Future<void> _reportIfNeeded({
    required dynamic error,
    required StackTrace stackTrace,
    required String feature,
    required String operationName,
    Map<String, dynamic>? extras,
    bool Function(dynamic error)? shouldReport,
    bool forceReport = false,
  }) async {
    if (crashReporter == null) return;

    // Determine if should report
    final doReport = forceReport ||
        (shouldReport?.call(error) ?? _defaultShouldReport(error));

    if (doReport) {
      try {
        await crashReporter!.recordError(
          exception: error,
          stackTrace: stackTrace,
          reason: 'Repository error: $feature.$operationName',
          information: [
            'feature: $feature',
            'operation: $operationName',
            'errorType: ${error.runtimeType.toString()}',
            'timestamp: ${DateTime.now().toIso8601String()}',
            if (extras != null)
              ...extras.entries.map((e) => '${e.key}: ${e.value}'),
          ],
        );
      } catch (reportError) {
        // Silently fail if Crashlytics reporting fails
        // Don't break the app because of monitoring
        // ignore: avoid_print
        print('Failed to report to Crashlytics: $reportError');
      }
    }
  }

  /// Default logic to determine if error should be reported to Crashlytics
  ///
  /// This method implements smart filtering to reduce noise in Crashlytics:
  /// - DON'T report: Expected user errors (cancelled, invalid credentials, etc.)
  /// - DO report: System/infrastructure errors (network, timeout, service down, etc.)
  ///
  /// Returns:
  /// - false: Expected user errors that should not be reported
  /// - true: System/infrastructure errors that should be reported
  ///
  /// You can override this per operation using the [shouldReport] parameter
  /// in the [execute] method.
  bool _defaultShouldReport(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    // ═══════════════════════════════════════════════════════════════
    // DON'T report expected user errors
    // ═══════════════════════════════════════════════════════════════
    final expectedUserErrors = [
      'user cancelled',
      'cancelled by user',
      'authentication cancelled',
      'invalid credentials',
      'invalid_grant',
      'user not found',
      'account not found',
      'login required',
      'permission denied',
      'access denied',
      'unauthorized',
    ];

    for (final expected in expectedUserErrors) {
      if (errorMessage.contains(expected)) {
        return false; // ❌ Don't report
      }
    }

    // ═══════════════════════════════════════════════════════════════
    // DO report system/infrastructure errors
    // ═══════════════════════════════════════════════════════════════
    final criticalErrors = [
      'timeout',
      'network error',
      'no internet',
      'connection failed',
      'service unavailable',
      'internal server',
      'server error',
      '503',
      '500',
      '502',
      '504',
      'configuration error',
      'invalid_client',
      'invalid configuration',
      'null pointer',
      'nullpointerexception',
      'exception',
    ];

    for (final critical in criticalErrors) {
      if (errorMessage.contains(critical)) {
        return true; // ✅ Report to Crashlytics
      }
    }

    // ═══════════════════════════════════════════════════════════════
    // Default: Don't report (be conservative)
    // Only report what we know is important to avoid noise
    // ═══════════════════════════════════════════════════════════════
    return false;
  }

  /// Get default user-friendly error message
  ///
  /// Converts technical error messages to user-friendly ones.
  /// This ensures users see helpful messages instead of technical jargon.
  ///
  /// You can override this per operation using the [userMessageBuilder]
  /// parameter in the [execute] method.
  ///
  /// Error message mappings:
  /// - Network/connectivity errors → "Please check your internet connection"
  /// - Service unavailable → "Service temporarily unavailable. Please try again later"
  /// - Server errors → "Something went wrong on our end. Please try again later"
  /// - Authentication errors → "Invalid username or password"
  /// - Configuration errors → "Configuration error. Please contact support"
  /// - Default → "[operation] failed. Please try again"
  String _getDefaultUserMessage(String operation, dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    // Network/connectivity errors
    if (errorMessage.contains('network') ||
        errorMessage.contains('timeout') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('no internet')) {
      return 'Please check your internet connection and try again';
    }

    // Service unavailable
    if (errorMessage.contains('service unavailable') ||
        errorMessage.contains('503') ||
        errorMessage.contains('502') ||
        errorMessage.contains('504')) {
      return 'Service temporarily unavailable. Please try again later';
    }

    // Server errors
    if (errorMessage.contains('internal server') ||
        errorMessage.contains('500')) {
      return 'Something went wrong on our end. Please try again later';
    }

    // Authentication errors
    if (errorMessage.contains('invalid credentials') ||
        errorMessage.contains('invalid_grant')) {
      return 'Invalid username or password';
    }

    if (errorMessage.contains('user cancelled') ||
        errorMessage.contains('cancelled')) {
      return 'Operation cancelled';
    }

    // Configuration errors
    if (errorMessage.contains('configuration') ||
        errorMessage.contains('invalid_client')) {
      return 'Configuration error. Please contact support';
    }

    // Default: Operation name + generic message
    return '$operation failed. Please try again';
  }

  /// Set user identifier for Crashlytics
  ///
  /// Call this after user signs in to tag all subsequent error reports
  /// with the user ID. This helps track which users are experiencing errors.
  ///
  /// Example:
  /// ```dart
  /// // After successful sign in
  /// await errorHandler.setUserIdentifier(user.id);
  /// ```
  Future<void> setUserIdentifier(String userId) async {
    await crashReporter?.setUserIdentifier(userId);
  }

  /// Set custom data for Crashlytics
  ///
  /// Use this to add custom context that will be included in all error reports.
  /// Useful for environment info, feature flags, etc.
  ///
  /// Example:
  /// ```dart
  /// await errorHandler.setCustomData({
  ///   'environment': 'production',
  ///   'appVersion': '1.0.0',
  ///   'platform': Platform.operatingSystem,
  /// });
  /// ```
  Future<void> setCustomData(Map<String, dynamic> data) async {
    if (crashReporter == null) return;

    await crashReporter!.setCustomKeys(data);
  }

  /// Clear user data from Crashlytics
  ///
  /// Call this when user signs out to stop tagging errors with user ID.
  ///
  /// Example:
  /// ```dart
  /// // On sign out
  /// await errorHandler.clearUserData();
  /// ```
  Future<void> clearUserData() async {
    await crashReporter?.setUserIdentifier('');
  }
}

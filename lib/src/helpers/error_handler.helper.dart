import 'package:dartz/dartz.dart';

import '../errors/failures.dart';
import '../foundation/domain/typedef/result.typedef.dart';
import '../infrastructure/analytics/contract/crash_reporter.service.dart';
import '../infrastructure/logging/contract/log.service.dart';

/// Global error handler utility
///
/// Provides unified error handling with automatic crash reporting
/// and logging integration. This utility simplifies error handling
/// throughout the application and ensures consistent error tracking.
///
/// ## Design Philosophy
///
/// Following BUMA Core principles:
/// - ✅ Optional - Inject only when needed
/// - ✅ Configurable - Control crash reporting per operation
/// - ✅ Composable - Works with Either/Result pattern
/// - ✅ Safe - Never throws from error handling
/// - ✅ Testable - Easy to mock dependencies
///
/// ## Setup
///
/// Register in dependency injection:
///
/// ```dart
/// // DI setup
/// getIt.registerLazySingleton<ErrorHandler>(
///   () => ErrorHandler(
///     crashReporter: getIt<CrashReporterService>(),
///     logger: getIt<LoggingService>(),
///   ),
/// );
/// ```
///
/// ## Basic Usage
///
/// ### Handle Either/Result
///
/// ```dart
/// class UserRepository {
///   final ErrorHandler errorHandler;
///   final AuthService authService;
///
///   Future<User?> getCurrentUser() async {
///     return errorHandler.handleResult(
///       await authService.getCurrentUser(),
///       reportToCrashlytics: true,
///       context: 'Getting current user',
///       onError: (failure) async {
///         // Show error to user
///         showSnackBar(failure.message);
///       },
///     );
///   }
/// }
/// ```
///
/// ### Wrap Async Operations
///
/// ```dart
/// Future<Either<Failure, User>> saveProfile(User user) async {
///   return errorHandler.wrapAsync(
///     () => api.saveUserProfile(user),
///     context: 'Saving user profile',
///     reportToCrashlytics: true,
///   );
/// }
/// ```
///
/// ## Advanced Usage
///
/// ### With Callbacks
///
/// ```dart
/// final user = await errorHandler.handleResult(
///   await authService.signIn(email, password),
///   reportToCrashlytics: true,
///   context: 'User sign in',
///   onError: (failure) async {
///     // Track analytics
///     analytics.trackEvent('login_failed');
///     // Show UI error
///     showErrorDialog(failure.message);
///   },
///   onSuccess: (credentials) async {
///     // Track analytics
///     analytics.trackEvent('login_success');
///     // Navigate
///     Navigator.pushReplacementNamed(context, '/home');
///   },
/// );
/// ```
///
/// ### Wrap Synchronous Operations
///
/// ```dart
/// final result = errorHandler.wrapSync(
///   () => jsonDecode(jsonString),
///   context: 'Parsing JSON response',
/// );
/// ```
///
/// ## Benefits
///
/// 1. **DRY** - No repetitive error handling code
/// 2. **Consistent** - All errors handled the same way
/// 3. **Centralized** - Error reporting logic in one place
/// 4. **Testable** - Easy to mock for unit tests
/// 5. **Optional** - Choose when to report to Crashlytics
/// 6. **Flexible** - Support callbacks for custom handling
///
/// ## See Also
///
/// - [CrashReporterService] - For crash reporting
/// - [LogService] - For logging
/// - [Result] - Type alias for Either
class ErrorHandler {
  /// The crash reporter service for error reporting
  ///
  /// Optional - if not provided, crash reporting will be skipped
  final CrashReporterService? crashReporter;

  /// The logging service for debug output
  ///
  /// Optional - if not provided, logging will be skipped
  final LogService? logger;

  const ErrorHandler({
    this.crashReporter,
    this.logger,
  });

  /// Handle Either/Result with automatic error reporting
  ///
  /// Simplifies error handling by providing automatic logging and crash
  /// reporting, plus callbacks for custom error/success handling.
  ///
  /// **Parameters:**
  /// - [result] - The Either/Result to handle
  /// - [reportToCrashlytics] - Whether to report errors to crash reporter
  /// - [fatal] - Mark error as fatal in crash reporter
  /// - [context] - Additional context for error reporting/logging
  /// - [onError] - Optional callback when error occurs
  /// - [onSuccess] - Optional callback when success occurs
  ///
  /// **Returns:**
  /// The success value or null if error occurred
  ///
  /// **Example:**
  /// ```dart
  /// final user = await errorHandler.handleResult(
  ///   await authService.getCurrentUser(),
  ///   reportToCrashlytics: true,
  ///   context: 'Getting current user',
  ///   onError: (failure) async {
  ///     showErrorToUser(failure.message);
  ///   },
  /// );
  /// ```
  Future<R?> handleResult<L extends Failure, R>(
    Either<L, R> result, {
    bool reportToCrashlytics = false,
    bool fatal = false,
    String? context,
    Future<void> Function(L failure)? onError,
    Future<void> Function(R success)? onSuccess,
  }) async {
    return result.fold(
      (failure) async {
        // Log error
        final errorMessage =
            context != null ? '$context: ${failure.message}' : failure.message;
        logger?.error(errorMessage);

        // Report to crash reporter if enabled
        if (reportToCrashlytics && crashReporter != null) {
          await _reportToCrashlytics(
            failure: failure,
            context: context,
            fatal: fatal,
          );
        }

        // Call error callback
        await onError?.call(failure);

        return null;
      },
      (success) async {
        // Call success callback
        await onSuccess?.call(success);
        return success;
      },
    );
  }

  /// Wrap async operations with automatic error handling
  ///
  /// Converts exceptions to Failures and optionally reports them
  /// to the crash reporter. Useful for wrapping operations that
  /// might throw exceptions.
  ///
  /// **Parameters:**
  /// - [operation] - The async operation to wrap
  /// - [reportToCrashlytics] - Whether to report errors to crash reporter
  /// - [context] - Additional context for error reporting
  /// - [fatal] - Mark error as fatal in crash reporter
  ///
  /// **Returns:**
  /// Either<Failure, T> - Left if error occurred, Right if successful
  ///
  /// **Example:**
  /// ```dart
  /// final result = await errorHandler.wrapAsync(
  ///   () async {
  ///     final response = await http.post('/users', body: data);
  ///     return User.fromJson(response.data);
  ///   },
  ///   context: 'Creating new user',
  ///   reportToCrashlytics: true,
  /// );
  ///
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (user) => print('Success: ${user.name}'),
  /// );
  /// ```
  Future<Either<Failure, T>> wrapAsync<T>(
    Future<T> Function() operation, {
    bool reportToCrashlytics = true,
    String? context,
    bool fatal = false,
  }) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (e, stackTrace) {
      final failure = _convertToFailure(e);

      // Log error
      final errorMessage =
          context != null ? '$context: ${failure.message}' : failure.message;
      logger?.error(errorMessage);

      // Auto-report to crashlytics
      if (reportToCrashlytics && crashReporter != null) {
        await crashReporter!.recordError(
          exception: e,
          stackTrace: stackTrace,
          reason: context ?? 'Async operation failed',
          fatal: fatal,
        );
      }

      return Left(failure);
    }
  }

  /// Wrap synchronous operations with error handling
  ///
  /// Converts exceptions to Failures for sync operations.
  /// Note: Sync operations are not reported to crash reporter
  /// to avoid blocking the main thread.
  ///
  /// **Parameters:**
  /// - [operation] - The sync operation to wrap
  /// - [context] - Additional context for logging
  ///
  /// **Returns:**
  /// Either<Failure, T> - Left if error occurred, Right if successful
  ///
  /// **Example:**
  /// ```dart
  /// final result = errorHandler.wrapSync(
  ///   () => jsonDecode(jsonString),
  ///   context: 'Parsing JSON',
  /// );
  ///
  /// result.fold(
  ///   (failure) => print('Parse error: ${failure.message}'),
  ///   (data) => print('Parsed: $data'),
  /// );
  /// ```
  Either<Failure, T> wrapSync<T>(
    T Function() operation, {
    String? context,
  }) {
    try {
      final result = operation();
      return Right(result);
    } catch (e) {
      final failure = _convertToFailure(e);

      final errorMessage =
          context != null ? '$context: ${failure.message}' : failure.message;
      logger?.error(errorMessage);

      return Left(failure);
    }
  }

  /// Report failure to crash reporter
  Future<void> _reportToCrashlytics({
    required Failure failure,
    String? context,
    bool fatal = false,
  }) async {
    try {
      await crashReporter!.recordError(
        exception: failure,
        stackTrace: StackTrace.current,
        reason: context ?? failure.message,
        information: [
          'Failure Type: ${failure.runtimeType}',
          'Code: ${failure.code ?? 'N/A'}',
          'Details: ${failure.details?.toString() ?? 'N/A'}',
          if (context != null) 'Context: $context',
        ],
        fatal: fatal,
      );
    } catch (e) {
      // CRITICAL: Never throw from error reporting
      // This could cause infinite loops
      logger?.warning('Failed to report to Crashlytics: $e');
    }
  }

  /// Convert exception to Failure
  Failure _convertToFailure(dynamic error) {
    // If already a Failure, return as-is
    if (error is Failure) return error;

    // Convert exception to generic Failure
    return Failure(
      message: error.toString(),
      details: error,
    );
  }
}

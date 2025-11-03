import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../errors/failures.dart';
import '../models/crash_report.model.dart';

/// Abstract interface for crash reporting services.
///
/// This interface provides a dependency-independent abstraction for crash
/// and error reporting. It can be implemented by any crash reporting provider
/// (Firebase Crashlytics, Sentry, Bugsnag, etc.) without exposing their APIs.
///
/// ## Design Philosophy
///
/// This service follows the Dependency Independence principle:
/// - No third-party types exposed in public API
/// - Easy to switch between crash reporting providers
/// - Multiple implementations can coexist
/// - Testable with mock implementations
///
/// ## Usage Example
///
/// ```dart
/// // Initialize crash reporting
/// await crashReporter.initialize();
///
/// // Set user information
/// await crashReporter.setUserIdentifier('user_123');
/// await crashReporter.setUserEmail('user@example.com');
///
/// // Record custom error
/// await crashReporter.recordError(
///   exception: Exception('Something went wrong'),
///   stackTrace: StackTrace.current,
///   reason: 'User attempted invalid action',
///   fatal: false,
/// );
///
/// // Record custom log
/// await crashReporter.log('User logged in successfully');
///
/// // Set custom keys for debugging
/// await crashReporter.setCustomKey('last_action', 'checkout');
/// ```
///
/// ## Implementation Examples
///
/// - [FirebaseCrashlyticsServiceImpl] - Firebase Crashlytics implementation
/// - [SentryCrashReporterServiceImpl] - Sentry implementation (future)
/// - [BugsnagCrashReporterServiceImpl] - Bugsnag implementation (future)
///
/// ## Error Handling
///
/// All methods return `Either<Failure, T>` for consistent error handling:
/// - Left(CrashReporterFailure) - When operation fails
/// - Right(value) - When operation succeeds
abstract class CrashReporterService {
  /// Initializes the crash reporting service.
  ///
  /// Must be called before any other methods. Some implementations may
  /// automatically collect uncaught errors after initialization.
  ///
  /// Returns:
  /// - Right(void) - Initialization successful
  /// - Left(CrashReporterFailure) - Initialization failed
  ///
  /// Example:
  /// ```dart
  /// final result = await crashReporter.initialize();
  /// result.fold(
  ///   (failure) => print('Failed to initialize: $failure'),
  ///   (_) => print('Crash reporter initialized'),
  /// );
  /// ```
  Future<Either<Failure, void>> initialize();

  /// Records an error with optional stack trace.
  ///
  /// Use this to manually report caught exceptions or errors that you want
  /// to track but don't crash the app.
  ///
  /// [exception] - The exception or error object
  /// [stackTrace] - Stack trace associated with the error (optional)
  /// [reason] - Human-readable reason for the error (optional)
  /// [information] - Additional context information (optional)
  /// [fatal] - Whether this error is fatal (default: false)
  ///
  /// Returns:
  /// - Right(void) - Error recorded successfully
  /// - Left(CrashReporterFailure) - Failed to record error
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await riskyOperation();
  /// } catch (e, stackTrace) {
  ///   await crashReporter.recordError(
  ///     exception: e,
  ///     stackTrace: stackTrace,
  ///     reason: 'Failed to complete risky operation',
  ///     information: ['user_id: 123', 'attempt: 2'],
  ///     fatal: false,
  ///   );
  /// }
  /// ```
  Future<Either<Failure, void>> recordError({
    required dynamic exception,
    StackTrace? stackTrace,
    String? reason,
    List<String>? information,
    bool fatal = false,
  });

  /// Records a Flutter error.
  ///
  /// Specifically designed for Flutter framework errors captured by
  /// FlutterError.onError.
  ///
  /// [details] - Flutter error details
  /// [fatal] - Whether this error is fatal (default: false)
  ///
  /// Returns:
  /// - Right(void) - Error recorded successfully
  /// - Left(CrashReporterFailure) - Failed to record error
  ///
  /// Example:
  /// ```dart
  /// FlutterError.onError = (FlutterErrorDetails details) {
  ///   crashReporter.recordFlutterError(details);
  /// };
  /// ```
  Future<Either<Failure, void>> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  });

  /// Records a custom crash report.
  ///
  /// Use this for more detailed crash reporting with custom data.
  ///
  /// [report] - The crash report with all relevant information
  ///
  /// Returns:
  /// - Right(void) - Crash recorded successfully
  /// - Left(CrashReporterFailure) - Failed to record crash
  ///
  /// Example:
  /// ```dart
  /// await crashReporter.recordCrash(
  ///   CrashReport(
  ///     exception: exception,
  ///     stackTrace: stackTrace,
  ///     message: 'Payment processing failed',
  ///     customData: {
  ///       'transaction_id': '123',
  ///       'amount': 99.99,
  ///     },
  ///     fatal: true,
  ///   ),
  /// );
  /// ```
  Future<Either<Failure, void>> recordCrash(CrashReport report);

  /// Logs a message to the crash reporter.
  ///
  /// Logs are included with crash reports to provide context about what
  /// the user was doing before the crash.
  ///
  /// [message] - The log message
  ///
  /// Returns:
  /// - Right(void) - Message logged successfully
  /// - Left(CrashReporterFailure) - Failed to log message
  ///
  /// Example:
  /// ```dart
  /// await crashReporter.log('User navigated to checkout');
  /// await crashReporter.log('Payment method selected: credit_card');
  /// ```
  Future<Either<Failure, void>> log(String message);

  /// Sets a custom key-value pair.
  ///
  /// Custom keys are included with crash reports to provide additional
  /// context for debugging. They persist across app sessions.
  ///
  /// [key] - The key name
  /// [value] - The value (can be any type)
  ///
  /// Returns:
  /// - Right(void) - Key set successfully
  /// - Left(CrashReporterFailure) - Failed to set key
  ///
  /// Example:
  /// ```dart
  /// await crashReporter.setCustomKey('last_screen', 'checkout');
  /// await crashReporter.setCustomKey('items_in_cart', 3);
  /// await crashReporter.setCustomKey('is_premium', true);
  /// ```
  Future<Either<Failure, void>> setCustomKey(String key, dynamic value);

  /// Sets multiple custom key-value pairs at once.
  ///
  /// [customKeys] - Map of key-value pairs to set
  ///
  /// Returns:
  /// - Right(void) - Keys set successfully
  /// - Left(CrashReporterFailure) - Failed to set keys
  ///
  /// Example:
  /// ```dart
  /// await crashReporter.setCustomKeys({
  ///   'app_version': '1.2.3',
  ///   'user_type': 'premium',
  ///   'last_sync': DateTime.now().toIso8601String(),
  /// });
  /// ```
  Future<Either<Failure, void>> setCustomKeys(Map<String, dynamic> customKeys);

  /// Sets the user identifier.
  ///
  /// This helps you track which users are experiencing crashes.
  ///
  /// [identifier] - Unique user identifier
  ///
  /// Returns:
  /// - Right(void) - User identifier set successfully
  /// - Left(CrashReporterFailure) - Failed to set identifier
  ///
  /// Example:
  /// ```dart
  /// await crashReporter.setUserIdentifier('user_123');
  /// ```
  Future<Either<Failure, void>> setUserIdentifier(String identifier);

  /// Sets the user email.
  ///
  /// [email] - User's email address
  ///
  /// Returns:
  /// - Right(void) - Email set successfully
  /// - Left(CrashReporterFailure) - Failed to set email
  ///
  /// Example:
  /// ```dart
  /// await crashReporter.setUserEmail('user@example.com');
  /// ```
  Future<Either<Failure, void>> setUserEmail(String email);

  /// Sets the user name.
  ///
  /// [name] - User's name
  ///
  /// Returns:
  /// - Right(void) - Name set successfully
  /// - Left(CrashReporterFailure) - Failed to set name
  ///
  /// Example:
  /// ```dart
  /// await crashReporter.setUserName('John Doe');
  /// ```
  Future<Either<Failure, void>> setUserName(String name);

  /// Enables or disables crash reporting collection.
  ///
  /// When disabled, crashes and errors will not be reported.
  /// Useful for respecting user privacy preferences.
  ///
  /// [enabled] - Whether crash reporting should be enabled
  ///
  /// Returns:
  /// - Right(void) - Setting updated successfully
  /// - Left(CrashReporterFailure) - Failed to update setting
  ///
  /// Example:
  /// ```dart
  /// // Disable crash reporting if user opts out
  /// await crashReporter.setCrashCollectionEnabled(false);
  /// ```
  Future<Either<Failure, void>> setCrashCollectionEnabled(bool enabled);

  /// Checks if crash reporting collection is enabled.
  ///
  /// Returns:
  /// - Right(bool) - Current enabled state
  /// - Left(CrashReporterFailure) - Failed to get state
  Future<Either<Failure, bool>> isCrashCollectionEnabled();

  /// Forces sending of any unsent crash reports.
  ///
  /// Most crash reporters batch reports and send them later.
  /// Use this to force immediate sending.
  ///
  /// Returns:
  /// - Right(void) - Reports sent successfully
  /// - Left(CrashReporterFailure) - Failed to send reports
  ///
  /// Example:
  /// ```dart
  /// // Send all pending crash reports before app closes
  /// await crashReporter.sendUnsentReports();
  /// ```
  Future<Either<Failure, void>> sendUnsentReports();

  /// Deletes any unsent crash reports.
  ///
  /// Returns:
  /// - Right(void) - Reports deleted successfully
  /// - Left(CrashReporterFailure) - Failed to delete reports
  Future<Either<Failure, void>> deleteUnsentReports();

  /// Checks if there are any unsent crash reports.
  ///
  /// Returns:
  /// - Right(bool) - True if there are unsent reports
  /// - Left(CrashReporterFailure) - Failed to check
  Future<Either<Failure, bool>> hasUnsentReports();

  /// Disposes resources used by the crash reporter.
  ///
  /// Call this when the service is no longer needed.
  Future<Either<Failure, void>> dispose();
}

import 'package:dartz/dartz.dart';

import '../../../errors/failures.dart';
import '../models/appdynamics_breadcrumb.model.dart';
import '../models/appdynamics_config.model.dart';
import '../models/appdynamics_session_frame.model.dart';
import '../models/appdynamics_timer.model.dart';

/// Abstract interface for AppDynamics monitoring services.
///
/// This interface provides a dependency-independent abstraction for AppDynamics
/// Mobile Real User Monitoring (RUM). It can be implemented by any AppDynamics
/// SDK without exposing their specific APIs.
///
/// ## Design Philosophy
///
/// This service follows the Dependency Independence principle:
/// - No third-party types exposed in public API
/// - Easy to switch between AppDynamics SDK versions
/// - Testable with mock implementations
/// - All methods return `Either<Failure, T>` for consistent error handling
///
/// ## Features
///
/// - Network request tracking
/// - Automatic crash reporting
/// - Screen tracking
/// - ANR (App Not Responding) detection
/// - Session frames for custom user flows
/// - Errors and custom metrics reporting
/// - Breadcrumbs for user interactions
/// - Timers for performance tracking
/// - Custom user data
/// - Device metrics reporting
///
/// ## Usage Example
///
/// ```dart
/// // Initialize AppDynamics
/// final config = AppDynamicsConfig(
///   appKey: 'YOUR_EUM_APP_KEY',
///   loggingLevel: AppDynamicsLoggingLevel.verbose,
/// );
///
/// final result = await appDynamics.initialize(config);
/// result.fold(
///   (failure) => print('Failed to initialize: $failure'),
///   (_) => print('AppDynamics initialized'),
/// );
///
/// // Track a custom event
/// await appDynamics.reportError(
///   'Custom error occurred',
///   stackTrace: StackTrace.current,
/// );
///
/// // Start a session frame
/// final frame = await appDynamics.startSessionFrame('checkout_process');
/// // ... perform operations ...
/// await appDynamics.endSessionFrame(frame);
/// ```
abstract class AppDynamicsService {
  /// Initializes the AppDynamics service.
  ///
  /// Must be called before any other methods. Configure the service with
  /// app key, logging level, and other settings via [config].
  ///
  /// Returns:
  /// - Right(void) - Initialization successful
  /// - Left(AppDynamicsFailure) - Initialization failed
  ///
  /// Example:
  /// ```dart
  /// final config = AppDynamicsConfig(
  ///   appKey: 'YOUR_EUM_APP_KEY',
  ///   loggingLevel: AppDynamicsLoggingLevel.verbose,
  /// );
  ///
  /// final result = await appDynamics.initialize(config);
  /// result.fold(
  ///   (failure) => print('Failed: $failure'),
  ///   (_) => print('Initialized'),
  /// );
  /// ```
  Future<Either<Failure, void>> initialize(AppDynamicsConfig config);

  /// Reports an error to AppDynamics.
  ///
  /// Use this to manually report errors, exceptions, or custom error messages.
  ///
  /// [message] - Error message or description
  /// [stackTrace] - Optional stack trace
  /// [severity] - Optional severity level (default: error)
  /// [properties] - Optional additional properties
  ///
  /// Returns:
  /// - Right(void) - Error reported successfully
  /// - Left(AppDynamicsFailure) - Failed to report error
  ///
  /// Example:
  /// ```dart
  /// await appDynamics.reportError(
  ///   'Failed to process payment',
  ///   stackTrace: StackTrace.current,
  ///   properties: {'order_id': '12345'},
  /// );
  /// ```
  Future<Either<Failure, void>> reportError(
    String message, {
    StackTrace? stackTrace,
    String? severity,
    Map<String, dynamic>? properties,
  });

  /// Reports a custom metric to AppDynamics.
  ///
  /// Use this to track custom business metrics or performance indicators.
  ///
  /// [name] - Metric name
  /// [value] - Metric value (numeric)
  /// [unit] - Optional unit of measurement
  /// [properties] - Optional additional properties
  ///
  /// Returns:
  /// - Right(void) - Metric reported successfully
  /// - Left(AppDynamicsFailure) - Failed to report metric
  ///
  /// Example:
  /// ```dart
  /// await appDynamics.reportMetric(
  ///   'checkout_duration',
  ///   1250.5,
  ///   unit: 'ms',
  ///   properties: {'payment_method': 'credit_card'},
  /// );
  /// ```
  Future<Either<Failure, void>> reportMetric(
    String name,
    double value, {
    String? unit,
    Map<String, dynamic>? properties,
  });

  /// Starts a session frame for tracking custom user flows.
  ///
  /// Session frames allow you to track multi-step processes like checkout,
  /// onboarding, or any custom user flow.
  ///
  /// [name] - Name of the session frame
  /// [properties] - Optional properties associated with the frame
  ///
  /// Returns:
  /// - Right(AppDynamicsSessionFrame) - Frame started successfully
  /// - Left(AppDynamicsFailure) - Failed to start frame
  ///
  /// Example:
  /// ```dart
  /// final frame = await appDynamics.startSessionFrame(
  ///   'checkout_process',
  ///   properties: {'user_id': '123'},
  /// );
  /// ```
  Future<Either<Failure, AppDynamicsSessionFrame>> startSessionFrame(
    String name, {
    Map<String, dynamic>? properties,
  });

  /// Ends a session frame.
  ///
  /// Call this when the user flow tracked by the frame is complete.
  ///
  /// [frame] - The session frame to end
  ///
  /// Returns:
  /// - Right(void) - Frame ended successfully
  /// - Left(AppDynamicsFailure) - Failed to end frame
  ///
  /// Example:
  /// ```dart
  /// await appDynamics.endSessionFrame(frame);
  /// ```
  Future<Either<Failure, void>> endSessionFrame(
    AppDynamicsSessionFrame frame,
  );

  /// Updates a session frame with new properties.
  ///
  /// Use this to add or update properties on an active session frame.
  ///
  /// [frame] - The session frame to update
  /// [properties] - Properties to add or update
  ///
  /// Returns:
  /// - Right(void) - Frame updated successfully
  /// - Left(AppDynamicsFailure) - Failed to update frame
  Future<Either<Failure, void>> updateSessionFrame(
    AppDynamicsSessionFrame frame,
    Map<String, dynamic> properties,
  );

  /// Leaves a breadcrumb for tracking user interactions.
  ///
  /// Breadcrumbs help track user interactions and UI events throughout
  /// the app session.
  ///
  /// [breadcrumb] - The breadcrumb to leave
  ///
  /// Returns:
  /// - Right(void) - Breadcrumb left successfully
  /// - Left(AppDynamicsFailure) - Failed to leave breadcrumb
  ///
  /// Example:
  /// ```dart
  /// await appDynamics.leaveBreadcrumb(
  ///   AppDynamicsBreadcrumb(
  ///     message: 'User clicked submit button',
  ///     level: AppDynamicsBreadcrumbLevel.info,
  ///     category: 'user_action',
  ///   ),
  /// );
  /// ```
  Future<Either<Failure, void>> leaveBreadcrumb(
    AppDynamicsBreadcrumb breadcrumb,
  );

  /// Starts a timer for tracking events that span multiple methods.
  ///
  /// Timers allow you to track the duration of operations that span across
  /// multiple methods or async operations.
  ///
  /// [name] - Name of the timer
  /// [properties] - Optional properties associated with the timer
  ///
  /// Returns:
  /// - Right(AppDynamicsTimer) - Timer started successfully
  /// - Left(AppDynamicsFailure) - Failed to start timer
  ///
  /// Example:
  /// ```dart
  /// final timer = await appDynamics.startTimer(
  ///   'data_processing',
  ///   properties: {'data_size': '1000'},
  /// );
  /// ```
  Future<Either<Failure, AppDynamicsTimer>> startTimer(
    String name, {
    Map<String, dynamic>? properties,
  });

  /// Stops a timer.
  ///
  /// Call this when the operation tracked by the timer is complete.
  ///
  /// [timer] - The timer to stop
  ///
  /// Returns:
  /// - Right(void) - Timer stopped successfully
  /// - Left(AppDynamicsFailure) - Failed to stop timer
  ///
  /// Example:
  /// ```dart
  /// await appDynamics.stopTimer(timer);
  /// ```
  Future<Either<Failure, void>> stopTimer(AppDynamicsTimer timer);

  /// Sets custom user data.
  ///
  /// Use this to associate custom data with the current user session.
  /// This data will be included in crash reports, network requests, etc.
  ///
  /// [key] - Data key
  /// [value] - Data value (must be JSON-serializable)
  ///
  /// Returns:
  /// - Right(void) - User data set successfully
  /// - Left(AppDynamicsFailure) - Failed to set user data
  ///
  /// Example:
  /// ```dart
  /// await appDynamics.setUserData('user_id', '12345');
  /// await appDynamics.setUserData('email', 'user@example.com');
  /// ```
  Future<Either<Failure, void>> setUserData(String key, dynamic value);

  /// Removes custom user data.
  ///
  /// [key] - Data key to remove
  ///
  /// Returns:
  /// - Right(void) - User data removed successfully
  /// - Left(AppDynamicsFailure) - Failed to remove user data
  Future<Either<Failure, void>> removeUserData(String key);

  /// Clears all custom user data.
  ///
  /// Returns:
  /// - Right(void) - User data cleared successfully
  /// - Left(AppDynamicsFailure) - Failed to clear user data
  Future<Either<Failure, void>> clearUserData();

  /// Sets custom data for network requests.
  ///
  /// Use this to add custom data that will be included with network requests.
  ///
  /// [key] - Data key
  /// [value] - Data value (must be JSON-serializable)
  ///
  /// Returns:
  /// - Right(void) - Network data set successfully
  /// - Left(AppDynamicsFailure) - Failed to set network data
  Future<Either<Failure, void>> setNetworkRequestData(
    String key,
    dynamic value,
  );

  /// Removes custom data for network requests.
  ///
  /// [key] - Data key to remove
  ///
  /// Returns:
  /// - Right(void) - Network data removed successfully
  /// - Left(AppDynamicsFailure) - Failed to remove network data
  Future<Either<Failure, void>> removeNetworkRequestData(String key);

  /// Clears all custom data for network requests.
  ///
  /// Returns:
  /// - Right(void) - Network data cleared successfully
  /// - Left(AppDynamicsFailure) - Failed to clear network data
  Future<Either<Failure, void>> clearNetworkRequestData();

  /// Sets custom data for crash reports.
  ///
  /// Use this to add custom data that will be included with crash reports.
  ///
  /// [key] - Data key
  /// [value] - Data value (must be JSON-serializable)
  ///
  /// Returns:
  /// - Right(void) - Crash data set successfully
  /// - Left(AppDynamicsFailure) - Failed to set crash data
  Future<Either<Failure, void>> setCrashReportData(
    String key,
    dynamic value,
  );

  /// Removes custom data for crash reports.
  ///
  /// [key] - Data key to remove
  ///
  /// Returns:
  /// - Right(void) - Crash data removed successfully
  /// - Left(AppDynamicsFailure) - Failed to remove crash data
  Future<Either<Failure, void>> removeCrashReportData(String key);

  /// Clears all custom data for crash reports.
  ///
  /// Returns:
  /// - Right(void) - Crash data cleared successfully
  /// - Left(AppDynamicsFailure) - Failed to clear crash data
  Future<Either<Failure, void>> clearCrashReportData();

  /// Marks a method execution as an info point.
  ///
  /// Info points help identify important methods in your code for monitoring.
  ///
  /// [name] - Name of the info point
  /// [properties] - Optional properties
  ///
  /// Returns:
  /// - Right(void) - Info point marked successfully
  /// - Left(AppDynamicsFailure) - Failed to mark info point
  Future<Either<Failure, void>> markInfoPoint(
    String name, {
    Map<String, dynamic>? properties,
  });

  /// Splits the current session into a new session.
  ///
  /// Use this to split app instrumentation into multiple sessions.
  ///
  /// Returns:
  /// - Right(void) - Session split successfully
  /// - Left(AppDynamicsFailure) - Failed to split session
  Future<Either<Failure, void>> splitSession();

  /// Disposes resources used by the AppDynamics service.
  ///
  /// Call this when the service is no longer needed to clean up resources.
  ///
  /// Returns:
  /// - Right(void) - Disposal successful
  /// - Left(AppDynamicsFailure) - Failed to dispose
  Future<Either<Failure, void>> dispose();
}

/// Abstract contract for logging service.
///
/// This interface provides a standardized way to log messages across
/// different logging implementations (logger package, console, Sentry, etc.).
///
/// **Dependency Independence**: This interface does NOT depend on any
/// specific logging package. Consumer apps can use any logging provider
/// by creating implementations of this interface.
///
/// Example usage:
/// ```dart
/// final logService = getIt<LogService>();
///
/// logService.debug('User tapped button');
/// logService.info('User logged in successfully');
/// logService.warning('API response is slow');
/// logService.error('Failed to fetch data', error: e, stackTrace: st);
/// logService.fatal('Critical error occurred', error: e, stackTrace: st);
/// ```
abstract class LogService {
  /// Log a trace message.
  ///
  /// Used for very detailed logging, typically only in development.
  /// This is the lowest log level.
  ///
  /// [message] - The log message
  /// [metadata] - Optional additional context data
  ///
  /// Example:
  /// ```dart
  /// logService.trace('Method entered', metadata: {'userId': '123'});
  /// ```
  void trace(String message, {Map<String, dynamic>? metadata});

  /// Log a debug message.
  ///
  /// Used for debugging information, typically only in development.
  ///
  /// [message] - The log message
  /// [metadata] - Optional additional context data
  ///
  /// Example:
  /// ```dart
  /// logService.debug('Button clicked', metadata: {'buttonId': 'submit'});
  /// ```
  void debug(String message, {Map<String, dynamic>? metadata});

  /// Log an informational message.
  ///
  /// Used for general informational messages about app state.
  ///
  /// [message] - The log message
  /// [metadata] - Optional additional context data
  ///
  /// Example:
  /// ```dart
  /// logService.info('User logged in', metadata: {'email': 'user@example.com'});
  /// ```
  void info(String message, {Map<String, dynamic>? metadata});

  /// Log a warning message.
  ///
  /// Used for potentially harmful situations that don't prevent
  /// the application from functioning.
  ///
  /// [message] - The log message
  /// [metadata] - Optional additional context data
  ///
  /// Example:
  /// ```dart
  /// logService.warning('API response slow', metadata: {'duration': '5s'});
  /// ```
  void warning(String message, {Map<String, dynamic>? metadata});

  /// Log an error message.
  ///
  /// Used for error events that might still allow the application
  /// to continue running.
  ///
  /// [message] - The log message
  /// [error] - Optional error object
  /// [stackTrace] - Optional stack trace
  /// [metadata] - Optional additional context data
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await api.fetchData();
  /// } catch (e, st) {
  ///   logService.error('Failed to fetch data', error: e, stackTrace: st);
  /// }
  /// ```
  void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  });

  /// Log a fatal error message.
  ///
  /// Used for very severe error events that might lead the application
  /// to abort. This is the highest log level.
  ///
  /// [message] - The log message
  /// [error] - The error object (required)
  /// [stackTrace] - The stack trace (required)
  /// [metadata] - Optional additional context data
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await criticalOperation();
  /// } catch (e, st) {
  ///   logService.fatal('Critical operation failed', error: e, stackTrace: st);
  /// }
  /// ```
  void fatal(
    String message, {
    required dynamic error,
    required StackTrace stackTrace,
    Map<String, dynamic>? metadata,
  });

  /// Close/dispose the logger.
  ///
  /// Call this when the logger is no longer needed to clean up resources.
  /// Useful for loggers that write to files or external services.
  void close();
}

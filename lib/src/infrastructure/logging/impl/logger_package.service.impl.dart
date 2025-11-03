import 'package:logger/logger.dart' as logger_pkg;

import '../contract/log.service.dart';

/// Implementation of [LogService] using the logger package.
///
/// This implementation wraps the popular logger package
/// (https://pub.dev/packages/logger) which provides beautiful,
/// colorful console logs.
///
/// **Dependency**: This class depends on the `logger` package.
/// To use this implementation, add to pubspec.yaml:
/// ```yaml
/// dependencies:
///   logger: ^2.6.2
/// ```
///
/// Example usage:
/// ```dart
/// // Register in DI container
/// getIt.registerLazySingleton<LogService>(
///   () => LoggerPackageServiceImpl(
///     logger: Logger(
///       printer: PrettyPrinter(
///         methodCount: 2,
///         errorMethodCount: 8,
///         lineLength: 120,
///         colors: true,
///         printEmojis: true,
///         dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
///       ),
///     ),
///   ),
/// );
/// ```
///
/// Or use the default configuration:
/// ```dart
/// getIt.registerLazySingleton<LogService>(
///   () => LoggerPackageServiceImpl.defaultConfig(),
/// );
/// ```
class LoggerPackageServiceImpl implements LogService {
  final logger_pkg.Logger _logger;

  /// Create logger service with custom logger instance.
  ///
  /// This allows full customization of the logger behavior.
  LoggerPackageServiceImpl({
    required logger_pkg.Logger logger,
  }) : _logger = logger;

  /// Create logger service with default pretty configuration.
  ///
  /// This provides a good default for most use cases with:
  /// - Pretty colored output
  /// - Emojis for log levels
  /// - 2 method calls shown
  /// - 8 method calls shown for errors
  factory LoggerPackageServiceImpl.defaultConfig() {
    return LoggerPackageServiceImpl(
      logger: logger_pkg.Logger(
        printer: logger_pkg.PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          dateTimeFormat: logger_pkg.DateTimeFormat.onlyTimeAndSinceStart,
        ),
      ),
    );
  }

  /// Create logger service with simple configuration (no colors, no emojis).
  ///
  /// Useful for CI/CD environments or when ANSI colors are not supported.
  factory LoggerPackageServiceImpl.simpleConfig() {
    return LoggerPackageServiceImpl(
      logger: logger_pkg.Logger(
        printer: logger_pkg.SimplePrinter(
          colors: false,
          printTime: true,
        ),
      ),
    );
  }

  /// Create logger service with custom filter and level.
  ///
  /// [level] - Minimum log level to show
  /// [filter] - Custom filter for log events
  factory LoggerPackageServiceImpl.withFilter({
    logger_pkg.Level level = logger_pkg.Level.debug,
    logger_pkg.LogFilter? filter,
  }) {
    return LoggerPackageServiceImpl(
      logger: logger_pkg.Logger(
        filter: filter ?? logger_pkg.DevelopmentFilter(),
        level: level,
        printer: logger_pkg.PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          dateTimeFormat: logger_pkg.DateTimeFormat.onlyTimeAndSinceStart,
        ),
      ),
    );
  }

  @override
  void trace(String message, {Map<String, dynamic>? metadata}) {
    if (metadata != null) {
      _logger.t('$message\nMetadata: $metadata');
    } else {
      _logger.t(message);
    }
  }

  @override
  void debug(String message, {Map<String, dynamic>? metadata}) {
    if (metadata != null) {
      _logger.d('$message\nMetadata: $metadata');
    } else {
      _logger.d(message);
    }
  }

  @override
  void info(String message, {Map<String, dynamic>? metadata}) {
    if (metadata != null) {
      _logger.i('$message\nMetadata: $metadata');
    } else {
      _logger.i(message);
    }
  }

  @override
  void warning(String message, {Map<String, dynamic>? metadata}) {
    if (metadata != null) {
      _logger.w('$message\nMetadata: $metadata');
    } else {
      _logger.w(message);
    }
  }

  @override
  void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    String fullMessage = message;
    if (metadata != null) {
      fullMessage += '\nMetadata: $metadata';
    }

    _logger.e(
      fullMessage,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void fatal(
    String message, {
    required dynamic error,
    required StackTrace stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    String fullMessage = message;
    if (metadata != null) {
      fullMessage += '\nMetadata: $metadata';
    }

    _logger.f(
      fullMessage,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void close() {
    _logger.close();
  }
}

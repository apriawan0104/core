import 'package:flutter/foundation.dart';

import '../contract/log.service.dart';

/// Simple console-based implementation of [LogService].
///
/// This implementation uses Flutter's `debugPrint` for logging.
/// It's a lightweight alternative that doesn't require any external packages.
///
/// **Use cases:**
/// - Testing and development
/// - When you want zero dependencies
/// - Fallback when logger package is not available
/// - Simple console output without fancy formatting
///
/// **Limitations:**
/// - No colored output
/// - No emojis
/// - Limited formatting
/// - Only logs in debug mode (when kDebugMode is true)
///
/// Example usage:
/// ```dart
/// // Register in DI container
/// getIt.registerLazySingleton<LogService>(
///   () => ConsoleLogServiceImpl(),
/// );
/// ```
///
/// Or with production mode logging enabled:
/// ```dart
/// getIt.registerLazySingleton<LogService>(
///   () => ConsoleLogServiceImpl(logInProduction: true),
/// );
/// ```
class ConsoleLogServiceImpl implements LogService {
  /// Whether to log in production mode.
  ///
  /// Default is false (only logs in debug mode).
  final bool logInProduction;

  /// Whether to include timestamps in log messages.
  final bool includeTimestamp;

  /// Create console log service.
  ///
  /// [logInProduction] - If true, logs even in production mode
  /// [includeTimestamp] - If true, includes timestamp in each log
  const ConsoleLogServiceImpl({
    this.logInProduction = false,
    this.includeTimestamp = true,
  });

  /// Check if logging should occur based on environment.
  bool get _shouldLog => kDebugMode || logInProduction;

  /// Get current timestamp string.
  String get _timestamp =>
      includeTimestamp ? '[${DateTime.now().toIso8601String()}] ' : '';

  /// Format metadata for display.
  String _formatMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null || metadata.isEmpty) return '';
    return '\n   Metadata: $metadata';
  }

  @override
  void trace(String message, {Map<String, dynamic>? metadata}) {
    if (!_shouldLog) return;
    debugPrint('$_timestamp🔍 TRACE: $message${_formatMetadata(metadata)}');
  }

  @override
  void debug(String message, {Map<String, dynamic>? metadata}) {
    if (!_shouldLog) return;
    debugPrint('$_timestamp🐛 DEBUG: $message${_formatMetadata(metadata)}');
  }

  @override
  void info(String message, {Map<String, dynamic>? metadata}) {
    if (!_shouldLog) return;
    debugPrint('$_timestampℹ️ INFO: $message${_formatMetadata(metadata)}');
  }

  @override
  void warning(String message, {Map<String, dynamic>? metadata}) {
    if (!_shouldLog) return;
    debugPrint('$_timestamp⚠️ WARNING: $message${_formatMetadata(metadata)}');
  }

  @override
  void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    if (!_shouldLog) return;

    final buffer = StringBuffer();
    buffer.write('$_timestamp❌ ERROR: $message');
    buffer.write(_formatMetadata(metadata));

    if (error != null) {
      buffer.write('\n   Error: $error');
    }

    if (stackTrace != null) {
      buffer.write('\n   StackTrace:\n$stackTrace');
    }

    debugPrint(buffer.toString());
  }

  @override
  void fatal(
    String message, {
    required dynamic error,
    required StackTrace stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    if (!_shouldLog) return;

    final buffer = StringBuffer();
    buffer.write('$_timestamp💀 FATAL: $message');
    buffer.write(_formatMetadata(metadata));
    buffer.write('\n   Error: $error');
    buffer.write('\n   StackTrace:\n$stackTrace');

    debugPrint(buffer.toString());
  }

  @override
  void close() {
    // No resources to clean up for console logging
  }
}

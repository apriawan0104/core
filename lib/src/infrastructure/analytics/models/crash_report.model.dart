/// Model representing a crash or error report.
///
/// This model encapsulates all information about a crash or error
/// that should be reported to the crash reporting service.
///
/// ## Usage Example
///
/// ```dart
/// // Simple error report
/// final report = CrashReport(
///   exception: Exception('Something went wrong'),
///   stackTrace: StackTrace.current,
/// );
///
/// // Detailed crash report
/// final detailedReport = CrashReport(
///   exception: exception,
///   stackTrace: stackTrace,
///   message: 'Payment processing failed',
///   fatal: true,
///   customData: {
///     'transaction_id': '123',
///     'amount': 99.99,
///     'user_id': 'user_123',
///   },
///   logs: [
///     'User initiated payment',
///     'Payment gateway responded with error',
///     'Retrying payment',
///   ],
///   timestamp: DateTime.now(),
/// );
///
/// // Report to crash service
/// await crashReporter.recordCrash(report);
/// ```
class CrashReport {
  /// The exception or error object.
  ///
  /// This can be any type (Exception, Error, String, etc.)
  final dynamic exception;

  /// Stack trace associated with the error.
  ///
  /// If available, this helps identify where the error occurred.
  final StackTrace? stackTrace;

  /// Human-readable message describing the error.
  ///
  /// Provides context about what the user was doing or what went wrong.
  final String? message;

  /// Whether this is a fatal error that crashed the app.
  ///
  /// - true: Fatal crash (app stopped)
  /// - false: Non-fatal error (app continued running)
  final bool fatal;

  /// Custom data to attach to the crash report.
  ///
  /// Use this to provide additional context for debugging:
  /// - User state
  /// - Transaction IDs
  /// - Feature flags
  /// - App configuration
  /// - Any other relevant data
  final Map<String, dynamic>? customData;

  /// Log messages leading up to the crash.
  ///
  /// Helps understand the sequence of events before the error occurred.
  final List<String>? logs;

  /// Timestamp when the error occurred.
  ///
  /// If not provided, the crash reporting service will use the current time.
  final DateTime? timestamp;

  const CrashReport({
    required this.exception,
    this.stackTrace,
    this.message,
    this.fatal = false,
    this.customData,
    this.logs,
    this.timestamp,
  });

  /// Creates a copy of this report with optional field updates.
  CrashReport copyWith({
    dynamic exception,
    StackTrace? stackTrace,
    String? message,
    bool? fatal,
    Map<String, dynamic>? customData,
    List<String>? logs,
    DateTime? timestamp,
  }) {
    return CrashReport(
      exception: exception ?? this.exception,
      stackTrace: stackTrace ?? this.stackTrace,
      message: message ?? this.message,
      fatal: fatal ?? this.fatal,
      customData: customData ?? this.customData,
      logs: logs ?? this.logs,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Converts this report to a map.
  Map<String, dynamic> toMap() {
    return {
      'exception': exception.toString(),
      if (stackTrace != null) 'stack_trace': stackTrace.toString(),
      if (message != null) 'message': message,
      'fatal': fatal,
      if (customData != null) 'custom_data': customData,
      if (logs != null) 'logs': logs,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  /// Creates a crash report from a map.
  factory CrashReport.fromMap(Map<String, dynamic> map) {
    return CrashReport(
      exception: map['exception'],
      stackTrace: map['stack_trace'] != null
          ? StackTrace.fromString(map['stack_trace'] as String)
          : null,
      message: map['message'] as String?,
      fatal: map['fatal'] as bool? ?? false,
      customData: map['custom_data'] as Map<String, dynamic>?,
      logs: map['logs'] != null ? List<String>.from(map['logs'] as List) : null,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : null,
    );
  }

  /// Creates a crash report from a caught exception.
  ///
  /// Convenience factory for creating reports from try-catch blocks.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await riskyOperation();
  /// } catch (e, stackTrace) {
  ///   final report = CrashReport.fromException(
  ///     exception: e,
  ///     stackTrace: stackTrace,
  ///     message: 'Failed to complete operation',
  ///   );
  ///   await crashReporter.recordCrash(report);
  /// }
  /// ```
  factory CrashReport.fromException({
    required dynamic exception,
    StackTrace? stackTrace,
    String? message,
    bool fatal = false,
    Map<String, dynamic>? customData,
  }) {
    return CrashReport(
      exception: exception,
      stackTrace: stackTrace,
      message: message,
      fatal: fatal,
      customData: customData,
      timestamp: DateTime.now(),
    );
  }

  /// Gets a summary of the crash report.
  String getSummary() {
    final buffer = StringBuffer();

    buffer.writeln('Crash Report:');
    buffer.writeln('  Fatal: $fatal');
    if (message != null) buffer.writeln('  Message: $message');
    buffer.writeln('  Exception: $exception');
    if (stackTrace != null) {
      buffer.writeln('  Stack Trace:');
      final stackLines = stackTrace.toString().split('\n').take(5);
      for (final line in stackLines) {
        buffer.writeln('    $line');
      }
    }
    if (customData != null && customData!.isNotEmpty) {
      buffer.writeln('  Custom Data:');
      customData!.forEach((key, value) {
        buffer.writeln('    $key: $value');
      });
    }
    if (logs != null && logs!.isNotEmpty) {
      buffer.writeln('  Recent Logs:');
      for (final log in logs!.take(3)) {
        buffer.writeln('    - $log');
      }
    }

    return buffer.toString();
  }

  @override
  String toString() {
    return 'CrashReport(exception: $exception, message: $message, fatal: $fatal, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CrashReport &&
        other.exception.toString() == exception.toString() &&
        other.stackTrace.toString() == stackTrace.toString() &&
        other.message == message &&
        other.fatal == fatal &&
        _mapsEqual(other.customData, customData) &&
        _listsEqual(other.logs, logs) &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return exception.hashCode ^
        stackTrace.hashCode ^
        message.hashCode ^
        fatal.hashCode ^
        customData.hashCode ^
        logs.hashCode ^
        timestamp.hashCode;
  }

  /// Helper method to compare maps for equality.
  bool _mapsEqual(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) {
        return false;
      }
    }

    return true;
  }

  /// Helper method to compare lists for equality.
  bool _listsEqual(List<String>? a, List<String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }
}

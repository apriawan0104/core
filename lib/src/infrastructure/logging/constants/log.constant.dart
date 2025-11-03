/// Constants for logging configuration and behavior.
class LogConstants {
  LogConstants._(); // Private constructor to prevent instantiation

  /// Default line length for pretty printer.
  static const int defaultLineLength = 120;

  /// Default number of method calls to show in stack trace.
  static const int defaultMethodCount = 2;

  /// Default number of method calls to show when error occurs.
  static const int defaultErrorMethodCount = 8;

  /// Default log level names for custom formatting.
  static const Map<String, String> logLevelNames = {
    'trace': 'TRACE',
    'debug': 'DEBUG',
    'info': 'INFO',
    'warning': 'WARNING',
    'error': 'ERROR',
    'fatal': 'FATAL',
  };

  /// Default log level emojis.
  static const Map<String, String> logLevelEmojis = {
    'trace': '🔍',
    'debug': '🐛',
    'info': 'ℹ️',
    'warning': '⚠️',
    'error': '❌',
    'fatal': '💀',
  };

  /// Common metadata keys for structured logging.
  static const String keyUserId = 'userId';
  static const String keyUserEmail = 'userEmail';
  static const String keyScreenName = 'screenName';
  static const String keyAction = 'action';
  static const String keyDuration = 'duration';
  static const String keyStatusCode = 'statusCode';
  static const String keyEndpoint = 'endpoint';
  static const String keyMethod = 'method';
  static const String keyErrorCode = 'errorCode';
  static const String keyErrorType = 'errorType';
  static const String keyTimestamp = 'timestamp';
  static const String keyAppVersion = 'appVersion';
  static const String keyPlatform = 'platform';
  static const String keyDeviceModel = 'deviceModel';
}

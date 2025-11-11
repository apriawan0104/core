/// HTTP Inspector constants
class HttpInspectorConstants {
  HttpInspectorConstants._();

  /// Default notification title for HTTP requests
  static const String defaultNotificationTitle = 'HTTP Inspector';

  /// Default maximum content length to display
  static const int defaultMaxContentLength = 250000;

  /// Default timeout duration for requests
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Storage key for inspector settings
  static const String settingsStorageKey = 'http_inspector_settings';

  /// Storage key for inspector data
  static const String dataStorageKey = 'http_inspector_data';

  /// Maximum number of requests to store
  static const int maxRequestsToStore = 100;

  /// Default headers to hide (for security)
  static const List<String> defaultHeadersToHide = [
    'authorization',
    'cookie',
    'set-cookie',
    'api-key',
    'x-api-key',
    'access-token',
    'refresh-token',
  ];

  /// Content types that support preview
  static const List<String> previewableContentTypes = [
    'application/json',
    'application/xml',
    'text/plain',
    'text/html',
    'text/xml',
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
  ];

  /// Success status code range
  static const int successStatusCodeMin = 200;
  static const int successStatusCodeMax = 299;

  /// Client error status code range
  static const int clientErrorStatusCodeMin = 400;
  static const int clientErrorStatusCodeMax = 499;

  /// Server error status code range
  static const int serverErrorStatusCodeMin = 500;
  static const int serverErrorStatusCodeMax = 599;
}

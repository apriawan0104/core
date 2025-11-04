/// Represents a web resource error
class WebViewResourceError {
  /// Error code
  final int errorCode;

  /// Error description
  final String description;

  /// URL that failed to load
  final String? failingUrl;

  /// Whether this error is for the main frame
  final bool isForMainFrame;

  const WebViewResourceError({
    required this.errorCode,
    required this.description,
    this.failingUrl,
    required this.isForMainFrame,
  });
}

/// Represents an HTTP error response
class WebViewHttpError {
  /// HTTP status code
  final int statusCode;

  /// URL that returned the error
  final String? url;

  const WebViewHttpError({
    required this.statusCode,
    this.url,
  });
}


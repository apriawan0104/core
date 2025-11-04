/// Represents a web request to be loaded in the WebView
class WebViewRequest {
  /// The URI to load
  final Uri uri;

  /// HTTP method (GET, POST, etc.)
  final String method;

  /// HTTP headers
  final Map<String, String>? headers;

  /// Request body (for POST requests)
  final List<int>? body;

  const WebViewRequest({
    required this.uri,
    this.method = 'GET',
    this.headers,
    this.body,
  });

  /// Create a GET request
  factory WebViewRequest.get(
    Uri uri, {
    Map<String, String>? headers,
  }) {
    return WebViewRequest(
      uri: uri,
      method: 'GET',
      headers: headers,
    );
  }

  /// Create a POST request
  factory WebViewRequest.post(
    Uri uri, {
    Map<String, String>? headers,
    List<int>? body,
  }) {
    return WebViewRequest(
      uri: uri,
      method: 'POST',
      headers: headers,
      body: body,
    );
  }
}


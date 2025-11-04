/// Configuration for connectivity check endpoint
///
/// Defines a custom endpoint to check for internet connectivity.
/// This entity is independent of any specific connectivity checker implementation.
class ConnectivityCheckOptionEntity {
  /// The URI to check for connectivity
  final Uri uri;

  /// Custom headers for the request
  final Map<String, String>? headers;

  /// Request timeout duration
  final Duration timeout;

  /// Function to determine if response indicates success
  ///
  /// By default, checks if status code is 200.
  /// You can customize this to check for different status codes or response patterns.
  ///
  /// Example:
  /// ```dart
  /// responseStatusFn: (statusCode, headers, body) {
  ///   return statusCode >= 200 && statusCode < 300;
  /// }
  /// ```
  final bool Function(int statusCode, Map<String, String> headers, String body)?
      responseStatusFn;

  const ConnectivityCheckOptionEntity({
    required this.uri,
    this.headers,
    this.timeout = const Duration(seconds: 10),
    this.responseStatusFn,
  });

  /// Create a copy with modified fields
  ConnectivityCheckOptionEntity copyWith({
    Uri? uri,
    Map<String, String>? headers,
    Duration? timeout,
    bool Function(int statusCode, Map<String, String> headers, String body)?
        responseStatusFn,
  }) {
    return ConnectivityCheckOptionEntity(
      uri: uri ?? this.uri,
      headers: headers ?? this.headers,
      timeout: timeout ?? this.timeout,
      responseStatusFn: responseStatusFn ?? this.responseStatusFn,
    );
  }

  /// Default connectivity check options
  ///
  /// Uses common, reliable endpoints for connectivity checking
  static List<ConnectivityCheckOptionEntity> get defaultOptions => [
        ConnectivityCheckOptionEntity(
          uri: Uri.parse('https://www.google.com'),
          timeout: const Duration(seconds: 10),
        ),
        ConnectivityCheckOptionEntity(
          uri: Uri.parse('https://www.cloudflare.com'),
          timeout: const Duration(seconds: 10),
        ),
        ConnectivityCheckOptionEntity(
          uri: Uri.parse('https://www.apple.com'),
          timeout: const Duration(seconds: 10),
        ),
      ];

  @override
  String toString() {
    return 'ConnectivityCheckOptionEntity(uri: $uri, timeout: $timeout)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConnectivityCheckOptionEntity &&
        other.uri == uri &&
        other.timeout == timeout;
  }

  @override
  int get hashCode => uri.hashCode ^ timeout.hashCode;
}


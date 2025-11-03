import 'http_method.entity.dart';

/// HTTP request options
/// 
/// Generic request configuration that works with any HTTP client.
class RequestOptionsEntity {
  /// Request URL
  final String url;

  /// HTTP method
  final HttpMethod method;

  /// Request headers
  final Map<String, dynamic>? headers;

  /// Query parameters
  final Map<String, dynamic>? queryParameters;

  /// Request body/data
  final dynamic data;

  /// Connection timeout in milliseconds
  final int? connectTimeout;

  /// Receive timeout in milliseconds
  final int? receiveTimeout;

  /// Send timeout in milliseconds
  final int? sendTimeout;

  /// Whether to follow redirects
  final bool followRedirects;

  /// Max number of redirects to follow
  final int maxRedirects;

  /// Response type expected (json, stream, plain, bytes)
  final ResponseType responseType;

  /// Extra custom options (can be used by specific implementations)
  final Map<String, dynamic>? extra;

  const RequestOptionsEntity({
    required this.url,
    required this.method,
    this.headers,
    this.queryParameters,
    this.data,
    this.connectTimeout,
    this.receiveTimeout,
    this.sendTimeout,
    this.followRedirects = true,
    this.maxRedirects = 5,
    this.responseType = ResponseType.json,
    this.extra,
  });

  /// Create a copy with updated fields
  RequestOptionsEntity copyWith({
    String? url,
    HttpMethod? method,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    int? connectTimeout,
    int? receiveTimeout,
    int? sendTimeout,
    bool? followRedirects,
    int? maxRedirects,
    ResponseType? responseType,
    Map<String, dynamic>? extra,
  }) {
    return RequestOptionsEntity(
      url: url ?? this.url,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      queryParameters: queryParameters ?? this.queryParameters,
      data: data ?? this.data,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      followRedirects: followRedirects ?? this.followRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
      responseType: responseType ?? this.responseType,
      extra: extra ?? this.extra,
    );
  }

  @override
  String toString() {
    return 'RequestOptionsEntity(method: $method, url: $url)';
  }
}

/// Expected response type
enum ResponseType {
  /// JSON response (default)
  json,

  /// Stream response
  stream,

  /// Plain text response
  plain,

  /// Binary/bytes response
  bytes;
}


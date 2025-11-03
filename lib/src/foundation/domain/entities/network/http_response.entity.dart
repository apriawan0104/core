/// Generic HTTP response entity
/// 
/// This entity is independent of any HTTP client implementation.
/// It can be used with Dio, http, Chopper, or any other HTTP client.
class HttpResponseEntity<T> {
  /// Response data
  final T? data;

  /// HTTP status code
  final int statusCode;

  /// Response headers
  final Map<String, dynamic> headers;

  /// Status message (e.g., "OK", "Not Found")
  final String? statusMessage;

  /// Whether the request was successful (status code 2xx)
  bool get isSuccessful => statusCode >= 200 && statusCode < 300;

  const HttpResponseEntity({
    this.data,
    required this.statusCode,
    this.headers = const {},
    this.statusMessage,
  });

  /// Create response from map
  factory HttpResponseEntity.fromMap(Map<String, dynamic> map) {
    return HttpResponseEntity(
      data: map['data'] as T?,
      statusCode: map['statusCode'] as int? ?? 0,
      headers: Map<String, dynamic>.from(map['headers'] as Map? ?? {}),
      statusMessage: map['statusMessage'] as String?,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'statusCode': statusCode,
      'headers': headers,
      'statusMessage': statusMessage,
    };
  }

  @override
  String toString() {
    return 'HttpResponseEntity(statusCode: $statusCode, statusMessage: $statusMessage, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HttpResponseEntity<T> &&
        other.data == data &&
        other.statusCode == statusCode &&
        other.statusMessage == statusMessage;
  }

  @override
  int get hashCode {
    return data.hashCode ^ statusCode.hashCode ^ statusMessage.hashCode;
  }
}


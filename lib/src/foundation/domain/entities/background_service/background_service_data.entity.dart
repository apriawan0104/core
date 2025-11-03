/// Data to be sent/received between UI and background service
class BackgroundServiceData {
  /// Method name for the data
  final String method;

  /// Payload data
  final Map<String, dynamic>? payload;

  const BackgroundServiceData({
    required this.method,
    this.payload,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'method': method,
      if (payload != null) 'payload': payload,
    };
  }

  /// Create from JSON
  factory BackgroundServiceData.fromJson(Map<String, dynamic> json) {
    return BackgroundServiceData(
      method: json['method'] as String,
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }

  BackgroundServiceData copyWith({
    String? method,
    Map<String, dynamic>? payload,
  }) {
    return BackgroundServiceData(
      method: method ?? this.method,
      payload: payload ?? this.payload,
    );
  }

  @override
  String toString() {
    return 'BackgroundServiceData(method: $method, payload: $payload)';
  }
}


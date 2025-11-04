/// JavaScript execution mode
enum WebViewJavaScriptMode {
  /// JavaScript execution is disabled
  disabled,

  /// JavaScript execution is enabled without restrictions
  unrestricted,
}

/// Represents a JavaScript channel for communication between Dart and JavaScript
class WebViewJavaScriptChannel {
  /// Name of the channel
  final String name;

  /// Callback when a message is received from JavaScript
  final void Function(String message) onMessageReceived;

  const WebViewJavaScriptChannel({
    required this.name,
    required this.onMessageReceived,
  });
}

/// Result of JavaScript execution
class WebViewJavaScriptResult {
  /// The result value (can be String, num, bool, Map, List, or null)
  final Object? value;

  const WebViewJavaScriptResult(this.value);

  /// Check if result is a string
  bool get isString => value is String;

  /// Check if result is a number
  bool get isNumber => value is num;

  /// Check if result is a boolean
  bool get isBool => value is bool;

  /// Check if result is a map
  bool get isMap => value is Map;

  /// Check if result is a list
  bool get isList => value is List;

  /// Check if result is null
  bool get isNull => value == null;

  /// Get result as string
  String? asString() => value as String?;

  /// Get result as number
  num? asNumber() => value as num?;

  /// Get result as boolean
  bool? asBool() => value as bool?;

  /// Get result as map
  Map<dynamic, dynamic>? asMap() => value as Map?;

  /// Get result as list
  List<dynamic>? asList() => value as List?;
}


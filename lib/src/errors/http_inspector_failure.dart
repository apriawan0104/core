import 'failures.dart';

/// Base failure for HTTP Inspector operations
class HttpInspectorFailure extends Failure {
  /// Stack trace for debugging
  final StackTrace? stackTrace;

  const HttpInspectorFailure(
    String message, {
    this.stackTrace,
    super.code,
    super.details,
  }) : super(
          message: message,
        );
}

/// Failure when HTTP Inspector initialization fails
class HttpInspectorInitializationFailure extends HttpInspectorFailure {
  const HttpInspectorInitializationFailure(
    super.message, {
    super.stackTrace,
    super.code,
    super.details,
  });
}

/// Failure when getting interceptor fails
class HttpInspectorInterceptorFailure extends HttpInspectorFailure {
  const HttpInspectorInterceptorFailure(
    super.message, {
    super.stackTrace,
    super.code,
    super.details,
  });
}

/// Failure when configuration update fails
class HttpInspectorConfigFailure extends HttpInspectorFailure {
  const HttpInspectorConfigFailure(
    super.message, {
    super.stackTrace,
    super.code,
    super.details,
  });
}

/// Failure when data clearing fails
class HttpInspectorClearDataFailure extends HttpInspectorFailure {
  const HttpInspectorClearDataFailure(
    super.message, {
    super.stackTrace,
    super.code,
    super.details,
  });
}

/// Failure when inspector state change fails
class HttpInspectorStateFailure extends HttpInspectorFailure {
  const HttpInspectorStateFailure(
    super.message, {
    super.stackTrace,
    super.code,
    super.details,
  });
}

/// Failure when showing inspector UI fails
class HttpInspectorUIFailure extends HttpInspectorFailure {
  const HttpInspectorUIFailure(
    super.message, {
    super.stackTrace,
    super.code,
    super.details,
  });
}

/// Failure when HTTP client wrapping fails
class HttpInspectorClientFailure extends HttpInspectorFailure {
  const HttpInspectorClientFailure(
    super.message, {
    super.stackTrace,
    super.code,
    super.details,
  });
}

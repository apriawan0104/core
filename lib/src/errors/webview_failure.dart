import 'package:app_core/src/errors/failures.dart';

/// Base class for all webview-related failures
abstract class WebViewFailure extends Failure {
  const WebViewFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Failure when webview initialization fails
class WebViewInitializationFailure extends WebViewFailure {
  const WebViewInitializationFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Failure when loading a URL or request fails
class WebViewLoadFailure extends WebViewFailure {
  const WebViewLoadFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Failure when executing JavaScript fails
class WebViewJavaScriptFailure extends WebViewFailure {
  const WebViewJavaScriptFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Failure when navigation is blocked or fails
class WebViewNavigationFailure extends WebViewFailure {
  const WebViewNavigationFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Failure when cookie operations fail
class WebViewCookieFailure extends WebViewFailure {
  const WebViewCookieFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Failure when cache operations fail
class WebViewCacheFailure extends WebViewFailure {
  const WebViewCacheFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Failure when clearing data fails
class WebViewClearDataFailure extends WebViewFailure {
  const WebViewClearDataFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Failure when webview configuration fails
class WebViewConfigurationFailure extends WebViewFailure {
  const WebViewConfigurationFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Failure when webview platform is not supported
class WebViewPlatformNotSupportedFailure extends WebViewFailure {
  const WebViewPlatformNotSupportedFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Failure when a webview resource error occurs
class WebViewResourceFailure extends WebViewFailure {
  final int? errorCode;
  final String? url;

  const WebViewResourceFailure(
    String message, {
    this.errorCode,
    this.url,
    super.code,
    super.details,
  }) : super(message: message);
}

/// Failure when HTTP error occurs in webview
class WebViewHttpFailure extends WebViewFailure {
  final int statusCode;
  final String? url;

  const WebViewHttpFailure(
    String message, {
    required this.statusCode,
    this.url,
    super.code,
    super.details,
  }) : super(message: message);
}

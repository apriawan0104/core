/// Configuration for WebView initialization
class WebViewConfig {
  /// Enable or disable JavaScript execution
  final bool javaScriptEnabled;

  /// Enable or disable zoom controls
  final bool zoomEnabled;

  /// User agent string to use
  final String? userAgent;

  /// Background color of the webview
  final int? backgroundColor;

  /// Enable or disable debugging (Android)
  final bool debuggingEnabled;

  /// Allow inline media playback (iOS)
  final bool allowsInlineMediaPlayback;

  /// Media types requiring user action (iOS)
  final Set<String>? mediaTypesRequiringUserAction;

  /// Enable gesture navigation (iOS)
  final bool gestureNavigationEnabled;

  /// Custom headers to include in requests
  final Map<String, String>? customHeaders;

  /// Enable or disable local storage
  final bool localStorageEnabled;

  /// Enable or disable DOM storage
  final bool domStorageEnabled;

  /// Enable or disable cache
  final bool cacheEnabled;

  /// Custom initial cookies
  final List<WebViewCookieData>? initialCookies;

  const WebViewConfig({
    this.javaScriptEnabled = true,
    this.zoomEnabled = true,
    this.userAgent,
    this.backgroundColor,
    this.debuggingEnabled = false,
    this.allowsInlineMediaPlayback = false,
    this.mediaTypesRequiringUserAction,
    this.gestureNavigationEnabled = true,
    this.customHeaders,
    this.localStorageEnabled = true,
    this.domStorageEnabled = true,
    this.cacheEnabled = true,
    this.initialCookies,
  });

  WebViewConfig copyWith({
    bool? javaScriptEnabled,
    bool? zoomEnabled,
    String? userAgent,
    int? backgroundColor,
    bool? debuggingEnabled,
    bool? allowsInlineMediaPlayback,
    Set<String>? mediaTypesRequiringUserAction,
    bool? gestureNavigationEnabled,
    Map<String, String>? customHeaders,
    bool? localStorageEnabled,
    bool? domStorageEnabled,
    bool? cacheEnabled,
    List<WebViewCookieData>? initialCookies,
  }) {
    return WebViewConfig(
      javaScriptEnabled: javaScriptEnabled ?? this.javaScriptEnabled,
      zoomEnabled: zoomEnabled ?? this.zoomEnabled,
      userAgent: userAgent ?? this.userAgent,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      debuggingEnabled: debuggingEnabled ?? this.debuggingEnabled,
      allowsInlineMediaPlayback:
          allowsInlineMediaPlayback ?? this.allowsInlineMediaPlayback,
      mediaTypesRequiringUserAction:
          mediaTypesRequiringUserAction ?? this.mediaTypesRequiringUserAction,
      gestureNavigationEnabled:
          gestureNavigationEnabled ?? this.gestureNavigationEnabled,
      customHeaders: customHeaders ?? this.customHeaders,
      localStorageEnabled: localStorageEnabled ?? this.localStorageEnabled,
      domStorageEnabled: domStorageEnabled ?? this.domStorageEnabled,
      cacheEnabled: cacheEnabled ?? this.cacheEnabled,
      initialCookies: initialCookies ?? this.initialCookies,
    );
  }
}

/// Cookie data for WebView
class WebViewCookieData {
  final String name;
  final String value;
  final String domain;
  final String path;
  final DateTime? expiresDate;
  final bool isSecure;
  final bool isHttpOnly;

  const WebViewCookieData({
    required this.name,
    required this.value,
    required this.domain,
    this.path = '/',
    this.expiresDate,
    this.isSecure = false,
    this.isHttpOnly = false,
  });
}


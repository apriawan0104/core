/// Constants for WebView service
class WebViewConstants {
  WebViewConstants._();

  /// Default user agent prefix
  static const String defaultUserAgentPrefix = 'BUMACore';

  /// Default background color (white)
  static const int defaultBackgroundColor = 0xFFFFFFFF;

  /// Default timeout for operations (in seconds)
  static const int defaultTimeoutSeconds = 30;

  /// JavaScript channel names
  static const String defaultJavaScriptChannelName = 'BUMAChannel';

  /// Cookie path
  static const String defaultCookiePath = '/';

  /// Error messages
  static const String errorNotInitialized = 'WebView has not been initialized';
  static const String errorInvalidUrl = 'Invalid URL provided';
  static const String errorJavaScriptDisabled = 'JavaScript is disabled';
  static const String errorNavigationFailed = 'Navigation failed';
  static const String errorCookieOperationFailed = 'Cookie operation failed';
  static const String errorCacheOperationFailed = 'Cache operation failed';
  static const String errorPlatformNotSupported = 'Platform not supported';
  static const String errorControllerNotAvailable =
      'WebView controller is not available';

  /// Platform-specific constants
  static const String platformAndroid = 'android';
  static const String platformIOS = 'ios';
  static const String platformMacOS = 'macos';
  static const String platformWeb = 'web';

  /// Media playback types (iOS)
  static const String mediaTypeAudio = 'audio';
  static const String mediaTypeVideo = 'video';
  static const String mediaTypeAll = 'all';

  /// HTTP methods
  static const String methodGet = 'GET';
  static const String methodPost = 'POST';
  static const String methodPut = 'PUT';
  static const String methodDelete = 'DELETE';
  static const String methodPatch = 'PATCH';

  /// Common headers
  static const String headerUserAgent = 'User-Agent';
  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
  static const String headerAccept = 'Accept';

  /// Content types
  static const String contentTypeJson = 'application/json';
  static const String contentTypeFormUrlEncoded =
      'application/x-www-form-urlencoded';
  static const String contentTypeFormData = 'multipart/form-data';
  static const String contentTypeHtml = 'text/html';

  /// URL schemes
  static const String schemeHttp = 'http';
  static const String schemeHttps = 'https';
  static const String schemeFile = 'file';
  static const String schemeData = 'data';
  static const String schemeAbout = 'about';

  /// Special URLs
  static const String urlAboutBlank = 'about:blank';

  /// Progress values
  static const int progressMin = 0;
  static const int progressMax = 100;

  /// Scroll positions
  static const int scrollTop = 0;
  static const int scrollLeft = 0;
}

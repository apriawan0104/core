import 'package:app_core/src/errors/webview_failure.dart';
import 'package:app_core/src/infrastructure/webview/models/models.dart';
import 'package:dartz/dartz.dart';

/// Abstract interface for WebView operations
///
/// This service provides a generic interface for webview functionality
/// that is independent of any specific webview implementation.
///
/// Implementation can use any webview package (webview_flutter, flutter_inappwebview, etc.)
/// without affecting consumer code.
///
/// Example usage:
/// ```dart
/// final webViewService = getIt<WebViewService>();
///
/// // Configure webview
/// final config = WebViewConfig(
///   javaScriptEnabled: true,
///   zoomEnabled: true,
/// );
///
/// final result = await webViewService.initialize(config);
/// result.fold(
///   (failure) => print('Failed: ${failure.message}'),
///   (_) => print('Initialized successfully'),
/// );
/// ```
abstract class WebViewService {
  /// Initialize the webview with configuration
  ///
  /// This should be called before using any other webview functionality.
  ///
  /// [config] - Configuration for the webview
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> initialize(WebViewConfig config);

  /// Load a URL in the webview
  ///
  /// [url] - The URL to load
  /// [headers] - Optional headers to include in the request
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> loadUrl(
    String url, {
    Map<String, String>? headers,
  });

  /// Load a request in the webview
  ///
  /// [request] - The request to load
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> loadRequest(WebViewRequest request);

  /// Load HTML string directly
  ///
  /// [html] - The HTML content to load
  /// [baseUrl] - Optional base URL for resolving relative URLs
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> loadHtmlString(
    String html, {
    String? baseUrl,
  });

  /// Execute JavaScript code in the webview
  ///
  /// [javascript] - The JavaScript code to execute
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> runJavaScript(String javascript);

  /// Execute JavaScript and return the result
  ///
  /// [javascript] - The JavaScript code to execute
  ///
  /// Returns [Either] containing [WebViewFailure] on error or [WebViewJavaScriptResult] on success
  Future<Either<WebViewFailure, WebViewJavaScriptResult>>
      runJavaScriptReturningResult(String javascript);

  /// Get the current URL
  ///
  /// Returns [Either] containing [WebViewFailure] on error or URL string on success
  Future<Either<WebViewFailure, String?>> currentUrl();

  /// Get the page title
  ///
  /// Returns [Either] containing [WebViewFailure] on error or title string on success
  Future<Either<WebViewFailure, String?>> getTitle();

  /// Check if webview can go back in history
  ///
  /// Returns [Either] containing [WebViewFailure] on error or boolean on success
  Future<Either<WebViewFailure, bool>> canGoBack();

  /// Check if webview can go forward in history
  ///
  /// Returns [Either] containing [WebViewFailure] on error or boolean on success
  Future<Either<WebViewFailure, bool>> canGoForward();

  /// Go back in navigation history
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> goBack();

  /// Go forward in navigation history
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> goForward();

  /// Reload the current page
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> reload();

  /// Clear the webview cache
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> clearCache();

  /// Clear local storage
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> clearLocalStorage();

  /// Set JavaScript mode
  ///
  /// [mode] - The JavaScript mode to set
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> setJavaScriptMode(
    WebViewJavaScriptMode mode,
  );

  /// Set user agent string
  ///
  /// [userAgent] - The user agent string to use
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> setUserAgent(String? userAgent);

  /// Set background color
  ///
  /// [color] - The background color (as int, e.g., 0xFFFFFFFF for white)
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> setBackgroundColor(int color);

  /// Enable or disable zoom
  ///
  /// [enabled] - Whether zoom should be enabled
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> enableZoom(bool enabled);

  /// Add a JavaScript channel for communication
  ///
  /// [channel] - The JavaScript channel to add
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> addJavaScriptChannel(
    WebViewJavaScriptChannel channel,
  );

  /// Remove a JavaScript channel
  ///
  /// [name] - Name of the channel to remove
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> removeJavaScriptChannel(String name);

  /// Set navigation delegate for handling navigation events
  ///
  /// [onNavigationRequest] - Callback for navigation requests
  /// [onPageStarted] - Callback when page starts loading
  /// [onPageFinished] - Callback when page finishes loading
  /// [onProgress] - Callback for loading progress
  /// [onWebResourceError] - Callback for web resource errors
  /// [onHttpError] - Callback for HTTP errors
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> setNavigationDelegate({
    WebViewNavigationDecision Function(WebViewNavigationRequest request)?
        onNavigationRequest,
    void Function(String url)? onPageStarted,
    void Function(String url)? onPageFinished,
    void Function(int progress)? onProgress,
    void Function(WebViewResourceError error)? onWebResourceError,
    void Function(WebViewHttpError error)? onHttpError,
  });

  /// Get scroll position
  ///
  /// Returns [Either] containing [WebViewFailure] on error or scroll position (x, y) on success
  Future<Either<WebViewFailure, (int x, int y)>> getScrollPosition();

  /// Scroll to position
  ///
  /// [x] - Horizontal scroll position
  /// [y] - Vertical scroll position
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> scrollTo(int x, int y);

  /// Scroll by offset
  ///
  /// [x] - Horizontal scroll offset
  /// [y] - Vertical scroll offset
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> scrollBy(int x, int y);
}

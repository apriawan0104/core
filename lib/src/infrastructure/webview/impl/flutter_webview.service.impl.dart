import 'dart:ui';

import 'package:app_core/src/errors/webview_failure.dart';
import 'package:app_core/src/infrastructure/webview/constants/constants.dart';
import 'package:app_core/src/infrastructure/webview/contract/contracts.dart';
import 'package:app_core/src/infrastructure/webview/models/models.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Implementation of [WebViewService] using webview_flutter package
///
/// This implementation wraps the webview_flutter package to provide
/// a generic interface that is independent of the specific webview implementation.
///
/// Supports Android (API 21+), iOS (12.0+), and macOS (10.14+)
class FlutterWebViewServiceImpl implements WebViewService {
  WebViewController? _controller;
  final Map<String, WebViewJavaScriptChannel> _javaScriptChannels = {};
  bool _isInitialized = false;

  /// Get the underlying WebViewController
  ///
  /// This is exposed for use with WebViewWidget
  WebViewController? get controller => _controller;

  @override
  Future<Either<WebViewFailure, void>> initialize(WebViewConfig config) async {
    try {
      // Platform-specific parameters
      late final PlatformWebViewControllerCreationParams params;

      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        // iOS/macOS specific configuration
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: config.allowsInlineMediaPlayback,
          mediaTypesRequiringUserAction: _convertMediaTypesRequiringUserAction(
            config.mediaTypesRequiringUserAction,
          ),
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      // Create controller
      _controller = WebViewController.fromPlatformCreationParams(params);

      // Configure controller
      await _controller!.setJavaScriptMode(
        config.javaScriptEnabled
            ? JavaScriptMode.unrestricted
            : JavaScriptMode.disabled,
      );

      await _controller!.enableZoom(config.zoomEnabled);

      if (config.userAgent != null) {
        await _controller!.setUserAgent(config.userAgent);
      }

      if (config.backgroundColor != null) {
        await _controller!.setBackgroundColor(
          Color(config.backgroundColor!),
        );
      }

      // Android-specific configuration
      if (_controller!.platform is AndroidWebViewController) {
        final androidController =
            _controller!.platform as AndroidWebViewController;

        if (config.debuggingEnabled) {
          AndroidWebViewController.enableDebugging(true);
        }

        await androidController.setMediaPlaybackRequiresUserGesture(false);

        // Enable DOM storage if configured
        if (config.domStorageEnabled) {
          // This is enabled by default in webview_flutter
        }
      }

      // iOS/macOS-specific configuration
      if (_controller!.platform is WebKitWebViewController) {
        final webKitController =
            _controller!.platform as WebKitWebViewController;

        await webKitController.setAllowsBackForwardNavigationGestures(
          config.gestureNavigationEnabled,
        );
      }

      // Set initial cookies if provided
      if (config.initialCookies != null && config.initialCookies!.isNotEmpty) {
        final cookieManager = WebViewCookieManager();
        for (final cookie in config.initialCookies!) {
          await cookieManager.setCookie(
            WebViewCookie(
              name: cookie.name,
              value: cookie.value,
              domain: cookie.domain,
              path: cookie.path,
            ),
          );
        }
      }

      _isInitialized = true;
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewInitializationFailure(
          'Failed to initialize WebView: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> loadUrl(
    String url, {
    Map<String, String>? headers,
  }) async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewLoadFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      await _controller!.loadRequest(
        Uri.parse(url),
        headers: headers ?? {},
      );
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewLoadFailure(
          'Failed to load URL: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> loadRequest(
    WebViewRequest request,
  ) async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewLoadFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      await _controller!.loadRequest(
        request.uri,
        method: _convertLoadRequestMethod(request.method),
        headers: request.headers ?? {},
        body: request.body != null ? Uint8List.fromList(request.body!) : null,
      );
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewLoadFailure(
          'Failed to load request: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> loadHtmlString(
    String html, {
    String? baseUrl,
  }) async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewLoadFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      await _controller!.loadHtmlString(html, baseUrl: baseUrl);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewLoadFailure(
          'Failed to load HTML string: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> runJavaScript(String javascript) async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewJavaScriptFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      await _controller!.runJavaScript(javascript);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewJavaScriptFailure(
          'Failed to run JavaScript: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, WebViewJavaScriptResult>>
      runJavaScriptReturningResult(String javascript) async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewJavaScriptFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      final result = await _controller!.runJavaScriptReturningResult(
        javascript,
      );
      return Right(WebViewJavaScriptResult(result));
    } catch (e, stackTrace) {
      return Left(
        WebViewJavaScriptFailure(
          'Failed to run JavaScript: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, String?>> currentUrl() async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewConfigurationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      final url = await _controller!.currentUrl();
      return Right(url);
    } catch (e, stackTrace) {
      return Left(
        WebViewConfigurationFailure(
          'Failed to get current URL: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, String?>> getTitle() async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewConfigurationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      final title = await _controller!.getTitle();
      return Right(title);
    } catch (e, stackTrace) {
      return Left(
        WebViewConfigurationFailure(
          'Failed to get title: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, bool>> canGoBack() async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewConfigurationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      final canGoBack = await _controller!.canGoBack();
      return Right(canGoBack);
    } catch (e, stackTrace) {
      return Left(
        WebViewConfigurationFailure(
          'Failed to check if can go back: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, bool>> canGoForward() async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewConfigurationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      final canGoForward = await _controller!.canGoForward();
      return Right(canGoForward);
    } catch (e, stackTrace) {
      return Left(
        WebViewConfigurationFailure(
          'Failed to check if can go forward: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> goBack() async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewNavigationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      await _controller!.goBack();
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewNavigationFailure(
          'Failed to go back: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> goForward() async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewNavigationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      await _controller!.goForward();
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewNavigationFailure(
          'Failed to go forward: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> reload() async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewConfigurationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      await _controller!.reload();
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewConfigurationFailure(
          'Failed to reload: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> clearCache() async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewCacheFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      await _controller!.clearCache();
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewCacheFailure(
          'Failed to clear cache: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> clearLocalStorage() async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewClearDataFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      await _controller!.clearLocalStorage();
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewClearDataFailure(
          'Failed to clear local storage: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> setJavaScriptMode(
    WebViewJavaScriptMode mode,
  ) async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewConfigurationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      await _controller!.setJavaScriptMode(
        mode == WebViewJavaScriptMode.unrestricted
            ? JavaScriptMode.unrestricted
            : JavaScriptMode.disabled,
      );
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewConfigurationFailure(
          'Failed to set JavaScript mode: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> setUserAgent(String? userAgent) async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewConfigurationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      await _controller!.setUserAgent(userAgent);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewConfigurationFailure(
          'Failed to set user agent: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> setBackgroundColor(int color) async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewConfigurationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      await _controller!.setBackgroundColor(Color(color));
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewConfigurationFailure(
          'Failed to set background color: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> enableZoom(bool enabled) async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewConfigurationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      await _controller!.enableZoom(enabled);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewConfigurationFailure(
          'Failed to enable zoom: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> addJavaScriptChannel(
    WebViewJavaScriptChannel channel,
  ) async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewConfigurationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      _javaScriptChannels[channel.name] = channel;

      await _controller!.addJavaScriptChannel(
        channel.name,
        onMessageReceived: (JavaScriptMessage message) {
          channel.onMessageReceived(message.message);
        },
      );
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewConfigurationFailure(
          'Failed to add JavaScript channel: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> removeJavaScriptChannel(
    String name,
  ) async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewConfigurationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      _javaScriptChannels.remove(name);
      await _controller!.removeJavaScriptChannel(name);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewConfigurationFailure(
          'Failed to remove JavaScript channel: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> setNavigationDelegate({
    WebViewNavigationDecision Function(WebViewNavigationRequest request)?
        onNavigationRequest,
    void Function(String url)? onPageStarted,
    void Function(String url)? onPageFinished,
    void Function(int progress)? onProgress,
    void Function(WebViewResourceError error)? onWebResourceError,
    void Function(WebViewHttpError error)? onHttpError,
  }) async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewConfigurationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      await _controller!.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: onNavigationRequest != null
              ? (NavigationRequest request) {
                  final customRequest = WebViewNavigationRequest(
                    url: request.url,
                    isMainFrame: request.isMainFrame,
                  );
                  final decision = onNavigationRequest(customRequest);
                  return decision == WebViewNavigationDecision.navigate
                      ? NavigationDecision.navigate
                      : NavigationDecision.prevent;
                }
              : null,
          onPageStarted: onPageStarted,
          onPageFinished: onPageFinished,
          onProgress: onProgress,
          onWebResourceError: onWebResourceError != null
              ? (WebResourceError error) {
                  onWebResourceError(
                    WebViewResourceError(
                      errorCode: error.errorCode,
                      description: error.description,
                      failingUrl: error.url,
                      isForMainFrame: error.isForMainFrame ?? false,
                    ),
                  );
                }
              : null,
          onHttpError: onHttpError != null
              ? (HttpResponseError error) {
                  onHttpError(
                    WebViewHttpError(
                      statusCode: error.response?.statusCode ?? 0,
                      url: error.request?.uri.toString(),
                    ),
                  );
                }
              : null,
        ),
      );
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewConfigurationFailure(
          'Failed to set navigation delegate: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, (int x, int y)>> getScrollPosition() async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewConfigurationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      final position = await _controller!.getScrollPosition();
      return Right((position.dx.toInt(), position.dy.toInt()));
    } catch (e, stackTrace) {
      return Left(
        WebViewConfigurationFailure(
          'Failed to get scroll position: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> scrollTo(int x, int y) async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewConfigurationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      await _controller!.scrollTo(x, y);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewConfigurationFailure(
          'Failed to scroll to position: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> scrollBy(int x, int y) async {
    if (!_isInitialized || _controller == null) {
      return const Left(
        WebViewConfigurationFailure(WebViewConstants.errorNotInitialized),
      );
    }

    try {
      await _controller!.scrollBy(x, y);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewConfigurationFailure(
          'Failed to scroll by offset: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  // Helper methods

  LoadRequestMethod _convertLoadRequestMethod(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return LoadRequestMethod.get;
      case 'POST':
        return LoadRequestMethod.post;
      default:
        return LoadRequestMethod.get;
    }
  }

  Set<PlaybackMediaTypes> _convertMediaTypesRequiringUserAction(
    Set<String>? mediaTypes,
  ) {
    if (mediaTypes == null || mediaTypes.isEmpty) {
      return <PlaybackMediaTypes>{};
    }

    final result = <PlaybackMediaTypes>{};

    for (final type in mediaTypes) {
      switch (type.toLowerCase()) {
        case 'audio':
          result.add(PlaybackMediaTypes.audio);
          break;
        case 'video':
          result.add(PlaybackMediaTypes.video);
          break;
        case 'all':
          result.add(PlaybackMediaTypes.audio);
          result.add(PlaybackMediaTypes.video);
          break;
      }
    }

    return result;
  }
}

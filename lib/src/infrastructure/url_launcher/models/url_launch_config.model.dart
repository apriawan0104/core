import 'package:app_core/src/infrastructure/url_launcher/models/launch_mode.model.dart';

/// Configuration for launching a URL
///
/// This configuration allows customizing how a URL should be launched.
class UrlLaunchConfig {
  /// The launch mode to use
  final UrlLaunchMode mode;

  /// Custom HTTP headers (only for web URLs)
  final Map<String, String>? headers;

  /// Custom web view configuration (only for in-app web views)
  final WebViewConfiguration? webViewConfiguration;

  /// Whether to enable JavaScript (for web views)
  final bool enableJavaScript;

  /// Whether to enable DOM storage (for web views)
  final bool enableDomStorage;

  const UrlLaunchConfig({
    this.mode = UrlLaunchMode.platformDefault,
    this.headers,
    this.webViewConfiguration,
    this.enableJavaScript = true,
    this.enableDomStorage = true,
  });

  /// Default configuration
  static const UrlLaunchConfig defaultConfig = UrlLaunchConfig();

  /// Configuration for opening in external browser
  static const UrlLaunchConfig externalBrowser = UrlLaunchConfig(
    mode: UrlLaunchMode.externalApplication,
  );

  /// Configuration for opening in in-app browser
  static const UrlLaunchConfig inAppBrowser = UrlLaunchConfig(
    mode: UrlLaunchMode.inAppBrowserView,
  );

  /// Configuration for opening in in-app web view
  static const UrlLaunchConfig inAppWebView = UrlLaunchConfig(
    mode: UrlLaunchMode.inAppWebView,
  );

  /// Copy with method
  UrlLaunchConfig copyWith({
    UrlLaunchMode? mode,
    Map<String, String>? headers,
    WebViewConfiguration? webViewConfiguration,
    bool? enableJavaScript,
    bool? enableDomStorage,
  }) {
    return UrlLaunchConfig(
      mode: mode ?? this.mode,
      headers: headers ?? this.headers,
      webViewConfiguration: webViewConfiguration ?? this.webViewConfiguration,
      enableJavaScript: enableJavaScript ?? this.enableJavaScript,
      enableDomStorage: enableDomStorage ?? this.enableDomStorage,
    );
  }

  @override
  String toString() {
    return 'UrlLaunchConfig(mode: $mode, enableJavaScript: $enableJavaScript, enableDomStorage: $enableDomStorage)';
  }
}

/// Web view configuration for in-app web views
class WebViewConfiguration {
  /// Whether to show page title
  final bool showTitle;

  /// Toolbar color (hex color string)
  final String? toolbarColor;

  /// Whether to enable zoom
  final bool enableZoom;

  const WebViewConfiguration({
    this.showTitle = true,
    this.toolbarColor,
    this.enableZoom = true,
  });

  @override
  String toString() {
    return 'WebViewConfiguration(showTitle: $showTitle, toolbarColor: $toolbarColor, enableZoom: $enableZoom)';
  }
}

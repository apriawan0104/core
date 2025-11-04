/// Represents a navigation decision
enum WebViewNavigationDecision {
  /// Allow the navigation
  navigate,

  /// Prevent the navigation
  prevent,
}

/// Represents a navigation request
class WebViewNavigationRequest {
  /// The URL being navigated to
  final String url;

  /// Whether this is for the main frame
  final bool isMainFrame;

  const WebViewNavigationRequest({
    required this.url,
    required this.isMainFrame,
  });
}

/// Represents navigation progress
class WebViewNavigationProgress {
  /// Progress percentage (0-100)
  final int progress;

  const WebViewNavigationProgress(this.progress);
}


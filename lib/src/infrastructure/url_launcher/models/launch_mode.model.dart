/// Launch mode for URL launching
///
/// Defines how a URL should be opened on the platform.
/// This is our own abstraction to avoid exposing third-party types.
enum UrlLaunchMode {
  /// Leaves the decision to the platform
  /// - iOS: Uses SFSafariViewController
  /// - Android: Uses Custom Tabs
  platformDefault,

  /// Opens URL in an in-app web view
  /// Note: Not all platforms support this mode
  inAppWebView,

  /// Opens URL in an in-app browser view (Custom Tabs/SFSafariViewController)
  /// Falls back to platformDefault if not supported
  inAppBrowserView,

  /// Opens URL in external application (default browser)
  externalApplication,

  /// Opens URL in external non-browser application
  /// Falls back to externalApplication if no app can handle the URL
  externalNonBrowserApplication,
}

/// Extension to provide description for each launch mode
extension UrlLaunchModeExtension on UrlLaunchMode {
  /// Get human-readable description of the launch mode
  String get description {
    switch (this) {
      case UrlLaunchMode.platformDefault:
        return 'Platform default behavior';
      case UrlLaunchMode.inAppWebView:
        return 'In-app web view';
      case UrlLaunchMode.inAppBrowserView:
        return 'In-app browser view (Custom Tabs/Safari View Controller)';
      case UrlLaunchMode.externalApplication:
        return 'External application';
      case UrlLaunchMode.externalNonBrowserApplication:
        return 'External non-browser application';
    }
  }
}

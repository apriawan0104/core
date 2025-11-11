/// Configuration model for HTTP Inspector
class HttpInspectorConfig {
  /// Whether to show notifications for HTTP requests
  final bool showNotifications;

  /// Whether to enable inspector in release mode
  final bool showOnRelease;

  /// Whether to show only errors (4xx, 5xx status codes)
  final bool showOnlyErrors;

  /// Maximum content length to display
  final int maxContentLength;

  /// Headers to hide in inspector (for security)
  final List<String> headersToHide;

  /// Custom notification title
  final String? notificationTitle;

  /// Whether to enable request/response body encryption in storage
  final bool encryptStorage;

  /// Whether to show image previews
  final bool showImagePreview;

  /// Whether to enable sharing functionality
  final bool enableSharing;

  /// Maximum number of requests to store
  final int maxRequestsToStore;

  /// Whether to auto-clear old requests
  final bool autoClearOldRequests;

  const HttpInspectorConfig({
    this.showNotifications = true,
    this.showOnRelease = false,
    this.showOnlyErrors = false,
    this.maxContentLength = 250000,
    this.headersToHide = const [
      'authorization',
      'cookie',
      'set-cookie',
      'api-key',
      'x-api-key',
      'access-token',
      'refresh-token',
    ],
    this.notificationTitle,
    this.encryptStorage = false,
    this.showImagePreview = true,
    this.enableSharing = true,
    this.maxRequestsToStore = 100,
    this.autoClearOldRequests = true,
  });

  /// Creates a copy with modified fields
  HttpInspectorConfig copyWith({
    bool? showNotifications,
    bool? showOnRelease,
    bool? showOnlyErrors,
    int? maxContentLength,
    List<String>? headersToHide,
    String? notificationTitle,
    bool? encryptStorage,
    bool? showImagePreview,
    bool? enableSharing,
    int? maxRequestsToStore,
    bool? autoClearOldRequests,
  }) {
    return HttpInspectorConfig(
      showNotifications: showNotifications ?? this.showNotifications,
      showOnRelease: showOnRelease ?? this.showOnRelease,
      showOnlyErrors: showOnlyErrors ?? this.showOnlyErrors,
      maxContentLength: maxContentLength ?? this.maxContentLength,
      headersToHide: headersToHide ?? this.headersToHide,
      notificationTitle: notificationTitle ?? this.notificationTitle,
      encryptStorage: encryptStorage ?? this.encryptStorage,
      showImagePreview: showImagePreview ?? this.showImagePreview,
      enableSharing: enableSharing ?? this.enableSharing,
      maxRequestsToStore: maxRequestsToStore ?? this.maxRequestsToStore,
      autoClearOldRequests: autoClearOldRequests ?? this.autoClearOldRequests,
    );
  }

  @override
  String toString() {
    return 'HttpInspectorConfig('
        'showNotifications: $showNotifications, '
        'showOnRelease: $showOnRelease, '
        'showOnlyErrors: $showOnlyErrors, '
        'maxContentLength: $maxContentLength, '
        'headersToHide: $headersToHide, '
        'notificationTitle: $notificationTitle, '
        'encryptStorage: $encryptStorage, '
        'showImagePreview: $showImagePreview, '
        'enableSharing: $enableSharing, '
        'maxRequestsToStore: $maxRequestsToStore, '
        'autoClearOldRequests: $autoClearOldRequests'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HttpInspectorConfig &&
        other.showNotifications == showNotifications &&
        other.showOnRelease == showOnRelease &&
        other.showOnlyErrors == showOnlyErrors &&
        other.maxContentLength == maxContentLength &&
        other.notificationTitle == notificationTitle &&
        other.encryptStorage == encryptStorage &&
        other.showImagePreview == showImagePreview &&
        other.enableSharing == enableSharing &&
        other.maxRequestsToStore == maxRequestsToStore &&
        other.autoClearOldRequests == autoClearOldRequests;
  }

  @override
  int get hashCode {
    return showNotifications.hashCode ^
        showOnRelease.hashCode ^
        showOnlyErrors.hashCode ^
        maxContentLength.hashCode ^
        notificationTitle.hashCode ^
        encryptStorage.hashCode ^
        showImagePreview.hashCode ^
        enableSharing.hashCode ^
        maxRequestsToStore.hashCode ^
        autoClearOldRequests.hashCode;
  }
}

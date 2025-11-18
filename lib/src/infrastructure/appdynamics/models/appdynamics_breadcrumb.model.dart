/// Model representing a breadcrumb for tracking user interactions.
///
/// Breadcrumbs help track user interactions and UI events throughout
/// the app session. They are useful for debugging and understanding user flows.
///
/// ## Usage Example
///
/// ```dart
/// // Track a button click
/// await appDynamics.leaveBreadcrumb(
///   AppDynamicsBreadcrumb(
///     message: 'User clicked submit button',
///     level: AppDynamicsBreadcrumbLevel.info,
///     category: 'user_action',
///     properties: {'button_id': 'submit', 'screen': 'checkout'},
///   ),
/// );
/// ```
class AppDynamicsBreadcrumb {
  /// The breadcrumb message describing the event.
  ///
  /// Should be descriptive and help understand what happened.
  /// Example: 'User clicked submit button', 'Navigated to profile screen'
  final String message;

  /// The severity level of this breadcrumb.
  ///
  /// Default: [AppDynamicsBreadcrumbLevel.info]
  final AppDynamicsBreadcrumbLevel level;

  /// Category for grouping related breadcrumbs.
  ///
  /// Examples: 'user_action', 'navigation', 'api_call', 'error'
  final String? category;

  /// Additional properties associated with this breadcrumb.
  ///
  /// Can contain any JSON-serializable data.
  final Map<String, dynamic>? properties;

  /// Timestamp when the breadcrumb was created.
  ///
  /// If not provided, the current time will be used.
  final DateTime? timestamp;

  const AppDynamicsBreadcrumb({
    required this.message,
    this.level = AppDynamicsBreadcrumbLevel.info,
    this.category,
    this.properties,
    this.timestamp,
  });

  /// Creates a copy of this breadcrumb with optional field updates.
  AppDynamicsBreadcrumb copyWith({
    String? message,
    AppDynamicsBreadcrumbLevel? level,
    String? category,
    Map<String, dynamic>? properties,
    DateTime? timestamp,
  }) {
    return AppDynamicsBreadcrumb(
      message: message ?? this.message,
      level: level ?? this.level,
      category: category ?? this.category,
      properties: properties ?? this.properties,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'AppDynamicsBreadcrumb('
        'message: $message, '
        'level: $level, '
        'category: $category'
        ')';
  }
}

/// Severity levels for breadcrumbs.
enum AppDynamicsBreadcrumbLevel {
  /// Informational breadcrumb (default).
  info,

  /// Warning-level breadcrumb.
  warning,

  /// Error-level breadcrumb.
  error,

  /// Critical-level breadcrumb.
  critical,
}

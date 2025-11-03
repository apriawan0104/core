/// Model representing an analytics event.
///
/// An event represents a user action or system occurrence that you want to track.
/// Events can have optional properties to provide additional context.
///
/// ## Usage Example
///
/// ```dart
/// // Simple event
/// final event = AnalyticsEvent(name: 'button_clicked');
///
/// // Event with properties
/// final purchaseEvent = AnalyticsEvent(
///   name: 'purchase_completed',
///   properties: {
///     'product_id': '123',
///     'amount': 99.99,
///     'currency': 'USD',
///     'payment_method': 'credit_card',
///   },
///   timestamp: DateTime.now(),
/// );
///
/// // Event with nested properties
/// final signupEvent = AnalyticsEvent(
///   name: 'user_signed_up',
///   properties: {
///     'method': 'email',
///     'user': {
///       'email': 'user@example.com',
///       'name': 'John Doe',
///     },
///     'referrer': 'facebook_ad',
///   },
/// );
/// ```
class AnalyticsEvent {
  /// The name of the event.
  ///
  /// Should be descriptive and follow a consistent naming convention.
  /// Examples: 'button_clicked', 'purchase_completed', 'screen_viewed'
  final String name;

  /// Optional properties associated with the event.
  ///
  /// Properties provide additional context about the event.
  /// Can contain any JSON-serializable data.
  final Map<String, dynamic>? properties;

  /// Optional timestamp for the event.
  ///
  /// If not provided, the analytics service will use the current time.
  final DateTime? timestamp;

  const AnalyticsEvent({
    required this.name,
    this.properties,
    this.timestamp,
  });

  /// Creates a copy of this event with optional field updates.
  AnalyticsEvent copyWith({
    String? name,
    Map<String, dynamic>? properties,
    DateTime? timestamp,
  }) {
    return AnalyticsEvent(
      name: name ?? this.name,
      properties: properties ?? this.properties,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Converts this event to a map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (properties != null) 'properties': properties,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  /// Creates an event from a map.
  factory AnalyticsEvent.fromMap(Map<String, dynamic> map) {
    return AnalyticsEvent(
      name: map['name'] as String,
      properties: map['properties'] as Map<String, dynamic>?,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'AnalyticsEvent(name: $name, properties: $properties, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnalyticsEvent &&
        other.name == name &&
        _mapsEqual(other.properties, properties) &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => name.hashCode ^ properties.hashCode ^ timestamp.hashCode;

  /// Helper method to compare maps for equality.
  bool _mapsEqual(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) {
        return false;
      }
    }

    return true;
  }
}

/// Predefined common analytics events.
///
/// These are commonly tracked events across applications.
/// Use these for consistency or create your own custom events.
class CommonAnalyticsEvents {
  CommonAnalyticsEvents._();

  /// User signed up for the application.
  static AnalyticsEvent signUp({Map<String, dynamic>? properties}) {
    return AnalyticsEvent(name: 'sign_up', properties: properties);
  }

  /// User logged in.
  static AnalyticsEvent login({Map<String, dynamic>? properties}) {
    return AnalyticsEvent(name: 'login', properties: properties);
  }

  /// User logged out.
  static AnalyticsEvent logout({Map<String, dynamic>? properties}) {
    return AnalyticsEvent(name: 'logout', properties: properties);
  }

  /// User completed a purchase.
  static AnalyticsEvent purchase({Map<String, dynamic>? properties}) {
    return AnalyticsEvent(name: 'purchase', properties: properties);
  }

  /// User added item to cart.
  static AnalyticsEvent addToCart({Map<String, dynamic>? properties}) {
    return AnalyticsEvent(name: 'add_to_cart', properties: properties);
  }

  /// User removed item from cart.
  static AnalyticsEvent removeFromCart({Map<String, dynamic>? properties}) {
    return AnalyticsEvent(name: 'remove_from_cart', properties: properties);
  }

  /// User viewed a product.
  static AnalyticsEvent viewProduct({Map<String, dynamic>? properties}) {
    return AnalyticsEvent(name: 'view_product', properties: properties);
  }

  /// User searched for something.
  static AnalyticsEvent search({Map<String, dynamic>? properties}) {
    return AnalyticsEvent(name: 'search', properties: properties);
  }

  /// User shared content.
  static AnalyticsEvent share({Map<String, dynamic>? properties}) {
    return AnalyticsEvent(name: 'share', properties: properties);
  }

  /// User rated something.
  static AnalyticsEvent rate({Map<String, dynamic>? properties}) {
    return AnalyticsEvent(name: 'rate', properties: properties);
  }

  /// App was opened.
  static AnalyticsEvent appOpen({Map<String, dynamic>? properties}) {
    return AnalyticsEvent(name: 'app_open', properties: properties);
  }

  /// App was closed.
  static AnalyticsEvent appClose({Map<String, dynamic>? properties}) {
    return AnalyticsEvent(name: 'app_close', properties: properties);
  }

  /// Tutorial was started.
  static AnalyticsEvent tutorialBegin({Map<String, dynamic>? properties}) {
    return AnalyticsEvent(name: 'tutorial_begin', properties: properties);
  }

  /// Tutorial was completed.
  static AnalyticsEvent tutorialComplete({Map<String, dynamic>? properties}) {
    return AnalyticsEvent(name: 'tutorial_complete', properties: properties);
  }

  /// Level was completed (for games).
  static AnalyticsEvent levelComplete({Map<String, dynamic>? properties}) {
    return AnalyticsEvent(name: 'level_complete', properties: properties);
  }
}

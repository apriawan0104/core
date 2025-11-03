/// Entity representing notification data
///
/// This is a pure domain entity with no external dependencies
class NotificationDataEntity {
  /// Unique identifier for the notification
  final String? id;

  /// Title of the notification
  final String? title;

  /// Body/message of the notification
  final String? body;

  /// Additional payload data
  final Map<String, dynamic>? data;

  /// Image URL for the notification
  final String? imageUrl;

  /// Channel ID (Android specific)
  final String? channelId;

  /// Sound name for the notification
  final String? sound;

  /// Badge count (iOS specific)
  final int? badge;

  /// Category identifier (iOS specific)
  final String? category;

  /// Thread identifier for grouping (iOS specific)
  final String? threadIdentifier;

  /// Timestamp when notification was received
  final DateTime? timestamp;

  const NotificationDataEntity({
    this.id,
    this.title,
    this.body,
    this.data,
    this.imageUrl,
    this.channelId,
    this.sound,
    this.badge,
    this.category,
    this.threadIdentifier,
    this.timestamp,
  });

  /// Create a copy with modified fields
  NotificationDataEntity copyWith({
    String? id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? channelId,
    String? sound,
    int? badge,
    String? category,
    String? threadIdentifier,
    DateTime? timestamp,
  }) {
    return NotificationDataEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      channelId: channelId ?? this.channelId,
      sound: sound ?? this.sound,
      badge: badge ?? this.badge,
      category: category ?? this.category,
      threadIdentifier: threadIdentifier ?? this.threadIdentifier,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'NotificationDataEntity(id: $id, title: $title, body: $body, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationDataEntity &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.imageUrl == imageUrl &&
        other.channelId == channelId &&
        other.sound == sound &&
        other.badge == badge &&
        other.category == category &&
        other.threadIdentifier == threadIdentifier &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      body,
      imageUrl,
      channelId,
      sound,
      badge,
      category,
      threadIdentifier,
      timestamp,
    );
  }
}

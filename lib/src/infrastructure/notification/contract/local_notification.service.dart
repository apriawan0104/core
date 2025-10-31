import '../../../foundation/domain/entities/notification/entities.dart';

abstract class LocalNotificationService {
  Future<void> init({
    required void Function(NotificationData) notificationAction,
    String? androidChannelId,
    String? androidChannelName,
    String? androidChannelDescription,
  });

  Future<bool> requestPermissions();

  Future<void> showNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
  });
}

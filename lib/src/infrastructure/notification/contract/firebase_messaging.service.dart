import 'package:firebase_messaging/firebase_messaging.dart';

abstract class FirebaseMessagingService {
  Future<bool> init({
    required void Function(RemoteMessage?) initialAction,
    required void Function(RemoteMessage) notificationAction,
    required void Function(RemoteMessage) messageAction,
    required void Function(RemoteMessage) backgroundAction,
    required void Function() onNotificationPermissionDenied,
  });

  Future<bool> requestPermission({
    void Function()? onPermissionDenied,
  });

  Future<String?> getToken();

  Future<void> subscribeToTopic(String topic);

  Future<void> unsubscribeFromTopic(String topic);
}

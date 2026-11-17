import 'push_notification.settings.dart';

/// Builds an FCM topic from [settings] and a module key.
///
/// `hrgs` with prefix `module_` becomes `module_hrgs`. A value that already
/// starts with the prefix is left as-is.
String moduleTopic(PushNotificationSettings settings, String moduleKey) {
  final key = moduleKey.trim().toLowerCase();
  if (key.isEmpty) {
    throw ArgumentError.value(moduleKey, 'moduleKey', 'Module is empty');
  }
  final topic = key.startsWith(settings.moduleTopicPrefix)
      ? key
      : '${settings.moduleTopicPrefix}$key';
  return sanitizeTopic(topic);
}

/// Keeps only characters FCM accepts in a topic name.
String sanitizeTopic(String raw) {
  final cleaned = raw.trim().replaceAll(RegExp(r'[^A-Za-z0-9\-_.~%]'), '_');
  if (cleaned.isEmpty) {
    throw ArgumentError.value(raw, 'raw', 'Topic is empty');
  }
  return cleaned;
}

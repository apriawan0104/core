import 'push_notification.settings.dart';

/// Platform sound used when a message does not choose one.
const pushSystemSound = 'default';

/// Payload sound, then the native notification sound, then [PushNotificationSettings.defaultSound].
String resolvePushSound(
  PushNotificationSettings settings,
  Map<String, dynamic> data, {
  String? platformSound,
}) {
  final fromData = data[settings.soundField]?.toString().trim();
  if (fromData != null && fromData.isNotEmpty) return fromData;

  final native = platformSound?.trim();
  if (native != null && native.isNotEmpty) return native;

  final configured = settings.defaultSound.trim();
  if (configured.isEmpty) return pushSystemSound;
  return configured;
}

/// Android channel id. A custom sound gets its own channel because Android
/// keeps the first sound assigned to a channel.
String androidChannelIdForSound(
  PushNotificationSettings settings,
  String sound,
) {
  if (sound == pushSystemSound) return settings.defaultAndroidChannelId;
  final sanitized = sound.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
  return '${settings.soundChannelPrefix}$sanitized';
}

/// iOS sound file. `default` stays the system sound.
String iosSoundName(PushNotificationSettings settings, String sound) {
  if (sound == pushSystemSound) return pushSystemSound;
  if (sound.contains('.')) return sound;
  return '$sound${settings.iosSoundExtension}';
}

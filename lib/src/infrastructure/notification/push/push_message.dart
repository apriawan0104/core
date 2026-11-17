import 'push_notification.settings.dart';
import 'push_sound.dart';
import 'push_topics.dart';

enum PushAudienceType { general, module, topic, token }

/// Who should receive one push.
///
/// Topics are used for `general` and modules. A device is addressed by its FCM
/// token. A backend sends the map from [buildFcmMessageFor] through the FCM
/// HTTP v1 API. The server key stays on the backend.
class PushAudience {
  const PushAudience.general() : type = PushAudienceType.general, value = null;

  const PushAudience.module(this.value) : type = PushAudienceType.module;

  const PushAudience.topic(this.value) : type = PushAudienceType.topic;

  const PushAudience.token(this.value) : type = PushAudienceType.token;

  final PushAudienceType type;
  final String? value;

  String? topicIn(PushNotificationSettings settings) {
    switch (type) {
      case PushAudienceType.general:
        return settings.generalTopic;
      case PushAudienceType.module:
        return moduleTopic(settings, value ?? '');
      case PushAudienceType.topic:
        final topic = value?.trim() ?? '';
        if (topic.isEmpty) return null;
        return sanitizeTopic(topic);
      case PushAudienceType.token:
        return null;
    }
  }
}

/// One outgoing notification before it is turned into an FCM HTTP v1 body.
///
/// [data] is sent as-is. An app that wants the receiving device to open a
/// screen puts its own routing keys in [data], for example a `layout` JSON.
class PushMessageDraft {
  const PushMessageDraft({
    required this.audience,
    required this.title,
    required this.body,
    this.data = const {},
    this.sound,
  });

  final PushAudience audience;
  final String title;
  final String body;
  final Map<String, String> data;

  /// Overrides [PushNotificationSettings.defaultSound] for this message only.
  final String? sound;
}

/// FCM HTTP v1 `messages:send` body for [draft].
Map<String, dynamic> buildFcmMessageFor(
  PushNotificationSettings settings,
  PushMessageDraft draft,
) {
  final sound = resolvePushSound(settings, {
    settings.soundField: draft.sound ?? draft.data[settings.soundField],
  });
  final channelId = androidChannelIdForSound(settings, sound);
  final data = <String, String>{
    ...draft.data,
    settings.titleField: draft.data[settings.titleField] ?? draft.title,
    settings.bodyField: draft.data[settings.bodyField] ?? draft.body,
    settings.soundField: sound,
  };

  final message = <String, dynamic>{
    'notification': {'title': draft.title, 'body': draft.body},
    'data': data,
    'android': {
      'priority': 'HIGH',
      'notification': {
        'channel_id': channelId,
        'default_sound': sound == pushSystemSound,
        if (sound != pushSystemSound) 'sound': sound,
      },
    },
    'apns': {
      'payload': {
        'aps': {'sound': iosSoundName(settings, sound)},
      },
    },
  };

  if (draft.audience.type == PushAudienceType.token) {
    final token = draft.audience.value?.trim() ?? '';
    if (token.isEmpty) {
      throw ArgumentError.value(
        draft.audience.value,
        'token',
        'Device token is empty',
      );
    }
    message['token'] = token;
  } else {
    final topic = draft.audience.topicIn(settings);
    if (topic == null || topic.isEmpty) {
      throw ArgumentError('Push audience has no topic');
    }
    message['topic'] = topic;
  }

  return {'message': message};
}
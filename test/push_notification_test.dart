import 'dart:convert';

import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _settings = PushNotificationSettings(
  generalTopic: 'general',
  moduleTopicPrefix: 'module_',
  defaultSound: 'default',
  iosSoundExtension: '.caf',
  extraSounds: [],
  defaultAndroidChannelId: 'app_default',
  soundChannelPrefix: 'app_sound_',
  androidChannelName: 'App',
  androidChannelDescription: 'Notifikasi aplikasi',
  notificationIcon: 'ic_notification',
  notificationColor: Color(0xFF08A94C),
  soundField: 'sound',
  titleField: 'title',
  bodyField: 'body',
);

void main() {
  test('module topic uses the configured prefix', () {
    expect(moduleTopic(_settings, 'hrgs'), 'module_hrgs');
    expect(moduleTopic(_settings, 'module_hrgs'), 'module_hrgs');
    expect(moduleTopic(_settings, 'ETAMKAWA'), 'module_etamkawa');
    expect(sanitizeTopic('hello world'), 'hello_world');
  });

  test('message uses the configured sound unless the draft overrides it', () {
    final general = buildFcmMessageFor(
      _settings,
      const PushMessageDraft(
        audience: PushAudience.general(),
        title: 'Info',
        body: 'Untuk semua',
      ),
    );
    final message = general['message'] as Map<String, dynamic>;
    final data = message['data'] as Map<String, String>;
    final android =
        (message['android'] as Map)['notification'] as Map<String, dynamic>;

    expect(message['topic'], 'general');
    expect(data['sound'], 'default');
    expect(android['channel_id'], 'app_default');
    expect(android['default_sound'], isTrue);

    final custom = buildFcmMessageFor(
      _settings,
      const PushMessageDraft(
        audience: PushAudience.module('hrgs'),
        title: 'Task',
        body: 'Baru',
        sound: 'chime',
      ),
    );
    final customMessage = custom['message'] as Map<String, dynamic>;
    final customData = customMessage['data'] as Map<String, String>;
    final customAndroid =
        (customMessage['android'] as Map)['notification']
            as Map<String, dynamic>;
    final aps =
        (((customMessage['apns'] as Map)['payload'] as Map)['aps'] as Map);

    expect(customMessage['topic'], 'module_hrgs');
    expect(customData['sound'], 'chime');
    expect(customAndroid['channel_id'], 'app_sound_chime');
    expect(customAndroid['sound'], 'chime');
    expect(aps['sound'], 'chime.caf');
  });

  test('app data is passed through unchanged', () {
    final layout = jsonEncode({'RouteName': 'verification'});
    final body = buildFcmMessageFor(
      _settings,
      PushMessageDraft(
        audience: const PushAudience.general(),
        title: 'Task',
        body: 'Baru',
        data: {'layout': layout},
      ),
    );
    final data = (body['message'] as Map)['data'] as Map<String, String>;

    expect(data['layout'], layout);
  });

  test('device token audience maps to token and not a topic', () {
    final device = buildFcmMessageFor(
      _settings,
      const PushMessageDraft(
        audience: PushAudience.token('device-token'),
        title: 'Device',
        body: 'Satu perangkat',
      ),
    );

    expect((device['message'] as Map)['token'], 'device-token');
    expect((device['message'] as Map).containsKey('topic'), isFalse);
  });
}

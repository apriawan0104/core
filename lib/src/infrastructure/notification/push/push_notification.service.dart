import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

import 'push_audience_store.dart';
import 'push_firebase.dart';
import 'push_notification.presenter.dart';
import 'push_notification.settings.dart';
import 'push_platform.dart';
import 'push_topics.dart';

/// Called with the data map of a tapped notification. The app decides which
/// screen to open.
typedef PushOpenedCallback = void Function(Map<String, dynamic> data);

/// Subscribes this install to push audiences and reports each tapped
/// notification to the app.
///
/// This service attaches FCM listeners itself. Do not also call
/// `FirebaseMessagingService.initialize` in the same process, or foreground
/// messages and taps are handled twice. Apps that only use
/// `FirebaseMessagingService` are unaffected until they construct this class.
class PushNotificationService {
  PushNotificationService({
    required this.settings,
    required Future<void> Function(RemoteMessage message) onBackgroundMessage,
    required PushAudienceStore audienceStore,
  }) : _onBackgroundMessage = onBackgroundMessage,
       _audienceStore = audienceStore;

  final PushNotificationSettings settings;
  final Future<void> Function(RemoteMessage message) _onBackgroundMessage;
  final PushAudienceStore _audienceStore;

  PushOpenedCallback? _onOpened;
  String? _userId;
  Set<String> _modules = {};
  Set<String> _knownTopics = {};
  String? _lastOpenedId;
  String? deviceToken;
  bool _firebaseReady = false;
  bool _started = false;
  Future<void> _applyTail = Future<void>.value();

  String get _userKey => '${settings.storagePrefix}_user';
  String get _modulesKey => '${settings.storagePrefix}_modules';
  String get _topicsKey => '${settings.storagePrefix}_topics';

  /// Prepares Firebase, notification display, and the general topic.
  ///
  /// [onOpened] receives the data map of a tapped notification. The app reads
  /// its own keys and opens its own screen.
  /// Safe to call when Firebase files are still missing: the app keeps running
  /// and push stays inactive until the next launch with a valid configuration.
  Future<void> initialize({required PushOpenedCallback onOpened}) async {
    _onOpened = onOpened;
    if (PushPlatform.isWeb || _started) return;

    PushNotificationPresenter.onOpened = _openPayload;
    final ready = await ensurePushFirebase(settings);
    if (!ready) return;

    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    await PushNotificationPresenter.initialize(settings);
    await _requestPermission();
    await _waitForApnsToken();

    // Apple only. Android foreground banners are drawn by the local
    // notification presenter below; this call does not show them.
    if (PushPlatform.isIos) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    FirebaseMessaging.onMessage.listen((message) async {
      final shownByIos = PushPlatform.isIos && message.notification != null;
      if (shownByIos) return;
      await PushNotificationPresenter.showRemote(message, settings);
    });
    FirebaseMessaging.onMessageOpenedApp.listen(_openMessage);
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      deviceToken = token;
      debugPrint('FCM token refreshed');
      // ponytail: re-applies every topic on each token event. subscribeToTopic
      // is idempotent, so no diffing is needed for the late-APNs case.
      unawaited(_applyAudience());
    });

    await _loadAudience();
    _firebaseReady = true;
    _started = true;
    deviceToken = await _fetchToken() ?? deviceToken;
    await _applyAudience();
    await _openInitialMessages();
  }

  /// Subscribes this install to the general topic and each module.
  ///
  /// [userId] is stored on the device for the backend device-token call. It
  /// does not create a topic. [modules] are keys without the topic prefix. A
  /// previous module that is no longer included is unsubscribed. The general
  /// topic stays active.
  Future<void> syncAudience({
    String? userId,
    Set<String> modules = const {},
  }) async {
    final trimmedUser = userId?.trim();
    _userId = (trimmedUser == null || trimmedUser.isEmpty) ? null : trimmedUser;
    _modules = modules
        .map((module) => module.trim())
        .where((module) => module.isNotEmpty)
        .toSet();
    await _saveAudience();
    await _applyAudience();
  }

  /// Drops the user id and module topics. The general topic stays subscribed.
  Future<void> clearAudience() => syncAudience();

  Future<void> _requestPermission() async {
    try {
      final permission = await FirebaseMessaging.instance.requestPermission();
      debugPrint('Push permission: ${permission.authorizationStatus}');
    } catch (error, stackTrace) {
      debugPrint('Push permission request failed: $error\n$stackTrace');
    }
  }

  Future<void> _waitForApnsToken() async {
    if (!PushPlatform.isIos) return;
    for (var attempt = 0; attempt < 5; attempt++) {
      final token = await FirebaseMessaging.instance.getAPNSToken();
      if (token != null) return;
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    // Not fatal: onTokenRefresh delivers the token once APNs becomes ready.
    debugPrint('APNs token not ready after 5 attempts');
  }

  /// Returns null instead of throwing, so a missing APNs token (simulator,
  /// denied permission, slow network) does not stop app startup.
  Future<String?> _fetchToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (error, stackTrace) {
      _logFailure('Get FCM token', error, stackTrace);
      return null;
    }
  }

  /// One short line for the expected missing-APNs case, full trace otherwise.
  void _logFailure(String action, Object error, StackTrace stackTrace) {
    if (error is FirebaseException && error.code == 'apns-token-not-set') {
      debugPrint('$action skipped: APNs token not set yet');
      return;
    }
    debugPrint('$action failed: $error\n$stackTrace');
  }

  Future<void> _loadAudience() async {
    _userId = await _audienceStore.readString(_userKey);
    _modules = (await _audienceStore.readStringList(_modulesKey)).toSet();
    _knownTopics = (await _audienceStore.readStringList(_topicsKey)).toSet();
  }

  Future<void> _saveAudience() async {
    await _audienceStore.writeString(_userKey, _userId);
    await _audienceStore.writeStringList(_modulesKey, _modules.toList());
  }

  Future<void> _applyAudience() {
    final previous = _applyTail;
    final done = Completer<void>();
    _applyTail = done.future;
    return previous.then((_) => _applyAudienceBody()).whenComplete(() {
      if (!done.isCompleted) done.complete();
    });
  }

  Future<void> _applyAudienceBody() async {
    if (!_firebaseReady) return;

    final desired = <String>{settings.generalTopic};
    for (final module in _modules) {
      desired.add(moduleTopic(settings, module));
    }

    final applied = <String>{};
    for (final topic in _knownTopics.difference(desired)) {
      if (!await _unsubscribe(topic)) applied.add(topic);
    }
    for (final topic in desired) {
      if (await _subscribe(topic)) applied.add(topic);
    }

    _knownTopics = applied;
    await _audienceStore.writeStringList(_topicsKey, applied.toList());
  }

  Future<bool> _subscribe(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      return true;
    } catch (error, stackTrace) {
      _logFailure('Subscribe $topic', error, stackTrace);
      return false;
    }
  }

  Future<bool> _unsubscribe(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      return true;
    } catch (error, stackTrace) {
      _logFailure('Unsubscribe $topic', error, stackTrace);
      return false;
    }
  }

  Future<void> _openInitialMessages() async {
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _openMessage(initial);

    final launch = await PushNotificationPresenter.plugin
        .getNotificationAppLaunchDetails();
    final payload = launch?.notificationResponse?.payload;
    if ((launch?.didNotificationLaunchApp ?? false) &&
        payload != null &&
        payload.isNotEmpty) {
      _openPayload(payload);
    }
  }

  void _openMessage(RemoteMessage message) {
    _openData(message.data, messageId: message.messageId);
  }

  void _openPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return;
      final data = Map<String, dynamic>.from(decoded);
      final messageId = data.remove('_messageId')?.toString();
      _openData(data, messageId: messageId);
    } on FormatException catch (error) {
      debugPrint('Push payload is not JSON: $error');
    }
  }

  void _openData(Map<String, dynamic> data, {String? messageId}) {
    if (messageId != null && messageId.isNotEmpty) {
      if (messageId == _lastOpenedId) return;
      _lastOpenedId = messageId;
    }
    final opened = _onOpened;
    if (opened == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        opened(data);
      } catch (error, stackTrace) {
        debugPrint('Push navigation failed: $error\n$stackTrace');
      }
    });
  }
}

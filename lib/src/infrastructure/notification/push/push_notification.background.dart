import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

import 'push_firebase.dart';
import 'push_notification.presenter.dart';
import 'push_notification.settings.dart';

/// Handles a data-only message while the app is in the background.
///
/// Notification messages are displayed by the OS. Showing them again here
/// would duplicate the banner. The project entry point must call this with
/// that project's [PushNotificationSettings], because a background isolate
/// does not share the service instance.
Future<void> handlePushBackgroundMessage(
  RemoteMessage message,
  PushNotificationSettings settings,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  final ready = await ensurePushFirebase(settings);
  if (!ready || message.notification != null) return;
  await PushNotificationPresenter.showRemote(message, settings);
}

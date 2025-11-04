// ignore_for_file: unused_local_variable, avoid_print

import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

/// Example demonstrating notification module usage
///
/// This example shows:
/// 1. Setting up notification services using injectable
/// 2. Initializing FCM and local notifications
/// 3. Handling notification callbacks
/// 4. Showing, scheduling, and managing notifications
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone for scheduled notifications
  tz.initializeTimeZones();

  // Setup all services in DI container using injectable
  configureDependencies();

  // Initialize notifications
  await _initializeNotifications();

  runApp(const MyApp());
}

Future<void> _initializeNotifications() async {
  // Get services from DI
  final fcmService = getIt<FirebaseMessagingService>();
  final localService = getIt<LocalNotificationService>();

  // ==============================
  // 1. INITIALIZE FCM
  // ==============================
  await fcmService.initialize(
    // Called when user taps notification
    onNotificationTapped: (notification) async {
      print('📱 FCM Notification tapped: ${notification.title}');
      // Navigate to specific screen based on notification.data
      // Example:
      // if (notification.data?['screen'] == 'profile') {
      //   navigatorKey.currentState?.pushNamed('/profile');
      // }
    },

    // Called when notification received in foreground
    onForegroundNotification: (notification) async {
      print('🔔 FCM Foreground notification: ${notification.title}');

      // Show as local notification so user can see it
      await localService.show(
        NotificationConfig(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: notification.title,
          body: notification.body,
          payload: notification.data?.toString(),
        ),
      );
    },
  );

  // Request FCM permission (iOS)
  final fcmPermissionGranted = await fcmService.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (fcmPermissionGranted) {
    // Get FCM token to send to your backend
    final fcmToken = await fcmService.getToken();
    print('🔑 FCM Token: $fcmToken');

    // Subscribe to topics
    await fcmService.subscribeToTopic('general');
    await fcmService.subscribeToTopic('announcements');
  }

  // Listen to token refresh
  fcmService.onTokenRefresh.listen((newToken) {
    print('🔄 FCM Token refreshed: $newToken');
    // Send updated token to your backend
  });

  // Check if app was opened from notification
  final initialNotification = await fcmService.getInitialNotification();
  if (initialNotification != null) {
    print('🚀 App opened from notification: ${initialNotification.title}');
    // Navigate to appropriate screen
  }

  // ==============================
  // 2. INITIALIZE LOCAL NOTIFICATIONS
  // ==============================
  await localService.initialize(
    onNotificationTapped: (notification) async {
      print('📲 Local notification tapped: ${notification.title}');
      // Handle navigation
    },
  );

  // Request local notification permission
  final localPermissionGranted = await localService.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (localPermissionGranted) {
    // Create notification channels (Android)
    await localService.createNotificationChannel(
      channelId: NotificationConstants.defaultChannelId,
      channelName: NotificationConstants.defaultChannelName,
      channelDescription: NotificationConstants.defaultChannelDescription,
      importance: NotificationImportance.high,
    );

    await localService.createNotificationChannel(
      channelId: NotificationConstants.highPriorityChannelId,
      channelName: NotificationConstants.highPriorityChannelName,
      channelDescription: NotificationConstants.highPriorityChannelDescription,
      importance: NotificationImportance.max,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NotificationExampleScreen(),
    );
  }
}

class NotificationExampleScreen extends StatelessWidget {
  const NotificationExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localService = getIt<LocalNotificationService>();
    final fcmService = getIt<FirebaseMessagingService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ====================================
          // IMMEDIATE NOTIFICATIONS
          // ====================================
          const Text('Immediate Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: () async {
              await localService.show(
                const NotificationConfig(
                  id: 1,
                  title: 'Simple Notification',
                  body: 'This is a simple notification',
                  channelId: NotificationConstants.defaultChannelId,
                  channelName: NotificationConstants.defaultChannelName,
                ),
              );
            },
            child: const Text('Show Simple Notification'),
          ),

          ElevatedButton(
            onPressed: () async {
              await localService.show(
                const NotificationConfig(
                  id: 2,
                  title: 'High Priority Notification',
                  body: 'This notification has high priority',
                  channelId: NotificationConstants.highPriorityChannelId,
                  channelName: NotificationConstants.highPriorityChannelName,
                  importance: NotificationImportance.max,
                  priority: NotificationPriority.max,
                  playSound: true,
                  enableVibration: true,
                ),
              );
            },
            child: const Text('Show High Priority Notification'),
          ),

          const Divider(height: 32),

          // ====================================
          // SCHEDULED NOTIFICATIONS
          // ====================================
          const Text('Scheduled Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: () async {
              await localService.schedule(
                config: const NotificationConfig(
                  id: 10,
                  title: 'Reminder',
                  body: 'This notification was scheduled 10 seconds ago',
                ),
                scheduledDate: DateTime.now().add(const Duration(seconds: 10)),
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Notification scheduled for 10 seconds')),
                );
              }
            },
            child: const Text('Schedule in 10 Seconds'),
          ),

          ElevatedButton(
            onPressed: () async {
              await localService.showDaily(
                config: const NotificationConfig(
                  id: 11,
                  title: 'Daily Reminder',
                  body: 'Good morning! Start your day!',
                ),
                time: DateTime(2024, 1, 1, 9, 0), // 9:00 AM daily
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Daily notification at 9:00 AM set')),
                );
              }
            },
            child: const Text('Set Daily at 9:00 AM'),
          ),

          ElevatedButton(
            onPressed: () async {
              await localService.showWeekly(
                config: const NotificationConfig(
                  id: 12,
                  title: 'Weekly Reminder',
                  body: 'Your weekly report is ready!',
                ),
                dayOfWeek: DateTime.monday,
                time: DateTime(2024, 1, 1, 10, 0), // Monday 10:00 AM
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Weekly notification every Monday at 10:00 AM set')),
                );
              }
            },
            child: const Text('Set Weekly on Monday 10:00 AM'),
          ),

          const Divider(height: 32),

          // ====================================
          // NOTIFICATION MANAGEMENT
          // ====================================
          const Text('Notification Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: () async {
              final pending =
                  await localService.getPendingNotificationRequests();
              print('📋 Pending notifications: ${pending.length}');

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('${pending.length} pending notifications')),
                );
              }
            },
            child: const Text('Check Pending Notifications'),
          ),

          ElevatedButton(
            onPressed: () async {
              final active = await localService.getActiveNotifications();
              print('🔔 Active notifications: ${active.length}');

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('${active.length} active notifications')),
                );
              }
            },
            child: const Text('Check Active Notifications'),
          ),

          ElevatedButton(
            onPressed: () async {
              await localService.cancelAll();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications cancelled')),
                );
              }
            },
            child: const Text('Cancel All Notifications'),
          ),

          const Divider(height: 32),

          // ====================================
          // FCM
          // ====================================
          const Text('Firebase Cloud Messaging',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: () async {
              final token = await fcmService.getToken();
              print('🔑 FCM Token: $token');

              // Copy to clipboard or show dialog
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Token: ${token?.substring(0, 20)}...'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Get FCM Token'),
          ),

          ElevatedButton(
            onPressed: () async {
              final enabled = await localService.areNotificationsEnabled();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Notifications enabled: $enabled'),
                  ),
                );
              }
            },
            child: const Text('Check Notification Permission'),
          ),
        ],
      ),
    );
  }
}

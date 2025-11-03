# Notification Module

Abstraction layer untuk Firebase Cloud Messaging dan Local Notifications, mengikuti Dependency Inversion Principle.

## 📦 Package Dependencies

Module ini menggunakan:
- `firebase_messaging: ^16.0.3` - Remote notifications via FCM
- `flutter_local_notifications: ^17.2.3` - Local notifications
- `timezone: ^0.9.0` - Timezone support untuk scheduled notifications

## 🏗️ Architecture

```
notification/
├── contract/              → Abstract interfaces (DIP)
│   ├── firebase_messaging.service.dart
│   ├── local_notification.service.dart
│   └── notification.dart
├── impl/                  → Concrete implementations
│   ├── firebase_messaging.service.impl.dart
│   ├── local_notification.service.impl.dart
│   └── impl.dart
├── constants/             → Notification constants
│   ├── notification.constant.dart
│   └── constants.dart
└── notification.dart      → Main barrel file
```

## 🚀 Quick Start

### 1. Setup Dependencies

```dart
import 'package:app_core/app_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone for scheduled notifications
  await initializeTimeZones();
  
  // Register notification services
  setupNotificationServices();
  
  runApp(MyApp());
}
```

### 2. Initialize Services

```dart
class NotificationSetup {
  static Future<void> initialize() async {
    // Get services from DI
    final fcmService = getIt<FirebaseMessagingService>();
    final localService = getIt<LocalNotificationService>();
    
    // Initialize FCM
    await fcmService.initialize(
      onNotificationTapped: (notification) async {
        print('FCM notification tapped: ${notification.title}');
        // Handle navigation based on notification data
      },
      onForegroundNotification: (notification) async {
        print('Received foreground notification: ${notification.title}');
        // Show local notification for foreground FCM messages
        await localService.show(
          NotificationConfig(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: notification.title,
            body: notification.body,
          ),
        );
      },
    );
    
    // Request FCM permission (iOS)
    final granted = await fcmService.requestPermission();
    if (granted) {
      // Get FCM token
      final token = await fcmService.getToken();
      print('FCM Token: $token');
      
      // Subscribe to topics
      await fcmService.subscribeToTopic('general');
    }
    
    // Initialize local notifications
    await localService.initialize(
      onNotificationTapped: (notification) async {
        print('Local notification tapped: ${notification.title}');
        // Handle navigation
      },
    );
    
    // Request local notification permission
    await localService.requestPermission();
    
    // Create notification channels (Android)
    await localService.createNotificationChannel(
      channelId: NotificationConstants.defaultChannelId,
      channelName: NotificationConstants.defaultChannelName,
      channelDescription: NotificationConstants.defaultChannelDescription,
      importance: NotificationImportance.high,
    );
  }
}
```

## 📱 Usage Examples

### Firebase Cloud Messaging

#### Get FCM Token
```dart
final fcmService = getIt<FirebaseMessagingService>();
final token = await fcmService.getToken();
print('FCM Token: $token');
```

#### Subscribe/Unsubscribe to Topics
```dart
await fcmService.subscribeToTopic('news');
await fcmService.unsubscribeFromTopic('news');
```

#### Listen to Token Refresh
```dart
fcmService.onTokenRefresh.listen((newToken) {
  print('New FCM Token: $newToken');
  // Send to your backend
});
```

#### Handle Initial Notification (App opened from terminated state)
```dart
final initialNotification = await fcmService.getInitialNotification();
if (initialNotification != null) {
  print('App opened from notification: ${initialNotification.title}');
  // Navigate to specific screen
}
```

### Local Notifications

#### Show Immediate Notification
```dart
final localService = getIt<LocalNotificationService>();

await localService.show(
  NotificationConfig(
    id: 1,
    title: 'Hello!',
    body: 'This is a test notification',
    channelId: NotificationConstants.defaultChannelId,
    channelName: NotificationConstants.defaultChannelName,
  ),
);
```

#### Schedule Notification
```dart
await localService.schedule(
  config: NotificationConfig(
    id: 2,
    title: 'Reminder',
    body: 'Don\'t forget your meeting!',
  ),
  scheduledDate: DateTime.now().add(Duration(hours: 1)),
);
```

#### Daily Notification
```dart
await localService.showDaily(
  config: NotificationConfig(
    id: 3,
    title: 'Good Morning!',
    body: 'Have a great day!',
  ),
  time: DateTime(2024, 1, 1, 9, 0), // 9:00 AM every day
);
```

#### Weekly Notification
```dart
await localService.showWeekly(
  config: NotificationConfig(
    id: 4,
    title: 'Weekly Report',
    body: 'Your weekly summary is ready',
  ),
  dayOfWeek: DateTime.monday,
  time: DateTime(2024, 1, 1, 9, 0), // Every Monday at 9:00 AM
);
```

#### Periodic Notification
```dart
await localService.periodicallyShow(
  config: NotificationConfig(
    id: 5,
    title: 'Hourly Update',
    body: 'Time for a break!',
  ),
  repeatInterval: RepeatInterval.hourly,
);
```

#### Cancel Notifications
```dart
// Cancel specific notification
await localService.cancel(1);

// Cancel all notifications
await localService.cancelAll();
```

#### Get Pending/Active Notifications
```dart
// Get scheduled notifications
final pending = await localService.getPendingNotificationRequests();
print('Pending: ${pending.length} notifications');

// Get currently showing notifications
final active = await localService.getActiveNotifications();
print('Active: ${active.length} notifications');
```

### Advanced Configuration

#### Custom Notification Style (Android)
```dart
await localService.show(
  NotificationConfig(
    id: 6,
    title: 'New Message',
    body: 'You have a new message from John',
    style: NotificationStyle.bigText,
    largeIcon: 'https://example.com/avatar.jpg',
    importance: NotificationImportance.high,
    priority: NotificationPriority.high,
    playSound: true,
    sound: 'custom_sound', // Without extension
    enableVibration: true,
    vibrationPattern: [0, 500, 250, 500],
  ),
);
```

#### Grouped Notifications (Android)
```dart
// Show individual notifications
await localService.show(
  NotificationConfig(
    id: 10,
    title: 'Message 1',
    body: 'First message',
    groupKey: 'messages',
  ),
);

await localService.show(
  NotificationConfig(
    id: 11,
    title: 'Message 2',
    body: 'Second message',
    groupKey: 'messages',
  ),
);

// Show group summary
await localService.show(
  NotificationConfig(
    id: 12,
    title: 'Messages',
    body: '2 new messages',
    groupKey: 'messages',
    setAsGroupSummary: true,
  ),
);
```

#### Thread Identifier (iOS)
```dart
await localService.show(
  NotificationConfig(
    id: 20,
    title: 'Chat Message',
    body: 'New message in group chat',
    threadIdentifier: 'group_chat_123', // Groups notifications together
  ),
);
```

## 🔧 Custom Implementation

Jika Anda perlu custom behavior, inject custom implementation:

```dart
class MyCustomFCMService implements FirebaseMessagingService {
  @override
  Future<void> initialize({...}) async {
    // Your custom implementation
  }
  
  // Implement other methods...
}

// Register custom implementation
getIt.registerSingleton<FirebaseMessagingService>(
  MyCustomFCMService(),
);
```

## 🧪 Testing

Module ini mudah di-mock untuk testing:

```dart
class MockFirebaseMessagingService extends Mock 
    implements FirebaseMessagingService {}

class MockLocalNotificationService extends Mock 
    implements LocalNotificationService {}

void main() {
  test('notification handling', () async {
    final mockFcm = MockFirebaseMessagingService();
    final mockLocal = MockLocalNotificationService();
    
    when(() => mockFcm.getToken()).thenAnswer((_) async => 'test_token');
    
    final token = await mockFcm.getToken();
    expect(token, 'test_token');
  });
}
```

## ⚠️ Important Notes

### Android Setup

1. Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    
    <application>
        <!-- For scheduled exact alarms -->
        <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    </application>
</manifest>
```

2. For custom notification icons, place them in:
   - `android/app/src/main/res/drawable/`

3. For custom sounds, place them in:
   - `android/app/src/main/res/raw/`

### iOS Setup

1. Request permissions at appropriate time (not immediately at launch)

2. Add to `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

3. For custom sounds, place them in `ios/Runner/` and add to Xcode project

### Background Message Handler (Optional)

Untuk handle FCM messages di background, register static handler:

```dart
// Must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Register background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  runApp(MyApp());
}
```

## 📚 Reference

- [Firebase Messaging Documentation](https://pub.dev/packages/firebase_messaging)
- [Flutter Local Notifications Documentation](https://pub.dev/packages/flutter_local_notifications)
- [Project Architecture Guidelines](../../../ARCHITECTURE.md)

## 🆘 Troubleshooting

### Notifications not showing
1. Check permissions granted
2. Verify notification channel created (Android)
3. Check app is not in battery optimization (Android)

### Scheduled notifications not working
1. Ensure `timezone` package initialized
2. Check exact alarm permission (Android 12+)
3. Verify scheduled date is in future

### FCM token not received
1. Ensure Firebase initialized
2. Check google-services.json (Android) or GoogleService-Info.plist (iOS)
3. Verify internet connection

## 💡 Best Practices

1. **Always request permission at appropriate time** - Don't request immediately at app launch
2. **Create notification channels early** - Before showing any notifications (Android)
3. **Handle both FCM and local notifications** - Show local notification for foreground FCM messages
4. **Test on real devices** - Emulators may not receive FCM properly
5. **Provide meaningful notification content** - Users should understand what the notification is about
6. **Use notification IDs wisely** - Same ID will update existing notification
7. **Clean up scheduled notifications** - Cancel when no longer needed

---

**Remember**: Semua interfaces bersifat **generic** dan **flexible**. Consumer apps harus inject logic spesifik mereka sendiri melalui callbacks dan custom implementations!


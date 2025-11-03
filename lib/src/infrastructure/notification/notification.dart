// Main barrel file for notification infrastructure
// 
// This module provides abstraction over notification services following DIP.
// It wraps firebase_messaging and flutter_local_notifications packages.
// 
// Example usage:
// ```dart
// // 1. Register services in DI container
// GetIt.instance.registerSingleton<FirebaseMessagingService>(
//   FirebaseMessagingServiceImpl(),
// );
// 
// GetIt.instance.registerSingleton<LocalNotificationService>(
//   LocalNotificationServiceImpl(),
// );
// 
// // 2. Initialize services
// final fcmService = GetIt.instance<FirebaseMessagingService>();
// await fcmService.initialize(
//   onNotificationTapped: (notification) async {
//     // Handle notification tap
//     print('Notification tapped: ${notification.title}');
//   },
// );
// 
// final localService = GetIt.instance<LocalNotificationService>();
// await localService.initialize(
//   onNotificationTapped: (notification) async {
//     // Handle local notification tap
//     print('Local notification tapped: ${notification.title}');
//   },
// );
// 
// // 3. Use the services
// // Show local notification
// await localService.show(
//   NotificationConfig(
//     id: 1,
//     title: 'Hello',
//     body: 'This is a test notification',
//   ),
// );
// 
// // Get FCM token
// final token = await fcmService.getToken();
// print('FCM Token: $token');
// ```

// Export contracts (interfaces)
export 'contract/notification.dart';

// Export implementations
export 'impl/impl.dart';

// Export constants
export 'constants/constants.dart';


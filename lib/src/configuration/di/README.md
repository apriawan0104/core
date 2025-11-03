# Dependency Injection Setup

This package uses [injectable](https://pub.dev/packages/injectable) and [get_it](https://pub.dev/packages/get_it) for dependency injection.

## 📦 Services Registered

The following services are automatically registered:

### Notification Services
- `FirebaseMessagingService` - Handle Firebase Cloud Messaging
- `LocalNotificationService` - Handle local notifications

### Responsive Service
- `ResponsiveService` - Screen adaptation utilities

### External Dependencies
- `FirebaseMessaging` - Firebase Messaging instance
- `FlutterLocalNotificationsPlugin` - Flutter local notifications plugin

## 🚀 Usage

### Quick Start

```dart
import 'package:app_core/app_core.dart';

void main() {
  // Initialize all dependencies
  configureDependencies();
  
  // Now you can get services from the container
  final fcmService = getIt<FirebaseMessagingService>();
  final localService = getIt<LocalNotificationService>();
  final responsiveService = getIt<ResponsiveService>();
  
  runApp(MyApp());
}
```

### Complete Example

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone for scheduled notifications
  tz.initializeTimeZones();
  
  // Setup all services in DI container
  configureDependencies();
  
  // Initialize notifications
  final fcmService = getIt<FirebaseMessagingService>();
  final localService = getIt<LocalNotificationService>();
  
  await fcmService.initialize(
    onNotificationTapped: (notification) {
      print('Notification tapped: ${notification.title}');
    },
  );
  
  await localService.initialize(
    onNotificationTapped: (notification) {
      print('Local notification tapped: ${notification.title}');
    },
  );
  
  runApp(MyApp());
}
```

## 🔧 Architecture

### Injectable Annotations

Services are registered using the following annotations:

- `@LazySingleton` - Service is created only when first accessed
- `@Singleton` - Service is created immediately at startup
- `@Injectable` - Service is registered but can have different lifetimes

### Module Registration

External dependencies (third-party packages) are registered via `RegisterModule`:

```dart
@module
abstract class RegisterModule {
  @lazySingleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;
  
  @lazySingleton
  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();
}
```

## 🛠️ Development

### Adding New Services

1. Create your service interface and implementation
2. Add `@LazySingleton` or `@Injectable` annotation to the implementation:

```dart
import 'package:injectable/injectable.dart';

abstract class MyService {
  void doSomething();
}

@LazySingleton(as: MyService)
class MyServiceImpl implements MyService {
  @override
  void doSomething() {
    // Implementation
  }
}
```

3. Run code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Registering External Dependencies

If you need to register external dependencies (from other packages), add them to `RegisterModule`:

```dart
@module
abstract class RegisterModule {
  @lazySingleton
  MyExternalDependency get myDependency => MyExternalDependency();
}
```

## 📚 Migration from Manual Registration

If you were using the old `setupNotificationServices()` method:

### Before
```dart
void main() {
  setupNotificationServices();
  runApp(MyApp());
}
```

### After
```dart
void main() {
  configureDependencies();
  runApp(MyApp());
}
```

## 🔗 References

- [injectable documentation](https://pub.dev/packages/injectable)
- [get_it documentation](https://pub.dev/packages/get_it)
- [Notification Module Documentation](../../infrastructure/notification/doc/README.md)


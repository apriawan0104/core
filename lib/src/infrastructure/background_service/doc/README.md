# Background Service

Background service infrastructure untuk menjalankan Dart code di background, bahkan ketika aplikasi ditutup atau diminimize.

## 🎯 Overview

Background Service memungkinkan aplikasi menjalankan tugas di background seperti:
- Sinkronisasi data periodik
- Monitoring lokasi
- Background uploads/downloads
- Real-time messaging
- Background API polling
- Task scheduling

**Penting:**
- ✅ **Dependency Independent** - Tidak terikat ke flutter_background_service, bisa diganti dengan provider lain
- ✅ **Cross-platform** - Support Android dan iOS
- ⚠️ **Android:** Full background support dengan foreground service
- ⚠️ **iOS:** Limited background execution (max 15-30 detik karena OS restrictions)

## 🏗️ Architecture

```
infrastructure/background_service/
├── constants/           → Constants dan configurations
├── contract/           → Interface dan abstractions
│   └── background_service.service.dart
├── impl/              → Implementation dengan flutter_background_service
│   └── flutter_background_service.service.impl.dart
└── doc/              → Documentation
```

### Dependency Independence

Interface tidak expose types dari flutter_background_service package. Ganti provider hanya perlu:
1. Create new implementation class
2. Update DI registration
3. Done! Tidak perlu ubah business logic.

## 📦 Installation

### 1. Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  app_core: ^x.x.x

# For consumer app using Flutter Background Service
dependencies:
  flutter_background_service: ^5.1.0
```

### 2. Android Setup

#### Add Permissions

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Required permissions -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    
    <!-- Choose based on your foreground service type -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    <!-- OR -->
    <!-- <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" /> -->
    <!-- <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" /> -->
    
    <application>
        <!-- Add service declaration -->
        <service
            android:name="id.flutter.flutter_background_service.BackgroundService"
            android:foregroundServiceType="dataSync"
            android:exported="false" />
    </application>
</manifest>
```

**Foreground Service Types (Android 14+):**
- `dataSync` - For syncing data
- `location` - For location tracking
- `mediaPlayback` - For media playback
- `phoneCall` - For phone calls
- See [Android docs](https://developer.android.com/about/versions/14/changes/fgs-types-required) for full list

#### Custom Notification Icon (Optional)

Place icon named `ic_bg_service_small.png` in:
- `android/app/src/main/res/drawable-mdpi/`
- `android/app/src/main/res/drawable-hdpi/`
- `android/app/src/main/res/drawable-xhdpi/`
- `android/app/src/main/res/drawable-xxhdpi/`

For vector icons:
- `android/app/src/main/res/drawable-anydpi-v24/ic_bg_service_small.xml`

### 3. iOS Setup

#### Enable Background Modes

In Xcode, select your target → Signing & Capabilities → Add Background Modes:
- ☑️ Background fetch (optional)
- ☑️ Remote notifications (if needed)

#### Update Info.plist

```xml
<!-- ios/Runner/Info.plist -->
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>dev.flutter.background.refresh</string>
</array>
```

#### Custom Task Identifier (Optional)

```swift
// ios/Runner/AppDelegate.swift
import UIKit
import Flutter
import flutter_background_service_ios

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Custom task identifier
    SwiftFlutterBackgroundServicePlugin.taskIdentifier = "com.yourapp.background.task"
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 🚀 Usage

### Basic Implementation

#### 1. Register Service in DI

```dart
// configuration/di/register_module.dart
import 'package:flutter_background_service/flutter_background_service.dart' as fbs;

@module
abstract class RegisterModule {
  @lazySingleton
  BackgroundService get backgroundService => FlutterBackgroundServiceImpl(
    fbs.FlutterBackgroundService(),
  );
}
```

#### 2. Configure and Start Service

```dart
import 'package:flutter/material.dart';
import 'package:app_core/app_core.dart';

// Entry point annotation required for background execution
@pragma('vm:entry-point')
void onBackgroundStart(ServiceInstance service) async {
  // This runs in a separate isolate
  
  // Listen for stop command
  service.on('stop').listen((data) {
    service.stopSelf();
  });

  // Periodic task
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (!(await service.isForegroundService())) {
      // Service stopped, cancel timer
      timer.cancel();
      return;
    }

    // Do your background work here
    print('Background task running at ${DateTime.now()}');
    
    // Send data to UI
    service.invoke('update', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup DI
  await configureDependencies();
  
  // Get service
  final service = getIt<BackgroundService>();
  
  // Configure service
  await service.configure(
    config: BackgroundServiceConfig(
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_app_bg_service',
      initialNotificationTitle: 'My App',
      initialNotificationContent: 'Background service is running',
    ),
    onStart: onBackgroundStart,
  );
  
  runApp(MyApp());
}
```

#### 3. Communicate with Service

```dart
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BackgroundService _service = getIt<BackgroundService>();
  StreamSubscription<BackgroundServiceData?>? _subscription;
  
  @override
  void initState() {
    super.initState();
    
    // Listen for updates from service
    _subscription = _service.on('update').listen((data) {
      if (data != null) {
        print('Update from service: ${data.payload}');
      }
    });
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
  
  Future<void> _startService() async {
    final result = await _service.start();
    result.fold(
      (failure) => print('Error: ${failure.message}'),
      (_) => print('Service started'),
    );
  }
  
  Future<void> _stopService() async {
    final result = await _service.invoke('stop');
    result.fold(
      (failure) => print('Error: ${failure.message}'),
      (_) => print('Stop command sent'),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Background Service')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _startService,
              child: Text('Start Service'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _stopService,
              child: Text('Stop Service'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Advanced: Custom Notification with flutter_local_notifications

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const notificationChannelId = 'my_foreground';
const notificationId = 888;

Future<void> setupNotification() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // Create notification channel
  const channel = AndroidNotificationChannel(
    notificationChannelId,
    'Background Service',
    description: 'Background service notification',
    importance: Importance.low,
  );
  
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

@pragma('vm:entry-point')
void onBackgroundStart(ServiceInstance service) async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (await service.isForegroundService()) {
      // Update notification with custom content
      flutterLocalNotificationsPlugin.show(
        notificationId,
        'Background Service',
        'Running: ${DateTime.now()}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannelId,
            'Background Service',
            icon: 'ic_bg_service_small',
            ongoing: true,
          ),
        ),
      );
    }
  });
}
```

### Advanced: Background Mode (No Notification)

```dart
await service.configure(
  config: BackgroundServiceConfig(
    autoStart: true,
    isForegroundMode: false, // Background mode
    autoStartOnBoot: true,
  ),
  onStart: onBackgroundStart,
);
```

**⚠️ Important for Background Mode:**
- Service may be killed by system to save battery
- User must disable battery optimization for your app
- Works best with `autoStartOnBoot: true`
- Test in release mode, not debug mode

## 📋 API Reference

### BackgroundService

| Method | Description |
|--------|-------------|
| `configure()` | Configure service with callbacks and config |
| `start()` | Start the background service |
| `isRunning()` | Check if service is running |
| `invoke()` | Send data to background service |
| `on()` | Listen for data from background service |

### ServiceInstance

| Method | Description |
|--------|-------------|
| `invoke()` | Send data to UI isolate |
| `on()` | Listen for data from UI isolate |
| `stopSelf()` | Stop the service |
| `isForegroundService()` | Check if running as foreground service (Android) |
| `setAsForegroundService()` | Set as foreground service (Android) |
| `setAsBackgroundService()` | Set as background service (Android) |

### BackgroundServiceConfig

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `autoStart` | `bool` | `false` | Auto start on configure |
| `autoStartOnBoot` | `bool` | `false` | Auto start on device boot (Android) |
| `isForegroundMode` | `bool` | `true` | Run as foreground service (shows notification) |
| `notificationChannelId` | `String?` | `'background_service'` | Notification channel ID (Android) |
| `initialNotificationTitle` | `String?` | `'Background Service'` | Notification title |
| `initialNotificationContent` | `String?` | `'Service is running'` | Notification content |
| `foregroundServiceNotificationId` | `int?` | `888` | Notification ID |

## ⚠️ Common Issues

### Service Not Starting

**Solution:**
- Check permissions in AndroidManifest.xml
- Ensure `@pragma('vm:entry-point')` annotation on callback
- Test in release mode

### Service Killed Immediately on Android

**Solution:**
- Use `isForegroundMode: true` (recommended)
- If using background mode, disable battery optimization
- Some manufacturers (Xiaomi MIUI, etc.) need special settings

### iOS Background Not Working

**Solution:**
- iOS has strict background limitations
- Background fetch only runs every ~15 minutes minimum
- Background execution limited to 15-30 seconds
- Consider using push notifications instead

### Notification Icon Not Showing

**Solution:**
- Create `ic_bg_service_small` icon in drawable folders
- Use proper icon sizes for each density
- Ensure icon is white with transparent background

## 🔄 Migration from flutter_background_service

If migrating from direct usage of flutter_background_service:

```dart
// Before
import 'package:flutter_background_service/flutter_background_service.dart';

final service = FlutterBackgroundService();
await service.configure(...);

// After
import 'package:app_core/app_core.dart';

final service = getIt<BackgroundService>();
await service.configure(...);
```

Benefits:
- ✅ Same functionality
- ✅ Cleaner API with Either error handling
- ✅ Easy to switch implementations
- ✅ Testable with mock implementations

## 📚 Resources

- [flutter_background_service package](https://pub.dev/packages/flutter_background_service)
- [Android Foreground Services](https://developer.android.com/develop/background-work/services/foreground-services)
- [iOS Background Execution](https://developer.apple.com/documentation/uikit/app_and_environment/scenes/preparing_your_ui_to_run_in_the_background)

## 🧪 Testing

Create mock for testing:

```dart
class MockBackgroundService implements BackgroundService {
  @override
  Future<Either<Failure, void>> configure({
    required BackgroundServiceConfig config,
    required ServiceStartCallback onStart,
    IosBackgroundCallback? iosBackgroundCallback,
  }) async {
    return const Right(null);
  }
  
  @override
  Future<Either<Failure, void>> start() async {
    return const Right(null);
  }
  
  @override
  Future<Either<Failure, bool>> isRunning() async {
    return const Right(true);
  }
  
  @override
  Future<Either<Failure, void>> invoke(
    String method, [
    Map<String, dynamic>? payload,
  ]) async {
    return const Right(null);
  }
  
  @override
  Stream<BackgroundServiceData?> on(String method) {
    return Stream.value(null);
  }
}
```

## ⚡ Best Practices

1. **Always use foreground service mode** (`isForegroundMode: true`) for reliable execution
2. **Annotate callback with** `@pragma('vm:entry-point')`
3. **Handle service lifecycle** - listen for stop events
4. **Don't do heavy computation** - offload to background threads
5. **Test in release mode** - debug mode behavior differs
6. **Check battery optimization** - guide users to disable for your app
7. **Use appropriate foreground service type** for Android 14+
8. **Consider iOS limitations** - very restricted background execution

## 🆘 Support

For issues specific to BUMA Core background service implementation, check project documentation.
For flutter_background_service package issues, visit [package repository](https://github.com/ekasetiawans/flutter_background_service).


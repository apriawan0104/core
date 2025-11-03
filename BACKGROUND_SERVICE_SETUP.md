# Background Service Setup Guide

Complete setup guide for implementing background service in your Flutter app using BUMA Core.

## 📋 Table of Contents

- [Overview](#overview)
- [Platform Requirements](#platform-requirements)
- [Installation](#installation)
- [Android Configuration](#android-configuration)
- [iOS Configuration](#ios-configuration)
- [Basic Implementation](#basic-implementation)
- [Advanced Usage](#advanced-usage)
- [Common Issues](#common-issues)

## 🎯 Overview

Background Service allows you to run Dart code continuously in the background, even when the app is closed or minimized. Perfect for:

- Real-time data synchronization
- Location tracking
- Background downloads/uploads
- Periodic API polling
- Real-time messaging
- Task scheduling

### Platform Support

| Platform | Support Level | Notes |
|----------|---------------|-------|
| Android | ✅ Full Support | Can run indefinitely with foreground service |
| iOS | ⚠️ Limited Support | Max 15-30 seconds execution due to OS restrictions |

## 📦 Installation

### 1. Add Dependency

```yaml
# pubspec.yaml
dependencies:
  app_core: ^x.x.x
```

### 2. Get Packages

```bash
flutter pub get
```

## 🤖 Android Configuration

### Step 1: Add Permissions

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Required for foreground service -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    
    <!-- Choose based on your service type (Android 14+) -->
    <!-- For data synchronization -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    
    <!-- OR for location tracking -->
    <!-- <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" /> -->
    <!-- <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" /> -->
    <!-- <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" /> -->
    
    <!-- OR for media playback -->
    <!-- <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" /> -->
    
    <!-- OR for phone calls -->
    <!-- <uses-permission android:name="android.permission.FOREGROUND_SERVICE_PHONE_CALL" /> -->
    
    <application
        android:label="YourApp"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Your activities -->
        <activity
            android:name=".MainActivity"
            android:exported="true">
        </activity>
        
        <!-- Add service declaration -->
        <service
            android:name="id.flutter.flutter_background_service.BackgroundService"
            android:foregroundServiceType="dataSync"
            android:exported="false" />
            
    </application>
</manifest>
```

### Step 2: Foreground Service Types (Android 14+)

Choose the appropriate type based on your use case:

| Type | Permission | Use Case |
|------|------------|----------|
| `dataSync` | `FOREGROUND_SERVICE_DATA_SYNC` | Data synchronization |
| `location` | `FOREGROUND_SERVICE_LOCATION` | Location tracking |
| `mediaPlayback` | `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Media playback |
| `phoneCall` | `FOREGROUND_SERVICE_PHONE_CALL` | Phone/VoIP calls |
| `camera` | `FOREGROUND_SERVICE_CAMERA` | Camera access |
| `microphone` | `FOREGROUND_SERVICE_MICROPHONE` | Microphone access |

See [Android docs](https://developer.android.com/about/versions/14/changes/fgs-types-required) for full list.

### Step 3: Custom Notification Icon (Optional)

Create notification icon files named `ic_bg_service_small`:

**PNG Icons:**
- `android/app/src/main/res/drawable-mdpi/ic_bg_service_small.png` (24x24 dp)
- `android/app/src/main/res/drawable-hdpi/ic_bg_service_small.png` (36x36 dp)
- `android/app/src/main/res/drawable-xhdpi/ic_bg_service_small.png` (48x48 dp)
- `android/app/src/main/res/drawable-xxhdpi/ic_bg_service_small.png` (72x72 dp)
- `android/app/src/main/res/drawable-xxxhdpi/ic_bg_service_small.png` (96x96 dp)

**Vector Icon (Recommended):**
- `android/app/src/main/res/drawable-anydpi-v24/ic_bg_service_small.xml`

```xml
<!-- ic_bg_service_small.xml -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M12,2L2,12h3v8h6v-6h2v6h6v-8h3L12,2z"/>
</vector>
```

### Step 4: Update Gradle (If Needed)

Ensure your project uses these versions or higher:

```gradle
// android/build.gradle
buildscript {
    ext.kotlin_version = '1.8.10'
    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2'
    }
}
```

```properties
# android/gradle/wrapper/gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
```

## 🍎 iOS Configuration

### Step 1: Enable Background Modes

In Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select your target (Runner)
3. Go to Signing & Capabilities
4. Click + Capability
5. Add **Background Modes**
6. Check:
   - ☑️ Background fetch (for periodic updates)
   - ☑️ Remote notifications (if using push notifications)

### Step 2: Update Info.plist

```xml
<!-- ios/Runner/Info.plist -->
<dict>
    <!-- ... other keys ... -->
    
    <!-- Add background task identifier -->
    <key>BGTaskSchedulerPermittedIdentifiers</key>
    <array>
        <string>dev.flutter.background.refresh</string>
    </array>
    
    <!-- If using location -->
    <!-- <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>We need your location to provide location-based services</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We need your location to provide location-based services</string> -->
</dict>
```

### Step 3: Custom Task Identifier (Optional)

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
    // Set custom task identifier
    SwiftFlutterBackgroundServicePlugin.taskIdentifier = "com.yourapp.background.task"
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 🚀 Basic Implementation

### Step 1: Create Background Service Handler

```dart
import 'dart:async';
import 'package:app_core/app_core.dart';

/// Background service entry point
/// Must be top-level function with @pragma annotation
@pragma('vm:entry-point')
Future<void> onBackgroundServiceStart(ServiceInstance service) async {
  print('Background service started');

  // Listen for stop command
  service.on('stop').listen((data) async {
    print('Stopping service...');
    await service.stopSelf();
  });

  // Periodic task (every 10 seconds)
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (!(await service.isForegroundService())) {
      // Service stopped
      timer.cancel();
      return;
    }

    // Do your background work here
    print('Background task executed at ${DateTime.now()}');
    
    // Send update to UI
    service.invoke('update', {
      'timestamp': DateTime.now().toIso8601String(),
      'message': 'Task completed',
    });
  });
}
```

### Step 2: Configure in main()

```dart
import 'package:flutter/material.dart';
import 'package:app_core/app_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup DI
  await configureDependencies();
  
  // Get background service from DI
  final backgroundService = getIt<BackgroundService>();
  
  // Configure service
  final result = await backgroundService.configure(
    config: BackgroundServiceConfig(
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_app_bg_service',
      initialNotificationTitle: 'My App',
      initialNotificationContent: 'Background service is running',
      foregroundServiceNotificationId: 888,
    ),
    onStart: onBackgroundServiceStart,
  );
  
  result.fold(
    (failure) => print('Failed to configure: ${failure.message}'),
    (_) => print('Service configured successfully'),
  );
  
  runApp(MyApp());
}
```

### Step 3: Interact with Service in UI

```dart
import 'package:flutter/material.dart';
import 'package:app_core/app_core.dart';
import 'dart:async';

class BackgroundServicePage extends StatefulWidget {
  @override
  _BackgroundServicePageState createState() => _BackgroundServicePageState();
}

class _BackgroundServicePageState extends State<BackgroundServicePage> {
  final BackgroundService _service = getIt<BackgroundService>();
  StreamSubscription<BackgroundServiceData?>? _subscription;
  String _lastUpdate = 'No updates yet';

  @override
  void initState() {
    super.initState();
    
    // Listen for updates from service
    _subscription = _service.on('update').listen((data) {
      if (data?.payload != null) {
        setState(() {
          _lastUpdate = data!.payload!['message'] ?? 'Unknown';
        });
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
      (failure) => _showError(failure.message),
      (_) => _showSuccess('Service started'),
    );
  }

  Future<void> _stopService() async {
    final result = await _service.invoke('stop');
    result.fold(
      (failure) => _showError(failure.message),
      (_) => _showSuccess('Stop command sent'),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Background Service')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Last Update:', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text(_lastUpdate, style: Theme.of(context).textTheme.bodyLarge),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startService,
              child: Text('Start Service'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _stopService,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Stop Service'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔥 Advanced Usage

See [infrastructure/background_service/doc/README.md](/lib/src/infrastructure/background_service/doc/README.md) for:
- Custom notifications with flutter_local_notifications
- Background mode (no notification)
- Socket.io integration
- Real-time data synchronization
- Testing strategies

## ⚠️ Common Issues

### Service Not Starting

**Symptoms:** Service doesn't start or starts then immediately stops

**Solutions:**
1. Ensure `@pragma('vm:entry-point')` annotation on callback
2. Check permissions in AndroidManifest.xml
3. Test in **release mode** (background service behaves differently in debug)
4. Verify foreground service type matches permission

### Service Killed on Android

**Symptoms:** Service stops when app is closed or after some time

**Solutions:**
1. Use `isForegroundMode: true` (shows notification but reliable)
2. If using background mode, guide users to disable battery optimization
3. Some manufacturers (Xiaomi, Huawei) have aggressive battery savers
4. Add to battery optimization whitelist programmatically

### iOS Background Not Working

**Symptoms:** Background callbacks not executing on iOS

**Solutions:**
1. Remember: iOS has strict limitations (15-30 seconds max)
2. Background fetch only runs every ~15 minutes minimum
3. Test on real device (not simulator)
4. Consider using push notifications instead
5. iOS will suspend your app - this is expected behavior

### Notification Icon Not Showing

**Symptoms:** Default icon shown instead of custom icon

**Solutions:**
1. Ensure icon named exactly `ic_bg_service_small`
2. Icon must be white with transparent background
3. Place in correct drawable folders
4. Rebuild app completely

### Build Errors

**Symptoms:** Gradle or build errors

**Solutions:**
1. Update Gradle to 7.5 or higher
2. Update Kotlin to 1.8.10 or higher
3. Clean and rebuild: `flutter clean && flutter pub get`
4. Check Android SDK version (min SDK 24)

## 📚 Next Steps

- Read [Background Service Documentation](/lib/src/infrastructure/background_service/doc/README.md)
- Check [Example Implementation](/example/background_service_example.dart)
- Review [Project Guidelines](/PROJECT_GUIDELINES.md) for dependency independence principles

## 🆘 Support

For issues:
- Check [Common Issues](#common-issues)
- See [flutter_background_service issues](https://github.com/ekasetiawans/flutter_background_service/issues)
- Review Android/iOS platform documentation

---

**Important:** Always test background service in **release mode** on **real devices** for accurate behavior.


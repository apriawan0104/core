# AppDynamics Quick Start Guide

Get started with AppDynamics Mobile Real User Monitoring (RUM) in your Flutter app in minutes.

## 📋 Prerequisites

- Flutter app project
- AppDynamics EUM (End User Monitoring) account
- AppDynamics EUM App Key (get from AppDynamics dashboard)

## 🚀 Setup Steps

### 1. Add Dependency

Add `appdynamics_agent` to your `pubspec.yaml`:

```yaml
dependencies:
  appdynamics_agent: ^25.7.0
```

Run:
```bash
flutter pub get
```

### 2. Android Configuration

#### 2.1. Update `android/build.gradle`

Add the AppDynamics Gradle plugin to your project-level `build.gradle`:

```groovy
buildscript {
    dependencies {
        classpath "com.appdynamics:appdynamics-gradle-plugin:24.12.0"
        // ... other dependencies
    }
}
```

#### 2.2. Apply Plugin in `android/app/build.gradle`

Add at the bottom of your app-level `build.gradle`:

```groovy
dependencies {
    // ... project dependencies
}

// Bottom of file
apply plugin: 'adeum'
```

#### 2.3. Add Permissions to `AndroidManifest.xml`

Add these permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.myawesomepackage">

    <!-- Add these two permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application>
        <!-- other settings -->
    </application>
</manifest>
```

### 3. iOS Configuration

No additional configuration needed for iOS! The AppDynamics SDK handles everything automatically.

### 4. Initialize AppDynamics

In your `main.dart` or app initialization code:

```dart
import 'package:flutter/material.dart';
import 'package:app_core/app_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AppDynamics
  final appDynamics = AppDynamicsAgentServiceImpl();
  final config = AppDynamicsConfig(
    appKey: 'YOUR_EUM_APP_KEY', // Replace with your AppDynamics EUM App Key
    loggingLevel: AppDynamicsLoggingLevel.verbose, // For debugging
  );

  final result = await appDynamics.initialize(config);
  result.fold(
    (failure) {
      print('Failed to initialize AppDynamics: $failure');
      // Handle initialization failure
    },
    (_) {
      print('AppDynamics initialized successfully');
    },
  );

  runApp(const MyApp());
}
```

### 5. Register in Dependency Injection (Optional but Recommended)

If you're using dependency injection (e.g., GetIt):

```dart
import 'package:get_it/get_it.dart';
import 'package:app_core/app_core.dart';

final getIt = GetIt.instance;

void setupAppDynamics() {
  getIt.registerLazySingleton<AppDynamicsService>(
    () => AppDynamicsAgentServiceImpl(),
  );
}

// In your app initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  setupAppDynamics();
  
  final appDynamics = getIt<AppDynamicsService>();
  final config = AppDynamicsConfig(
    appKey: 'YOUR_EUM_APP_KEY',
    loggingLevel: AppDynamicsLoggingLevel.verbose,
  );
  
  await appDynamics.initialize(config);
  
  runApp(const MyApp());
}
```

## ✅ Verification

After setup, you should see AppDynamics logs in your console:

```
AppDynamics initialized successfully
```

Check your AppDynamics dashboard to see if data is being received.

## 🎯 Next Steps

- Read the [README.md](README.md) for detailed documentation
- Learn about [Session Frames](#session-frames) for tracking user flows
- Learn about [Breadcrumbs](#breadcrumbs) for tracking user interactions
- Learn about [Custom Metrics](#custom-metrics) for business metrics

## 📚 Common Use Cases

### Track Errors

```dart
try {
  // Your code
} catch (e, stackTrace) {
  await appDynamics.reportError(
    'Failed to process payment',
    stackTrace: stackTrace,
    properties: {'order_id': '12345'},
  );
}
```

### Track Custom Metrics

```dart
final startTime = DateTime.now();
// ... perform operation ...
final duration = DateTime.now().difference(startTime).inMilliseconds;

await appDynamics.reportMetric(
  'checkout_duration',
  duration.toDouble(),
  unit: 'ms',
  properties: {'payment_method': 'credit_card'},
);
```

### Track User Flows with Session Frames

```dart
// Start tracking checkout process
final frame = await appDynamics.startSessionFrame(
  'checkout_process',
  properties: {'user_id': '123'},
);

try {
  await addToCart();
  await selectPaymentMethod();
  await completePurchase();
  
  await appDynamics.updateSessionFrame(frame, {
    'items_count': 3,
    'total_amount': 99.99,
  });
} finally {
  // Always end the frame
  await appDynamics.endSessionFrame(frame);
}
```

### Track User Interactions with Breadcrumbs

```dart
await appDynamics.leaveBreadcrumb(
  AppDynamicsBreadcrumb(
    message: 'User clicked submit button',
    level: AppDynamicsBreadcrumbLevel.info,
    category: 'user_action',
    properties: {'button_id': 'submit', 'screen': 'checkout'},
  ),
);
```

## 🔧 Configuration Options

### Production Configuration

```dart
final config = AppDynamicsConfig.production(
  appKey: 'YOUR_EUM_APP_KEY',
  collectorURL: 'https://your-collector-url.com', // Optional, for on-premises
);
```

### Development Configuration

```dart
final config = AppDynamicsConfig.development(
  appKey: 'YOUR_EUM_APP_KEY',
  collectorURL: 'https://your-collector-url.com', // Optional
);
```

### Minimal Configuration

```dart
final config = AppDynamicsConfig.minimal(
  appKey: 'YOUR_EUM_APP_KEY',
);
```

## 🐛 Troubleshooting

### AppDynamics Not Initializing

1. Check that your `appKey` is correct
2. Verify Android permissions are added
3. Check console logs for error messages
4. Ensure `WidgetsFlutterBinding.ensureInitialized()` is called before initialization

### No Data in AppDynamics Dashboard

1. Wait a few minutes (data may take time to appear)
2. Check network connectivity
3. Verify app key is correct
4. Check if logging level is set to `verbose` for debugging

### Android Build Errors

1. Ensure Gradle plugin version matches: `24.12.0`
2. Verify `apply plugin: 'adeum'` is at the bottom of `build.gradle`
3. Clean and rebuild: `flutter clean && flutter pub get`

## 📖 More Information

- [AppDynamics Official Docs](https://docs.appdynamics.com/)
- [AppDynamics Flutter Plugin](https://pub.dev/packages/appdynamics_agent)
- [Full Documentation](README.md)


# HTTP Inspector Setup Guide

Complete setup guide for integrating HTTP Inspector into your Flutter application using BUMA Core.

## 📋 Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Basic Setup](#basic-setup)
- [HTTP Client Integration](#http-client-integration)
- [Configuration](#configuration)
- [Platform-Specific Setup](#platform-specific-setup)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)

## Overview

HTTP Inspector provides real-time inspection of HTTP(S) requests and responses in your Flutter app. It shows in-app notifications, stores data locally, and provides a beautiful UI for viewing and sharing network traffic.

### Features

- ✅ Works with Dio, http package, and Chopper
- ✅ In-app notifications for all requests
- ✅ Beautiful inspection UI with JSON formatting
- ✅ Request/response sharing
- ✅ Cross-platform support
- ✅ Zero configuration required
- ✅ **Dependency independent** - easy to swap implementations

## Installation

HTTP Inspector is already included in BUMA Core via `chucker_flutter`. No additional dependencies needed!

## Basic Setup

### Step 1: Initialize the Service

In your `main.dart`:

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize HTTP Inspector
  final httpInspector = ChuckerHttpInspectorServiceImpl();
  await httpInspector.initialize(
    const HttpInspectorConfig(
      showNotifications: true,
      showOnRelease: false, // IMPORTANT: Keep false for production!
    ),
  );
  
  // Register in DI container
  GetIt.instance.registerSingleton<HttpInspectorService>(httpInspector);
  
  runApp(const MyApp());
}
```

### Step 2: Add Navigator Observer

In your `MaterialApp`:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final httpInspector = GetIt.instance<HttpInspectorService>();
    
    return MaterialApp(
      title: 'My App',
      navigatorObservers: [
        httpInspector.getNavigatorObserver(),
      ],
      home: const HomePage(),
    );
  }
}
```

## HTTP Client Integration

Choose your HTTP client and follow the appropriate setup:

### Option 1: Dio (Recommended)

```dart
import 'package:dio/dio.dart';
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

class NetworkService {
  late final Dio _dio;
  
  NetworkService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.yourapp.com',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    
    // Add HTTP Inspector interceptor
    final httpInspector = GetIt.instance<HttpInspectorService>();
    final interceptorResult = httpInspector.getDioInterceptor();
    
    interceptorResult.fold(
      (failure) {
        // Handle error (optional)
        debugPrint('Failed to add HTTP Inspector: $failure');
      },
      (interceptor) {
        _dio.interceptors.add(interceptor);
      },
    );
    
    // Add other interceptors
    _dio.interceptors.addAll([
      // Your custom interceptors
    ]);
  }
  
  Future<Response> get(String path) => _dio.get(path);
  Future<Response> post(String path, {dynamic data}) => _dio.post(path, data: data);
}
```

### Option 2: http Package

```dart
import 'package:http/http.dart' as http;
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

class NetworkService {
  late final http.Client _client;
  
  NetworkService() {
    final httpInspector = GetIt.instance<HttpInspectorService>();
    final clientResult = httpInspector.getHttpClient(http.Client());
    
    _client = clientResult.fold(
      (failure) {
        debugPrint('Failed to wrap http client: $failure');
        return http.Client(); // Fallback to normal client
      },
      (wrappedClient) => wrappedClient,
    );
  }
  
  Future<http.Response> get(String url) async {
    return await _client.get(Uri.parse(url));
  }
  
  Future<http.Response> post(String url, {dynamic body}) async {
    return await _client.post(
      Uri.parse(url),
      body: body,
      headers: {'Content-Type': 'application/json'},
    );
  }
  
  void dispose() {
    _client.close();
  }
}
```

### Option 3: Chopper

```dart
import 'package:chopper/chopper.dart';
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

ChopperClient createChopperClient() {
  final httpInspector = GetIt.instance<HttpInspectorService>();
  final interceptorResult = httpInspector.getChopperInterceptor();
  
  return ChopperClient(
    baseUrl: Uri.parse('https://api.yourapp.com'),
    services: [
      // Your Chopper services
      // _$UserService(),
      // _$PostService(),
    ],
    interceptors: [
      // Add HTTP Inspector interceptor
      if (interceptorResult.isRight())
        interceptorResult.getOrElse(() => null),
      
      // Add other interceptors
      // HttpLoggingInterceptor(),
    ],
    converter: const JsonConverter(),
  );
}
```

## Configuration

Customize HTTP Inspector behavior with `HttpInspectorConfig`:

```dart
HttpInspectorConfig(
  // Show in-app notifications for requests
  showNotifications: true,
  
  // Enable in release mode (⚠️ NOT RECOMMENDED for production)
  showOnRelease: false,
  
  // Only show requests with errors (4xx, 5xx status codes)
  showOnlyErrors: false,
  
  // Maximum content length to display (in bytes)
  maxContentLength: 250000,
  
  // Headers to hide for security (won't be shown in UI)
  headersToHide: [
    'authorization',
    'cookie',
    'set-cookie',
    'api-key',
    'x-api-key',
    'access-token',
    'refresh-token',
  ],
  
  // Custom notification title
  notificationTitle: 'API Inspector',
  
  // Encrypt stored request/response data
  encryptStorage: false,
  
  // Show image URL previews in inspector
  showImagePreview: true,
  
  // Enable sharing of request/response data
  enableSharing: true,
  
  // Maximum number of requests to store locally
  maxRequestsToStore: 100,
  
  // Automatically clear old requests when limit is reached
  autoClearOldRequests: true,
)
```

### Common Configurations

#### Development (Default)

```dart
const HttpInspectorConfig(
  showNotifications: true,
  showOnRelease: false,
  showOnlyErrors: false,
)
```

#### Testing (Errors Only)

```dart
const HttpInspectorConfig(
  showNotifications: true,
  showOnRelease: false,
  showOnlyErrors: true, // Only show errors
)
```

#### Production (Disabled)

```dart
const HttpInspectorConfig(
  showNotifications: false,
  showOnRelease: false, // NEVER enable in production!
)
```

## Platform-Specific Setup

### Android

Update `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        applicationId "com.yourcompany.yourapp"
        minSdkVersion 22  // Required: Must be at least 22
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
}
```

### iOS

No additional setup required! ✅

### Web

No additional setup required! ✅

### Windows

No additional setup required! ✅

### macOS

No additional setup required! ✅

### Linux

No additional setup required! ✅

## Advanced Usage

### Update Configuration at Runtime

```dart
final httpInspector = GetIt.instance<HttpInspectorService>();

// Get current config
final currentConfig = httpInspector.getConfig().getOrElse(
  () => const HttpInspectorConfig(),
);

// Update config
await httpInspector.updateConfig(
  currentConfig.copyWith(
    showOnlyErrors: true,
    maxContentLength: 500000,
  ),
);
```

### Enable/Disable Dynamically

```dart
final httpInspector = GetIt.instance<HttpInspectorService>();

// Disable temporarily
await httpInspector.setEnabled(false);

// Check if enabled
if (httpInspector.isEnabled()) {
  print('Inspector is active');
}

// Re-enable
await httpInspector.setEnabled(true);
```

### Clear Stored Data

```dart
final httpInspector = GetIt.instance<HttpInspectorService>();

final result = await httpInspector.clearData();
result.fold(
  (failure) => print('Failed to clear: $failure'),
  (_) => print('Data cleared successfully'),
);
```

### Show Inspector UI Manually

#### Option 1: Use Pre-built Widget (Recommended)

```dart
// Add as FloatingActionButton
Scaffold(
  appBar: AppBar(title: Text('My App')),
  body: MyContent(),
  floatingActionButton: HttpInspectorButton(),
)
```

#### Option 2: With Label

```dart
Scaffold(
  floatingActionButton: HttpInspectorButton(
    label: 'Inspector',
    icon: Icons.network_check,
  ),
)
```

#### Option 3: Draggable Overlay

```dart
MaterialApp(
  home: HttpInspectorOverlay(
    child: MyHomePage(),
  ),
)
```

#### Option 4: Custom Button

```dart
// Add a custom debug button
ElevatedButton(
  onPressed: () async {
    final httpInspector = GetIt.instance<HttpInspectorService>();
    await httpInspector.showInspectorUI(context);
  },
  child: const Text('Open HTTP Inspector'),
)
```

### Environment-Based Configuration

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Different config based on environment
  final config = kDebugMode
      ? const HttpInspectorConfig(
          showNotifications: true,
          showOnRelease: false,
        )
      : const HttpInspectorConfig(
          showNotifications: false,
          showOnRelease: false,
        );
  
  final httpInspector = ChuckerHttpInspectorServiceImpl();
  await httpInspector.initialize(config);
  
  GetIt.instance.registerSingleton<HttpInspectorService>(httpInspector);
  
  runApp(const MyApp());
}
```

## Troubleshooting

### Issue: Android Build Error (minSdkVersion)

**Error:**
```
Manifest merger failed : uses-sdk:minSdkVersion 21 cannot be smaller than version 22
```

**Solution:**
Update `android/app/build.gradle`:
```gradle
defaultConfig {
    minSdkVersion 22  // Change from 21 (or lower)
}
```

### Issue: Notifications Not Showing

**Possible Causes:**
1. `showNotifications` is `false` in config
2. Navigator observer not added
3. Inspector not initialized

**Solution:**
```dart
// Verify config
final config = httpInspector.getConfig().getOrElse(
  () => const HttpInspectorConfig(),
);
print('Notifications enabled: ${config.showNotifications}');

// Verify observer is added
MaterialApp(
  navigatorObservers: [httpInspector.getNavigatorObserver()],
  // ...
);
```

### Issue: Interceptor Not Working

**Possible Causes:**
1. Interceptor added after requests started
2. Inspector not initialized
3. Inspector disabled

**Solution:**
```dart
// Initialize before making requests
await httpInspector.initialize(config);

// Check if enabled
if (!httpInspector.isEnabled()) {
  await httpInspector.setEnabled(true);
}

// Verify interceptor was added
final result = httpInspector.getDioInterceptor();
result.fold(
  (failure) => print('Error: $failure'),
  (interceptor) => dio.interceptors.add(interceptor),
);
```

### Issue: UI Not Opening

**Cause:**
Chucker Flutter primarily uses notifications for navigation. Manual UI opening may have limited support.

**Solution:**
1. Tap on the notification's "Details" button
2. Ensure navigator observer is properly registered
3. Check if requests are being captured first

## Best Practices

1. **Security First**
   ```dart
   HttpInspectorConfig(
     showOnRelease: false, // NEVER enable in production
     headersToHide: ['authorization', 'api-key'], // Hide sensitive headers
     encryptStorage: true, // Encrypt stored data
   )
   ```

2. **Performance**
   ```dart
   HttpInspectorConfig(
     maxRequestsToStore: 50, // Limit storage
     autoClearOldRequests: true, // Auto-cleanup
     maxContentLength: 100000, // Limit content size
   )
   ```

3. **Testing**
   ```dart
   HttpInspectorConfig(
     showOnlyErrors: true, // Focus on errors during testing
   )
   ```

4. **Dependency Injection**
   ```dart
   // Register as singleton for easy access
   GetIt.instance.registerSingleton<HttpInspectorService>(httpInspector);
   
   // Access anywhere
   final inspector = GetIt.instance<HttpInspectorService>();
   ```

## Related Documentation

- [Quick Start Guide](lib/src/infrastructure/http_inspector/doc/QUICK_START.md)
- [README](lib/src/infrastructure/http_inspector/doc/README.md)
- [Example Code](example/http_inspector_example.dart)
- [Architecture Documentation](ARCHITECTURE.md)

## External Resources

- [Chucker Flutter Package](https://pub.dev/packages/chucker_flutter)
- [Chucker Android (Original)](https://github.com/ChuckerTeam/chucker)
- [Dio Documentation](https://pub.dev/packages/dio)
- [http Package Documentation](https://pub.dev/packages/http)

---

**Need Help?** Check the [example app](example/http_inspector_example.dart) or review the [API documentation](lib/src/infrastructure/http_inspector/contract/http_inspector.service.dart).


# HTTP Inspector Service

HTTP Inspector is a powerful debugging tool that helps you inspect HTTP(S) requests and responses in your Flutter application. It provides an intuitive interface to monitor, analyze, and share network traffic.

## 🎯 Purpose

The HTTP Inspector Service provides:
- Real-time HTTP request/response inspection
- In-app notifications for network calls
- Beautiful UI for viewing network traffic
- Request/response sharing capabilities
- Support for multiple HTTP clients (Dio, http, Chopper)
- Cross-platform support (Android, iOS, Web, Windows, macOS, Linux)

## 🏗️ Architecture

Following BUMA Core's **Dependency Independence** principle, this service is designed to be implementation-agnostic:

```
HttpInspectorService (Abstract Interface)
    ↓
ChuckerHttpInspectorServiceImpl (Chucker implementation)
AliceHttpInspectorServiceImpl (Alternative implementation)
CustomHttpInspectorServiceImpl (Your custom implementation)
```

### Why This Matters

You can easily switch from Chucker to Alice or any other inspector tool:

```dart
// Before: Using Chucker
getIt.registerLazySingleton<HttpInspectorService>(
  () => ChuckerHttpInspectorServiceImpl(),
);

// After: Using Alice (just change one line!)
getIt.registerLazySingleton<HttpInspectorService>(
  () => AliceHttpInspectorServiceImpl(),
);

// Your business logic remains unchanged! ✅
```

## 📦 Current Implementation

The default implementation uses [chucker_flutter](https://pub.dev/packages/chucker_flutter), which is inspired by Chucker Android.

### Features

- ✅ Works with Dio, http package, and Chopper
- ✅ In-app notifications for requests
- ✅ Local data storage
- ✅ Beautiful inspection UI
- ✅ Request/response sharing
- ✅ JSON formatting and syntax highlighting
- ✅ Image URL preview
- ✅ Search and filter capabilities
- ✅ Works on all platforms

## 🚀 Quick Start

### 1. Initialize the Service

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize HTTP Inspector
  final httpInspector = ChuckerHttpInspectorServiceImpl();
  await httpInspector.initialize(
    HttpInspectorConfig(
      showNotifications: true,
      showOnRelease: false, // Only show in debug mode
      showOnlyErrors: false, // Show all requests
    ),
  );
  
  runApp(MyApp());
}
```

### 2. Setup with Your HTTP Client

#### For Dio

```dart
final dio = Dio();

// Get Dio interceptor
final result = httpInspector.getDioInterceptor();
result.fold(
  (failure) => print('Failed to get interceptor: $failure'),
  (interceptor) => dio.interceptors.add(interceptor),
);
```

#### For http package

```dart
import 'package:http/http.dart' as http;

// Wrap your http client
final result = httpInspector.getHttpClient(http.Client());
final client = result.getOrElse(() => http.Client());

// Use the wrapped client
final response = await client.get(Uri.parse('https://api.example.com'));
```

#### For Chopper

```dart
final result = httpInspector.getChopperInterceptor();

final chopperClient = ChopperClient(
  baseUrl: Uri.parse('https://api.example.com'),
  interceptors: [
    result.getOrElse(() => null),
  ],
);
```

### 3. Add Navigator Observer

```dart
MaterialApp(
  navigatorObservers: [
    httpInspector.getNavigatorObserver(),
  ],
  home: MyHomePage(),
);
```

### 4. Show Inspector UI Manually (Optional)

```dart
// Add a debug button in your app
ElevatedButton(
  onPressed: () async {
    await httpInspector.showInspectorUI(context);
  },
  child: Text('Show HTTP Inspector'),
);
```

## 🔧 Configuration

The `HttpInspectorConfig` allows you to customize the inspector behavior:

```dart
HttpInspectorConfig(
  // Show notifications for each request
  showNotifications: true,
  
  // Enable inspector in release mode
  showOnRelease: false,
  
  // Only show requests with errors (4xx, 5xx)
  showOnlyErrors: false,
  
  // Maximum content length to display
  maxContentLength: 250000,
  
  // Headers to hide (for security)
  headersToHide: [
    'authorization',
    'api-key',
    'access-token',
  ],
  
  // Custom notification title
  notificationTitle: 'API Inspector',
  
  // Enable body encryption in storage
  encryptStorage: false,
  
  // Show image previews
  showImagePreview: true,
  
  // Enable sharing functionality
  enableSharing: true,
  
  // Max requests to store
  maxRequestsToStore: 100,
  
  // Auto-clear old requests
  autoClearOldRequests: true,
);
```

## 📱 Platform-Specific Setup

### Android

Update your `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 22  // Required for Chucker
    }
}
```

### iOS, Web, Windows, macOS, Linux

No additional setup required! 🎉

## 🎯 Advanced Usage

### Update Configuration at Runtime

```dart
final result = await httpInspector.updateConfig(
  config.copyWith(showOnlyErrors: true),
);
```

### Clear Stored Data

```dart
final result = await httpInspector.clearData();
result.fold(
  (failure) => print('Failed to clear data: $failure'),
  (_) => print('Data cleared successfully'),
);
```

### Enable/Disable Dynamically

```dart
// Disable inspector
await httpInspector.setEnabled(false);

// Check if enabled
if (httpInspector.isEnabled()) {
  print('Inspector is active');
}

// Re-enable
await httpInspector.setEnabled(true);
```

### Get Current Configuration

```dart
final result = httpInspector.getConfig();
result.fold(
  (failure) => print('Failed to get config: $failure'),
  (config) => print('Current config: $config'),
);
```

## 🧪 Testing

The abstraction makes testing easy:

```dart
class MockHttpInspectorService implements HttpInspectorService {
  @override
  Future<Either<Failure, void>> initialize(HttpInspectorConfig config) async {
    return right(null);
  }
  
  @override
  Either<Failure, dynamic> getDioInterceptor() {
    return right(MockDioInterceptor());
  }
  
  // ... implement other methods
}

// Use in tests
final mockInspector = MockHttpInspectorService();
```

## 🔄 Switching Implementations

Want to use a different inspector? Just create a new implementation:

```dart
class AliceHttpInspectorServiceImpl implements HttpInspectorService {
  final Alice _alice = Alice();
  
  @override
  Future<Either<Failure, void>> initialize(HttpInspectorConfig config) async {
    // Initialize Alice
    return right(null);
  }
  
  @override
  Either<Failure, dynamic> getDioInterceptor() {
    return right(_alice.getDioInterceptor());
  }
  
  // ... implement other methods
}

// Register in DI
getIt.registerLazySingleton<HttpInspectorService>(
  () => AliceHttpInspectorServiceImpl(),
);

// Your app code doesn't change! 🎉
```

## ⚠️ Important Notes

### Security Considerations

1. **Never enable in production** (set `showOnRelease: false`)
2. **Hide sensitive headers** (use `headersToHide`)
3. **Clear data regularly** if storing sensitive information
4. **Consider encrypting storage** (set `encryptStorage: true`)

### Performance

- Inspector has minimal performance impact
- Data is stored locally (not transmitted)
- Auto-clear feature prevents excessive storage usage
- Disable when not needed for optimal performance

### Limitations

- Some Chucker features require manual navigation through notifications
- Clearing data might require using Chucker's UI
- Image preview depends on content type

## 🔗 Related Documentation

- [Quick Start Guide](./QUICK_START.md)
- [Architecture Documentation](../../../../ARCHITECTURE.md)
- [Network Service](../../network/doc/README.md)
- [API Documentation](https://pub.dev/documentation/chucker_flutter/latest/)

## 📚 Resources

- [Chucker Flutter Package](https://pub.dev/packages/chucker_flutter)
- [Chucker Android (Original)](https://github.com/ChuckerTeam/chucker)
- [HTTP Inspector Service Contract](../contract/http_inspector.service.dart)

## 🤝 Contributing

When contributing to the HTTP Inspector service:

1. **Maintain abstraction** - Don't expose implementation details
2. **Follow DIP** - Depend on interfaces, not implementations
3. **Test thoroughly** - Test with different HTTP clients
4. **Document clearly** - Update docs for any changes
5. **Consider security** - Always think about sensitive data

## 📝 License

This service follows the BUMA Core library license.

---

**Remember**: The goal is to provide a powerful debugging tool while maintaining **dependency independence** and **flexibility**. Keep the abstraction clean and the implementations swappable! 🚀


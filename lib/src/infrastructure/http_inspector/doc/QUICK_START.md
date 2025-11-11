# HTTP Inspector - Quick Start Guide

Get up and running with HTTP Inspector in less than 5 minutes! 🚀

## Prerequisites

- Flutter project with BUMA Core library
- Android minSdkVersion 22+ (for Android apps)

## Installation

The `chucker_flutter` package is already included in BUMA Core. No additional installation needed!

## Setup Steps

### Step 1: Initialize (30 seconds)

In your `main.dart`:

```dart
import 'package:app_core/app_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize HTTP Inspector
  final httpInspector = ChuckerHttpInspectorServiceImpl();
  await httpInspector.initialize(
    const HttpInspectorConfig(
      showNotifications: true,
      showOnRelease: false,
    ),
  );
  
  // Store in DI container (recommended)
  GetIt.instance.registerSingleton<HttpInspectorService>(httpInspector);
  
  runApp(const MyApp());
}
```

### Step 2: Add Navigator Observer (10 seconds)

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

### Step 3: Setup Your HTTP Client (1 minute)

Choose your HTTP client:

#### Option A: Dio (Most Common)

```dart
import 'package:dio/dio.dart';
import 'package:app_core/app_core.dart';

class ApiClient {
  late final Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.example.com',
    ));
    
    // Add HTTP Inspector interceptor
    final httpInspector = GetIt.instance<HttpInspectorService>();
    final result = httpInspector.getDioInterceptor();
    result.fold(
      (failure) => print('Inspector error: $failure'),
      (interceptor) => _dio.interceptors.add(interceptor),
    );
  }
  
  Future<Response> fetchData() async {
    return await _dio.get('/data');
  }
}
```

#### Option B: http package

```dart
import 'package:http/http.dart' as http;
import 'package:app_core/app_core.dart';

class ApiClient {
  late final http.Client _client;
  
  ApiClient() {
    final httpInspector = GetIt.instance<HttpInspectorService>();
    final result = httpInspector.getHttpClient(http.Client());
    _client = result.getOrElse(() => http.Client());
  }
  
  Future<http.Response> fetchData() async {
    return await _client.get(
      Uri.parse('https://api.example.com/data'),
    );
  }
}
```

#### Option C: Chopper

```dart
import 'package:chopper/chopper.dart';
import 'package:app_core/app_core.dart';

ChopperClient createChopperClient() {
  final httpInspector = GetIt.instance<HttpInspectorService>();
  final interceptorResult = httpInspector.getChopperInterceptor();
  
  return ChopperClient(
    baseUrl: Uri.parse('https://api.example.com'),
    services: [
      // Your Chopper services
    ],
    interceptors: [
      interceptorResult.getOrElse(() => null),
    ],
  );
}
```

## That's It! 🎉

You're ready to inspect HTTP requests. Now:

1. **Run your app**
2. **Make an API call**
3. **See the notification** appear
4. **Tap "Details"** to view the request/response

## Usage Tips

### View All Requests

When you tap the notification's "Details" button, you'll see:
- Request URL, method, headers, body
- Response status, headers, body
- Response time and size
- Beautiful JSON formatting
- Image previews (for image URLs)

### Search & Filter

In the inspector UI:
- Search by URL
- Filter by status code
- Sort by time
- Clear all data

### Share Requests

Long-press or use the share button to:
- Share request details
- Copy cURL command
- Export as text

## Customize (Optional)

### Show Only Errors

```dart
HttpInspectorConfig(
  showOnlyErrors: true, // Only show 4xx and 5xx
)
```

### Hide Sensitive Headers

```dart
HttpInspectorConfig(
  headersToHide: [
    'authorization',
    'api-key',
    'x-api-token',
  ],
)
```

### Custom Notification Title

```dart
HttpInspectorConfig(
  notificationTitle: 'API Debugger',
)
```

## Troubleshooting

### Android: minSdkVersion Error

**Error**: "Manifest merger failed"

**Fix**: In `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdkVersion 22  // Change from lower version
    }
}
```

### Not Seeing Notifications

**Possible causes**:
1. `showNotifications` is `false` in config
2. Navigator observer not added to MaterialApp
3. Inspector not initialized

**Fix**:
```dart
// Check config
final result = httpInspector.getConfig();
result.fold(
  (failure) => print('Error: $failure'),
  (config) => print('Notifications: ${config.showNotifications}'),
);
```

### Interceptor Not Working

**Possible causes**:
1. Interceptor added after requests started
2. Inspector not initialized
3. Inspector disabled

**Fix**:
```dart
// Check if enabled
if (!httpInspector.isEnabled()) {
  await httpInspector.setEnabled(true);
}
```

## Advanced Features

### Manual UI Opening

Add a debug button:

```dart
ElevatedButton(
  onPressed: () async {
    final httpInspector = GetIt.instance<HttpInspectorService>();
    await httpInspector.showInspectorUI(context);
  },
  child: const Text('Open HTTP Inspector'),
)
```

### Enable in Release Mode (Not Recommended)

```dart
HttpInspectorConfig(
  showOnRelease: true, // ⚠️ Use with caution!
)
```

### Clear Data Programmatically

```dart
final result = await httpInspector.clearData();
result.fold(
  (failure) => print('Failed to clear: $failure'),
  (_) => print('Data cleared'),
);
```

### Toggle at Runtime

```dart
// Disable temporarily
await httpInspector.setEnabled(false);

// Re-enable
await httpInspector.setEnabled(true);
```

## Example App

Check out the complete example:

```dart
// example/http_inspector_example.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize
  final httpInspector = ChuckerHttpInspectorServiceImpl();
  await httpInspector.initialize(const HttpInspectorConfig());
  GetIt.instance.registerSingleton<HttpInspectorService>(httpInspector);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [
        GetIt.instance<HttpInspectorService>().getNavigatorObserver(),
      ],
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _makeRequest() async {
    final dio = Dio();
    final inspector = GetIt.instance<HttpInspectorService>();
    
    // Add interceptor
    final result = inspector.getDioInterceptor();
    result.fold(
      (failure) => print('Error: $failure'),
      (interceptor) => dio.interceptors.add(interceptor),
    );
    
    // Make request
    try {
      await dio.get('https://jsonplaceholder.typicode.com/posts/1');
    } catch (e) {
      print('Request failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HTTP Inspector Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: _makeRequest,
          child: const Text('Make API Request'),
        ),
      ),
    );
  }
}
```

## Next Steps

- Read the [full documentation](./README.md)
- Explore [configuration options](../models/http_inspector_config.model.dart)
- Check the [example file](../../../../example/http_inspector_example.dart)
- Learn about [dependency independence](../../../../ARCHITECTURE.md)

## Need Help?

- Review the [Chucker Flutter documentation](https://pub.dev/packages/chucker_flutter)
- Check [common issues](./README.md#-important-notes)
- See the [contract definition](../contract/http_inspector.service.dart)

---

Happy debugging! 🐛🔍


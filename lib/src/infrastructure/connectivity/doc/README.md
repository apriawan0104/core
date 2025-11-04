# Connectivity Service

A robust, dependency-independent connectivity checking service for Flutter applications. This service provides **real** internet connectivity checking, not just Wi-Fi or mobile data connection status.

## 🎯 Why This Service?

Most connectivity packages only check if your device is connected to Wi-Fi or mobile network, but they **don't verify if there's actual internet access**. This leads to false positives where your app thinks it's online but can't actually reach the internet.

### Common Problem:
```dart
// ❌ This only checks Wi-Fi/Mobile connection, NOT internet access!
final connectivityResult = await Connectivity().checkConnectivity();
if (connectivityResult == ConnectivityResult.wifi) {
  // This could be true even with no internet! 🚫
  // User might be connected to a router with no internet
}
```

### Our Solution:
```dart
// ✅ This checks ACTUAL internet connectivity by pinging real endpoints
final result = await connectivity.hasInternetConnection();
result.fold(
  (failure) => print('Check failed'),
  (isConnected) {
    if (isConnected) {
      // Guaranteed internet access! ✅
    }
  },
);
```

## ✨ Features

- ✅ **Real Internet Checking**: Verifies actual internet access, not just network connection
- ⚡ **Subsecond Response Times**: Fast checks even on mobile networks
- 🔄 **Live Status Monitoring**: Stream of connectivity changes in real-time
- 🎛️ **Customizable Endpoints**: Check connectivity to your own servers
- ⏱️ **Configurable Intervals**: Control how often connectivity is checked
- ⏸️ **Lifecycle Management**: Pause/resume monitoring to save battery
- 🌐 **Cross-Platform**: Works on Android, iOS, macOS, Linux, Windows, Web
- 🔌 **Dependency Independent**: Easy to swap implementations

## 📦 Installation

### 1. Add dependency to `pubspec.yaml`

```yaml
dependencies:
  app_core: ^x.x.x  # Your core library version
```

### 2. Import the package

```dart
import 'package:app_core/app_core.dart';
```

### 3. Register in Dependency Injection

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDI() {
  // Register ConnectivityService
  getIt.registerLazySingleton<ConnectivityService>(
    () => InternetConnectionCheckerPlusServiceImpl(),
  );
}
```

## 🚀 Basic Usage

### One-Time Connectivity Check

```dart
final connectivity = getIt<ConnectivityService>();

// Initialize first
await connectivity.initialize();

// Check connection
final result = await connectivity.hasInternetConnection();
result.fold(
  (failure) {
    // Handle error
    print('Failed to check: ${failure.message}');
  },
  (isConnected) {
    if (isConnected) {
      // Internet is available
      print('Online! 🌐');
    } else {
      // No internet
      print('Offline! 📵');
    }
  },
);
```

### Listen to Connectivity Changes

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription<ConnectivityStatusEntity> _subscription;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    
    final connectivity = getIt<ConnectivityService>();
    
    // Listen to connectivity changes
    _subscription = connectivity.onConnectivityChanged.listen((status) {
      setState(() {
        _isOnline = status.isConnected;
      });
      
      if (status.isConnected) {
        // Internet available - sync data
        _syncData();
      } else {
        // No internet - show offline UI
        _showOfflineUI();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isOnline 
        ? OnlineContent() 
        : OfflineContent(),
    );
  }
}
```

### Get Current Status (Synchronous)

```dart
final connectivity = getIt<ConnectivityService>();

// Get last known status without making a new check
final status = connectivity.currentStatus;
final isConnected = connectivity.isConnected;

if (isConnected ?? false) {
  // Safe to make network requests
  fetchData();
}
```

## 🎛️ Advanced Usage

### Custom Check Endpoints

Check connectivity to your own API servers:

```dart
await connectivity.initialize(
  checkOptions: [
    ConnectivityCheckOptionEntity(
      uri: Uri.parse('https://api.myapp.com/health'),
      timeout: Duration(seconds: 5),
    ),
    ConnectivityCheckOptionEntity(
      uri: Uri.parse('https://backup-api.myapp.com/health'),
      timeout: Duration(seconds: 5),
    ),
  ],
);
```

### Custom Success Criteria

Define what counts as a successful connectivity check:

```dart
await connectivity.initialize(
  checkOptions: [
    ConnectivityCheckOptionEntity(
      uri: Uri.parse('https://api.myapp.com/ping'),
      timeout: Duration(seconds: 5),
      responseStatusFn: (statusCode, headers, body) {
        // Custom success logic
        return statusCode >= 200 && statusCode < 300;
      },
    ),
  ],
);
```

### Configurable Check Intervals

```dart
// Check every 5 seconds (more frequent)
await connectivity.initialize(
  checkInterval: Duration(seconds: 5),
);

// Change interval at runtime
connectivity.updateCheckInterval(Duration(seconds: 30));
```

### Lifecycle Management (Pause/Resume)

Save battery when app is in background:

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late ConnectivityService _connectivity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectivity = getIt<ConnectivityService>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App goes to background - pause connectivity checks
      _connectivity.pause();
    } else if (state == AppLifecycleState.resumed) {
      // App comes to foreground - resume connectivity checks
      _connectivity.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}
```

### Dynamic Check Endpoints

Update endpoints at runtime:

```dart
// Start with default endpoints
await connectivity.initialize();

// Later, switch to check your own servers
connectivity.updateCheckOptions([
  ConnectivityCheckOptionEntity(
    uri: Uri.parse('https://api.myapp.com/health'),
  ),
]);
```

## 🎨 UI Integration Examples

### Offline Banner

```dart
class OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final connectivity = getIt<ConnectivityService>();
    
    return StreamBuilder<ConnectivityStatusEntity>(
      stream: connectivity.onConnectivityChanged,
      builder: (context, snapshot) {
        final isOffline = snapshot.data?.isDisconnected ?? false;
        
        if (!isOffline) return SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(8),
          color: Colors.red,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'No Internet Connection',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### Connectivity Indicator

```dart
class ConnectivityIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final connectivity = getIt<ConnectivityService>();
    
    return StreamBuilder<ConnectivityStatusEntity>(
      stream: connectivity.onConnectivityChanged,
      builder: (context, snapshot) {
        final status = snapshot.data;
        final isConnected = status?.isConnected ?? false;
        
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConnected ? Colors.green : Colors.red,
          ),
        );
      },
    );
  }
}
```

### Retry Logic

```dart
Future<void> fetchDataWithRetry() async {
  final connectivity = getIt<ConnectivityService>();
  
  // Check connectivity before making request
  final connectionResult = await connectivity.hasInternetConnection();
  
  await connectionResult.fold(
    (failure) {
      // Failed to check connectivity
      showError('Cannot verify internet connection');
    },
    (isConnected) async {
      if (!isConnected) {
        // No internet - wait for connection
        await _waitForConnection();
      }
      
      // Now fetch data
      await _fetchData();
    },
  );
}

Future<void> _waitForConnection() async {
  final connectivity = getIt<ConnectivityService>();
  
  // Wait until connected
  await connectivity.onConnectivityChanged
      .firstWhere((status) => status.isConnected);
  
  showMessage('Back online! Syncing data...');
}
```

## 🔧 Dependency Independence

This service is designed to be independent of any specific connectivity checking package. The default implementation uses `internet_connection_checker_plus`, but you can easily create your own implementation.

### Creating Custom Implementation

```dart
class MyCustomConnectivityServiceImpl implements ConnectivityService {
  @override
  Future<Either<ConnectivityFailure, bool>> hasInternetConnection() async {
    // Your custom connectivity checking logic
    try {
      // Example: Ping your own server
      final response = await http.get(Uri.parse('https://api.myapp.com/ping'));
      return Right(response.statusCode == 200);
    } catch (e) {
      return Left(InternetCheckFailure(message: e.toString()));
    }
  }
  
  // Implement other methods...
}
```

### Switching Implementations

Just update your DI registration:

```dart
// Option 1: Use internet_connection_checker_plus
getIt.registerLazySingleton<ConnectivityService>(
  () => InternetConnectionCheckerPlusServiceImpl(),
);

// Option 2: Use custom implementation
getIt.registerLazySingleton<ConnectivityService>(
  () => MyCustomConnectivityServiceImpl(),
);
```

**That's it!** No changes needed in your business logic or UI code.

## ⚡ Performance Tips

1. **Use appropriate check intervals**: Don't check too frequently
   ```dart
   // ❌ Too frequent - wastes battery
   checkInterval: Duration(seconds: 1)
   
   // ✅ Reasonable
   checkInterval: Duration(seconds: 10)
   ```

2. **Pause when not needed**: Save battery when app is in background
   ```dart
   connectivity.pause();  // When app goes to background
   connectivity.resume(); // When app comes to foreground
   ```

3. **Cache current status**: Use synchronous getters when possible
   ```dart
   // ❌ Makes async check every time
   await connectivity.hasInternetConnection();
   
   // ✅ Uses cached status (if available)
   final isConnected = connectivity.isConnected;
   ```

4. **Use custom endpoints wisely**: Checking your own API is useful, but keep timeouts reasonable
   ```dart
   ConnectivityCheckOptionEntity(
     uri: Uri.parse('https://api.myapp.com/health'),
     timeout: Duration(seconds: 5), // Not too long!
   )
   ```

## 🐛 Troubleshooting

### Service not initialized error

```dart
// ❌ Error: Not initialized
final result = await connectivity.hasInternetConnection();

// ✅ Solution: Initialize first
await connectivity.initialize();
final result = await connectivity.hasInternetConnection();
```

### Stream subscription not working

```dart
// ❌ Wrong: Service not initialized
connectivity.onConnectivityChanged.listen(...);

// ✅ Correct: Initialize first
await connectivity.initialize();
connectivity.onConnectivityChanged.listen(...);
```

### False positives/negatives

If you're getting incorrect connectivity status:

1. Check your endpoints are reachable
2. Verify timeout is not too short
3. Check firewall/proxy settings
4. Try using custom endpoints

```dart
await connectivity.initialize(
  checkOptions: [
    ConnectivityCheckOptionEntity(
      uri: Uri.parse('https://www.google.com'),
      timeout: Duration(seconds: 10), // Increase if needed
    ),
  ],
);
```

## 📚 API Reference

See `QUICK_START.md` for detailed API documentation and examples.

## 🔗 Related Services

- **Network Service**: For making HTTP requests
- **Storage Service**: For caching data when offline
- **Analytics Service**: For tracking connectivity issues

## 📝 License

This service is part of BUMA Core library.


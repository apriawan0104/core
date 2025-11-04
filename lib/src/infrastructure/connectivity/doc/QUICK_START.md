# Connectivity Service - Quick Start Guide

Step-by-step guide to integrate real internet connectivity checking in your Flutter app.

## 📋 Prerequisites

- Flutter SDK installed
- BUMA Core library added to `pubspec.yaml`
- Basic understanding of dependency injection (GetIt)

## 🚀 Step-by-Step Setup

### Step 1: Add Dependency

In your app's `pubspec.yaml`:

```yaml
dependencies:
  app_core: ^x.x.x  # Replace with actual version
  get_it: ^7.6.0     # For dependency injection
```

Run:
```bash
flutter pub get
```

### Step 2: Setup Dependency Injection

Create or update your DI setup file (e.g., `lib/config/di/locator.dart`):

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Register ConnectivityService
  getIt.registerLazySingleton<ConnectivityService>(
    () => InternetConnectionCheckerPlusServiceImpl(),
  );
  
  // Initialize the service
  final connectivity = getIt<ConnectivityService>();
  await connectivity.initialize();
}
```

### Step 3: Initialize in `main.dart`

```dart
import 'package:flutter/material.dart';
import 'config/di/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup dependencies
  await setupDependencies();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: HomePage(),
    );
  }
}
```

### Step 4: Use in Your App

#### Example 1: Basic Connectivity Check

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'config/di/locator.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _connectivity = getIt<ConnectivityService>();
  bool _isChecking = false;
  String _status = 'Tap button to check';

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
      _status = 'Checking...';
    });

    final result = await _connectivity.hasInternetConnection();
    
    result.fold(
      (failure) {
        setState(() {
          _isChecking = false;
          _status = 'Error: ${failure.message}';
        });
      },
      (isConnected) {
        setState(() {
          _isChecking = false;
          _status = isConnected ? 'Connected! 🌐' : 'Disconnected! 📵';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connectivity Check')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _status,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isChecking ? null : _checkConnection,
              child: Text('Check Connection'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Example 2: Real-Time Monitoring

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'config/di/locator.dart';

class MonitoredPage extends StatefulWidget {
  @override
  State<MonitoredPage> createState() => _MonitoredPageState();
}

class _MonitoredPageState extends State<MonitoredPage> {
  final _connectivity = getIt<ConnectivityService>();
  late StreamSubscription<ConnectivityStatusEntity> _subscription;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    
    // Get initial status
    _isOnline = _connectivity.isConnected ?? false;
    
    // Listen to changes
    _subscription = _connectivity.onConnectivityChanged.listen((status) {
      setState(() {
        _isOnline = status.isConnected;
      });
      
      // Handle connectivity changes
      if (status.isConnected) {
        _onConnected();
      } else {
        _onDisconnected();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _onConnected() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Back online! 🌐'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onDisconnected() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connection lost! 📵'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Monitoring'),
        actions: [
          // Connection indicator
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isOnline ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
      body: _isOnline ? _buildOnlineContent() : _buildOfflineContent(),
    );
  }

  Widget _buildOnlineContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi, size: 100, color: Colors.green),
          SizedBox(height: 16),
          Text(
            'Online',
            style: TextStyle(fontSize: 24, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 100, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Offline',
            style: TextStyle(fontSize: 24, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
```

#### Example 3: With Lifecycle Management

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'config/di/locator.dart';

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
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground
        print('App resumed - checking connectivity');
        _connectivity.resume();
        break;
      case AppLifecycleState.paused:
        // App went to background
        print('App paused - pausing connectivity checks');
        _connectivity.pause();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: HomePage(),
    );
  }
}
```

#### Example 4: Offline Banner Widget

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'config/di/locator.dart';

class OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final connectivity = getIt<ConnectivityService>();
    
    return StreamBuilder<ConnectivityStatusEntity>(
      stream: connectivity.onConnectivityChanged,
      initialData: connectivity.currentStatus,
      builder: (context, snapshot) {
        final isOffline = snapshot.data?.isDisconnected ?? false;
        
        if (!isOffline) return SizedBox.shrink();
        
        return Material(
          elevation: 4,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'No Internet Connection',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Usage in your app
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Column(
        children: [
          OfflineBanner(), // Add at the top
          Expanded(
            child: YourContent(),
          ),
        ],
      ),
    );
  }
}
```

#### Example 5: Retry Logic with Connectivity

```dart
import 'package:app_core/app_core.dart';
import 'config/di/locator.dart';

class DataService {
  final _connectivity = getIt<ConnectivityService>();
  
  Future<void> fetchDataWithRetry() async {
    // Check connectivity first
    final connectionResult = await _connectivity.hasInternetConnection();
    
    await connectionResult.fold(
      (failure) {
        // Failed to check connectivity
        throw Exception('Cannot verify internet connection: ${failure.message}');
      },
      (isConnected) async {
        if (!isConnected) {
          // No internet - wait for connection
          print('No internet. Waiting for connection...');
          await _waitForConnection();
        }
        
        // Now fetch data
        await _performFetch();
      },
    );
  }
  
  Future<void> _waitForConnection() async {
    // Wait until connected (with timeout)
    await _connectivity.onConnectivityChanged
        .firstWhere((status) => status.isConnected)
        .timeout(
          Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Connection timeout');
          },
        );
    
    print('Connected! Proceeding with fetch...');
  }
  
  Future<void> _performFetch() async {
    // Your actual data fetching logic
    print('Fetching data...');
  }
}
```

## 🎛️ Advanced Configuration

### Custom Endpoints

To check connectivity against your own API:

```dart
Future<void> setupDependencies() async {
  getIt.registerLazySingleton<ConnectivityService>(
    () => InternetConnectionCheckerPlusServiceImpl(),
  );
  
  final connectivity = getIt<ConnectivityService>();
  
  await connectivity.initialize(
    checkInterval: Duration(seconds: 10),
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
}
```

### Custom Success Criteria

```dart
await connectivity.initialize(
  checkOptions: [
    ConnectivityCheckOptionEntity(
      uri: Uri.parse('https://api.myapp.com/ping'),
      timeout: Duration(seconds: 5),
      responseStatusFn: (statusCode, headers, body) {
        // Custom logic to determine success
        return statusCode >= 200 && statusCode < 300;
      },
    ),
  ],
);
```

### Dynamic Check Intervals

```dart
class AdaptiveConnectivity {
  final _connectivity = getIt<ConnectivityService>();
  
  void onUserActive() {
    // Check more frequently when user is active
    _connectivity.updateCheckInterval(Duration(seconds: 5));
  }
  
  void onUserIdle() {
    // Check less frequently when idle
    _connectivity.updateCheckInterval(Duration(seconds: 30));
  }
}
```

## 🎯 Best Practices

### 1. Always Initialize

```dart
// ❌ Wrong
final result = await connectivity.hasInternetConnection(); // Error!

// ✅ Correct
await connectivity.initialize();
final result = await connectivity.hasInternetConnection();
```

### 2. Cancel Subscriptions

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription<ConnectivityStatusEntity> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = connectivity.onConnectivityChanged.listen(...);
  }

  @override
  void dispose() {
    _subscription.cancel(); // ✅ Always cancel!
    super.dispose();
  }
}
```

### 3. Use Lifecycle Management

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    connectivity.pause(); // Save battery
  } else if (state == AppLifecycleState.resumed) {
    connectivity.resume(); // Resume checks
  }
}
```

### 4. Handle Errors Gracefully

```dart
final result = await connectivity.hasInternetConnection();

result.fold(
  (failure) {
    // ✅ Handle failure gracefully
    print('Check failed: ${failure.message}');
    // Show cached data or retry
  },
  (isConnected) {
    // Handle success
  },
);
```

### 5. Don't Check Too Frequently

```dart
// ❌ Too frequent - wastes battery
checkInterval: Duration(seconds: 1)

// ✅ Reasonable default
checkInterval: Duration(seconds: 10)

// ✅ For background checking
checkInterval: Duration(seconds: 30)
```

## 🐛 Common Issues

### Issue 1: Service not initialized

**Error:** `ConnectivityService not initialized. Call initialize() first.`

**Solution:**
```dart
await connectivity.initialize();
```

### Issue 2: Memory leaks from uncancelled subscriptions

**Problem:** App performance degrades over time

**Solution:** Always cancel subscriptions
```dart
@override
void dispose() {
  _subscription.cancel();
  super.dispose();
}
```

### Issue 3: False negatives (shows offline when online)

**Possible causes:**
- Firewall blocking check endpoints
- VPN or proxy issues
- Corporate network restrictions

**Solution:** Use custom endpoints
```dart
await connectivity.initialize(
  checkOptions: [
    ConnectivityCheckOptionEntity(
      uri: Uri.parse('https://your-accessible-server.com'),
    ),
  ],
);
```

## 📚 Next Steps

- Read the full [README.md](README.md) for more details
- Check out complete examples in `/example/connectivity_example.dart`
- Learn about [error handling](../../../errors/connectivity_failure.dart)
- Explore [entities](../../../foundation/domain/entities/connectivity/entities.dart)

## 🆘 Need Help?

- Check the [Troubleshooting section](README.md#-troubleshooting) in README
- Review the example code
- Check the API documentation

---

**Happy coding! 🚀**


# Connectivity Service Setup Guide

Complete guide for setting up and using the Connectivity Service in your Flutter app.

## 📖 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Basic Setup](#basic-setup)
- [Usage Examples](#usage-examples)
- [Advanced Configuration](#advanced-configuration)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [API Reference](#api-reference)

## 🎯 Overview

The Connectivity Service provides **real internet connectivity checking**, not just Wi-Fi or mobile data connection status. This is crucial because:

- ❌ **Common Problem**: Being connected to Wi-Fi doesn't guarantee internet access
- ✅ **Our Solution**: Verify actual internet connectivity by pinging real endpoints

### Why This Matters

```dart
// ❌ Wrong: This only checks if Wi-Fi/Mobile is connected
final connectivityResult = await Connectivity().checkConnectivity();
if (connectivityResult == ConnectivityResult.wifi) {
  // Could be true even with NO internet! 🚫
}

// ✅ Correct: This checks ACTUAL internet connectivity
final result = await connectivity.hasInternetConnection();
result.fold(
  (failure) => handleError(),
  (isConnected) {
    if (isConnected) {
      // Guaranteed internet access! ✅
    }
  },
);
```

## ✨ Features

- ✅ **Real Internet Checking**: Verifies actual internet access
- ⚡ **Subsecond Response Times**: Fast checks even on mobile networks
- 🔄 **Live Status Monitoring**: Stream of connectivity changes
- 🎛️ **Customizable Endpoints**: Check connectivity to your own servers
- ⏱️ **Configurable Intervals**: Control check frequency
- ⏸️ **Lifecycle Management**: Pause/resume to save battery
- 🌐 **Cross-Platform**: Android, iOS, macOS, Linux, Windows, Web
- 🔌 **Dependency Independent**: Easy to swap implementations

## 📦 Installation

### 1. Add to pubspec.yaml

The `internet_connection_checker_plus` package is already included in BUMA Core:

```yaml
dependencies:
  app_core: ^x.x.x  # Your core library version
```

### 2. Import the package

```dart
import 'package:app_core/app_core.dart';
```

### 3. Platform-specific setup

#### Android

Add to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

#### iOS / macOS

Add to `.entitlements` files:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

## 🚀 Basic Setup

### Step 1: Register in Dependency Injection

Create or update your DI setup file:

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

### Step 2: Initialize in main.dart

```dart
import 'package:flutter/material.dart';
import 'config/di/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup dependencies (includes connectivity)
  await setupDependencies();
  
  runApp(MyApp());
}
```

### Step 3: Use in your app

```dart
class MyWidget extends StatelessWidget {
  final _connectivity = getIt<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityStatusEntity>(
      stream: _connectivity.onConnectivityChanged,
      builder: (context, snapshot) {
        final isOnline = snapshot.data?.isConnected ?? false;
        
        return isOnline 
          ? OnlineContent() 
          : OfflineContent();
      },
    );
  }
}
```

## 📚 Usage Examples

### One-Time Connectivity Check

```dart
final connectivity = getIt<ConnectivityService>();

final result = await connectivity.hasInternetConnection();

result.fold(
  (failure) {
    // Handle error
    print('Error: ${failure.message}');
  },
  (isConnected) {
    if (isConnected) {
      // Internet available
      fetchData();
    } else {
      // No internet
      showOfflineUI();
    }
  },
);
```

### Real-Time Monitoring

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
    
    _subscription = connectivity.onConnectivityChanged.listen((status) {
      setState(() {
        _isOnline = status.isConnected;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel(); // Important!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isOnline ? OnlineView() : OfflineView();
  }
}
```

### Offline Banner Widget

```dart
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
        
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          color: Colors.red,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'No Internet Connection',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
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
  
  // Check connectivity first
  final connectionResult = await connectivity.hasInternetConnection();
  
  await connectionResult.fold(
    (failure) {
      throw Exception('Cannot verify connectivity: ${failure.message}');
    },
    (isConnected) async {
      if (!isConnected) {
        // Wait for connection
        await connectivity.onConnectivityChanged
            .firstWhere((status) => status.isConnected)
            .timeout(Duration(seconds: 30));
      }
      
      // Now fetch data
      await _performFetch();
    },
  );
}
```

## ⚙️ Advanced Configuration

### Custom Endpoints

Check connectivity against your own API servers:

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

Define what counts as successful connectivity:

```dart
await connectivity.initialize(
  checkOptions: [
    ConnectivityCheckOptionEntity(
      uri: Uri.parse('https://api.myapp.com/ping'),
      timeout: Duration(seconds: 5),
      responseStatusFn: (statusCode, headers, body) {
        // Custom logic
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

// Update at runtime
connectivity.updateCheckInterval(Duration(seconds: 30));
```

### Lifecycle Management

Pause checks when app goes to background:

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
      _connectivity.pause(); // Save battery
    } else if (state == AppLifecycleState.resumed) {
      _connectivity.resume(); // Resume checks
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
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
@override
void dispose() {
  _subscription.cancel(); // ✅ Always cancel!
  super.dispose();
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
result.fold(
  (failure) {
    // ✅ Handle failure
    showCachedData();
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

// ✅ Reasonable
checkInterval: Duration(seconds: 10)
```

## 🐛 Troubleshooting

### Service not initialized

**Error:** `ConnectivityService not initialized. Call initialize() first.`

**Solution:**
```dart
await connectivity.initialize();
```

### Memory leaks from uncancelled subscriptions

**Problem:** App performance degrades over time

**Solution:**
```dart
@override
void dispose() {
  _subscription.cancel();
  super.dispose();
}
```

### False negatives (shows offline when online)

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

## 📖 API Reference

### ConnectivityService

Main interface for connectivity checking.

#### Methods

**`initialize({checkInterval, checkOptions})`**
- Initialize the service
- Must be called before using the service

**`hasInternetConnection()`**
- One-time connectivity check
- Returns `Either<ConnectivityFailure, bool>`

**`pause()`**
- Pause connectivity monitoring
- Use when app goes to background

**`resume()`**
- Resume connectivity monitoring
- Use when app comes to foreground

**`updateCheckInterval(Duration interval)`**
- Change check frequency at runtime

**`updateCheckOptions(List<ConnectivityCheckOptionEntity> options)`**
- Change check endpoints at runtime

**`dispose()`**
- Clean up resources
- Call when service is no longer needed

#### Properties

**`onConnectivityChanged`** (Stream<ConnectivityStatusEntity>)
- Stream of connectivity status changes
- Broadcast stream, allows multiple listeners

**`currentStatus`** (ConnectivityStatusEntity?)
- Last known connectivity status
- Synchronous, doesn't perform new check

**`isConnected`** (bool?)
- Last known connection state
- Synchronous, doesn't perform new check

**`isInitialized`** (bool)
- Check if service is initialized

**`isPaused`** (bool)
- Check if monitoring is paused

## 🔗 Related Documentation

- [Full README](lib/src/infrastructure/connectivity/doc/README.md)
- [Quick Start Guide](lib/src/infrastructure/connectivity/doc/QUICK_START.md)
- [Example Code](example/connectivity_example.dart)
- [API Documentation](lib/src/infrastructure/connectivity/contract/connectivity.service.dart)

## 🔄 Changing Implementation

To switch from `internet_connection_checker_plus` to another package:

### 1. Create new implementation

```dart
class MyCustomConnectivityServiceImpl implements ConnectivityService {
  // Implement with different package
  @override
  Future<Either<ConnectivityFailure, bool>> hasInternetConnection() async {
    // Your custom logic
  }
  
  // Implement other methods...
}
```

### 2. Update DI registration

```dart
getIt.registerLazySingleton<ConnectivityService>(
  () => MyCustomConnectivityServiceImpl(),
);
```

**That's it!** No changes needed in business logic or UI code.

## 📝 Examples

See complete working examples in:
- [example/connectivity_example.dart](example/connectivity_example.dart)

## 🆘 Need Help?

- Check the [README.md](lib/src/infrastructure/connectivity/doc/README.md)
- Review [QUICK_START.md](lib/src/infrastructure/connectivity/doc/QUICK_START.md)
- See working [examples](example/connectivity_example.dart)
- Check [API documentation](lib/src/infrastructure/connectivity/contract/connectivity.service.dart)

---

**Made with ❤️ following BUMA Core architecture principles**


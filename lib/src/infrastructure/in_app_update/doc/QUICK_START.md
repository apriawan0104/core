# In-App Update - Quick Start Guide

Quick reference for implementing in-app updates in your Flutter app.

## 📦 Installation

```yaml
# pubspec.yaml
dependencies:
  app_core:
    path: ../core
  in_app_update: ^4.2.5
```

## ⚙️ Setup

### 1. Register Service

```dart
// DI setup (e.g., in main.dart or di/locator.dart)
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServices() {
  getIt.registerLazySingleton<InAppUpdateService>(
    () => AndroidInAppUpdateServiceImpl(),
  );
}
```

### 2. Initialize

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServices();
  
  final updateService = getIt<InAppUpdateService>();
  await updateService.initialize();
  
  runApp(MyApp());
}
```

## 🚀 Basic Usage

### Check for Updates

```dart
Future<void> checkForUpdates() async {
  final updateService = getIt<InAppUpdateService>();
  
  final result = await updateService.checkForUpdate();
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (info) {
      if (info.isUpdateAvailable) {
        print('Update available: v${info.availableVersionCode}');
        print('Priority: ${info.updatePriority}');
      } else {
        print('App is up to date');
      }
    },
  );
}
```

### Immediate Update (Full-Screen)

```dart
Future<void> performImmediateUpdate() async {
  final updateService = getIt<InAppUpdateService>();
  
  final result = await updateService.performImmediateUpdate();
  
  result.fold(
    (failure) => print('Update failed: ${failure.message}'),
    (_) => print('Update completed (app will restart)'),
  );
}
```

### Flexible Update (Background)

```dart
Future<void> performFlexibleUpdate() async {
  final updateService = getIt<InAppUpdateService>();
  
  // 1. Start download
  final startResult = await updateService.startFlexibleUpdate();
  
  startResult.fold(
    (failure) => print('Download failed: ${failure.message}'),
    (_) {
      print('Downloading update...');
      
      // 2. Listen for completion
      updateService.installStatusStream.listen((status) {
        if (status.isDownloaded) {
          print('Download complete! Ready to install.');
          
          // 3. Prompt user to install
          showInstallPrompt();
        }
      });
    },
  );
}

void showInstallPrompt() {
  // Show snackbar or dialog
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Update ready. Install now?'),
      action: SnackBarAction(
        label: 'INSTALL',
        onPressed: () async {
          final updateService = getIt<InAppUpdateService>();
          await updateService.completeFlexibleUpdate();
          // App will restart
        },
      ),
    ),
  );
}
```

## 🎯 Complete Example

```dart
class UpdateManager {
  final InAppUpdateService _updateService;
  
  UpdateManager(this._updateService);
  
  Future<void> checkAndHandleUpdate() async {
    final result = await _updateService.checkForUpdate();
    
    await result.fold(
      (failure) async {
        print('Check failed: $failure');
      },
      (info) async {
        if (!info.isUpdateAvailable) {
          return;
        }
        
        // High priority (4-5) -> Immediate update
        if (info.shouldBeImmediate) {
          await _performImmediateUpdate();
        }
        // Low-medium priority (1-3) -> Flexible update
        else if (info.canBeFlexible) {
          await _startFlexibleUpdate();
        }
      },
    );
  }
  
  Future<void> _performImmediateUpdate() async {
    await _updateService.performImmediateUpdate();
  }
  
  Future<void> _startFlexibleUpdate() async {
    final result = await _updateService.startFlexibleUpdate();
    
    result.fold(
      (failure) => print('Download failed: $failure'),
      (_) => _listenToInstallStatus(),
    );
  }
  
  void _listenToInstallStatus() {
    _updateService.installStatusStream.listen((status) {
      switch (status) {
        case InstallStatus.downloading:
          showMessage('Downloading update...');
          break;
        case InstallStatus.downloaded:
          showInstallPrompt();
          break;
        case InstallStatus.failed:
          showMessage('Update failed');
          break;
        default:
          break;
      }
    });
  }
}

// Usage in app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServices();
  
  final updateService = getIt<InAppUpdateService>();
  await updateService.initialize();
  
  // Check for updates on startup
  final updateManager = UpdateManager(updateService);
  await updateManager.checkAndHandleUpdate();
  
  runApp(MyApp());
}
```

## 📊 Update Priority Guide

Use these priorities in Google Play Console:

| Priority | Type | Use Case | User Experience |
|----------|------|----------|-----------------|
| **5** | Critical | Security patches, breaking changes | Force immediate update |
| **4** | High | Important bugs, major features | Suggest immediate update |
| **3** | Medium | Feature updates, improvements | Flexible with reminders |
| **1-2** | Low | Minor fixes, optimizations | Silent flexible update |

```dart
// Smart update handling based on priority
Future<void> handleUpdateByPriority(AppUpdateInfo info) async {
  if (info.updatePriority == 5) {
    // Critical - force update
    await _updateService.performImmediateUpdate();
  } else if (info.updatePriority >= 4) {
    // High - show dialog
    final shouldUpdate = await showUpdateDialog(required: false);
    if (shouldUpdate) {
      await _updateService.performImmediateUpdate();
    }
  } else {
    // Normal - flexible update
    await _updateService.startFlexibleUpdate();
  }
}
```

## 🧪 Testing Checklist

**⚠️ Important: Cannot test locally! Must use Google Play.**

### Before Testing:

- [ ] Current version uploaded to Play Console
- [ ] Current version installed via Play Store on test device
- [ ] New version (higher version code) uploaded to Play Console
- [ ] New version published (Internal/Alpha/Beta track OK)
- [ ] Test device has internet connection

### Common Test Issues:

| Error | Cause | Solution |
|-------|-------|----------|
| `ERROR_API_NOT_AVAILABLE` | App not from Play Store | Install via Play Store |
| `ERROR_UPDATE_NOT_AVAILABLE` | No higher version | Upload higher version code |
| `PLATFORM_NOT_SUPPORTED` | Testing on iOS | Only works on Android |

### Test Commands:

```dart
// Test update availability
final result = await updateService.checkForUpdate();
result.fold(
  (failure) => print('Error: ${failure.code}'),
  (info) => print('Available: ${info.isUpdateAvailable}'),
);

// Test platform support
final supported = await updateService.isUpdateSupported();
print('Supported: $supported');

// Test install status
final status = await updateService.getCurrentInstallStatus();
print('Status: $status');
```

## 💡 Best Practices

### ✅ DO:

```dart
// Check on app startup
void main() async {
  await checkForUpdates();
  runApp(MyApp());
}

// Check on resume
class MyApp extends StatefulWidget {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkForUpdates();
    }
  }
}

// Use priority for decision making
if (info.shouldBeImmediate) {
  performImmediateUpdate();
} else {
  startFlexibleUpdate();
}

// Handle errors gracefully
result.fold(
  (failure) {
    // Log but don't block user
    logError(failure);
  },
  (info) => handleUpdate(info),
);
```

### ❌ DON'T:

```dart
// Don't check too frequently
Timer.periodic(Duration(minutes: 1), (_) => checkForUpdates()); // Bad!

// Don't force immediate for minor updates
if (minorFeatureUpdate) {
  performImmediateUpdate(); // Bad UX!
}

// Don't show technical errors to users
if (error) {
  showDialog('ERROR_API_NOT_AVAILABLE'); // Bad!
}

// Don't block UI while checking
final update = await checkForUpdates(); // Blocks UI!
runApp(MyApp());
```

## 📱 Platform-Specific Code

### Android Only:

```dart
import 'dart:io';

Future<void> checkForUpdates() async {
  // Only check on Android
  if (!Platform.isAndroid) {
    return;
  }
  
  final updateService = getIt<InAppUpdateService>();
  await updateService.checkForUpdate();
}
```

### Multi-Platform Support:

```dart
Future<void> checkForUpdates() async {
  if (Platform.isAndroid) {
    // Use in-app update
    final updateService = getIt<InAppUpdateService>();
    await updateService.checkForUpdate();
  } else if (Platform.isIOS) {
    // Use upgrader package or custom solution
    await checkAppStoreVersion();
  }
}
```

## 🔗 Quick Links

- **Full Documentation**: [README.md](README.md)
- **Package**: [in_app_update on pub.dev](https://pub.dev/packages/in_app_update)
- **Android Docs**: [In-App Updates API](https://developer.android.com/guide/playcore/in-app-updates)
- **Testing Guide**: [Test In-App Updates](https://developer.android.com/guide/playcore/in-app-updates/test)

## 📞 Common Issues

### Issue: Update not showing

```dart
// Debug update info
final result = await updateService.checkForUpdate();
result.fold(
  (failure) => print('Error: ${failure.code} - ${failure.message}'),
  (info) {
    print('Available: ${info.isUpdateAvailable}');
    print('Version code: ${info.availableVersionCode}');
    print('Immediate allowed: ${info.immediateUpdateAllowed}');
    print('Flexible allowed: ${info.flexibleUpdateAllowed}');
  },
);
```

### Issue: Download not completing

```dart
// Monitor download progress
updateService.installStatusStream.listen((status) {
  print('Status: $status');
  
  if (status == InstallStatus.failed) {
    print('Download failed!');
  } else if (status == InstallStatus.canceled) {
    print('User cancelled download');
  }
});
```

### Issue: Install not working

```dart
// Check if download complete before installing
final statusResult = await updateService.getCurrentInstallStatus();
statusResult.fold(
  (failure) => print('Error: $failure'),
  (status) {
    if (status.isDownloaded) {
      // OK to install
      updateService.completeFlexibleUpdate();
    } else {
      print('Download not complete yet: $status');
    }
  },
);
```

---

**Need more details?** See the full [README.md](README.md) for comprehensive documentation.


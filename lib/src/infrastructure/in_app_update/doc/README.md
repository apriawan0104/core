# In-App Update Service

Comprehensive in-app update service for BUMA Core that enables seamless app updates on Android via Google Play.

## 📋 Table of Contents

- [Overview](#overview)
- [Platform Support](#platform-support)
- [Architecture](#architecture)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Update Types](#update-types)
- [Usage Examples](#usage-examples)
- [Testing](#testing)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

The in-app update service provides a **dependency-independent** abstraction for managing app updates. It wraps the Android In-App Update API while keeping your business logic independent from Google Play APIs.

### Key Features

✅ **Immediate Updates**: Full-screen updates for critical releases  
✅ **Flexible Updates**: Background downloads for non-critical updates  
✅ **Dependency Independent**: Easy to switch update providers  
✅ **Type Safe**: All operations return `Either<Failure, Success>`  
✅ **Real-time Status**: Stream-based installation progress  
✅ **Priority-Based**: Smart update flow based on update priority  
✅ **Easy Testing**: Mock-friendly design  

### Design Philosophy

Following BUMA Core principles:

1. **No Third-Party Types in Public API**: All interfaces use our own models
2. **Abstraction First**: Wrap Google Play API with clean interface
3. **Easy Migration**: Can support alternative update mechanisms
4. **Zero Business Logic Changes**: Consumer code remains unchanged

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **Android** | ✅ Fully Supported | Via Google Play In-App Updates API |
| **iOS** | ❌ Not Supported | iOS doesn't offer in-app update functionality |
| **Web** | ❌ Not Supported | Use browser auto-update |
| **Desktop** | ❌ Not Supported | Use platform-specific update mechanisms |

For iOS, consider using the [`upgrader`](https://pub.dev/packages/upgrader) package for App Store version checking.

## 🏗️ Architecture

```
in_app_update/
├── contract/
│   └── in_app_update.service.dart          # Abstract interface
├── impl/
│   └── android_in_app_update.service.impl.dart
├── models/
│   ├── app_update_info.model.dart          # Update information
│   ├── update_availability.model.dart      # Availability status
│   ├── install_status.model.dart           # Installation progress
│   └── update_type.model.dart              # Immediate vs Flexible
├── constants/
│   └── in_app_update.constant.dart         # Error codes, defaults
└── doc/
    ├── README.md                           # This file
    └── QUICK_START.md                      # Quick reference
```

## 📦 Installation

### 1. Add Dependencies

Add to your app's `pubspec.yaml`:

```yaml
dependencies:
  # Core library
  app_core:
    path: ../core  # or your core library path
  
  # In-App Update package
  in_app_update: ^4.2.5
```

### 2. Platform Setup

#### Android

No additional setup required. The package works automatically with Google Play.

**Minimum Requirements:**
- Android API Level 21 (Android 5.0) or higher
- App must be installed via Google Play Store

#### iOS

In-app updates are not supported on iOS. The service will return `PLATFORM_NOT_SUPPORTED` error.

For iOS update prompts, consider alternative solutions:
- [`upgrader`](https://pub.dev/packages/upgrader) package
- Custom version checking logic
- App Store review prompts

### 3. Google Play Configuration

To enable in-app updates:

1. **Create a new version** in Play Console with higher version code
2. **Upload to track** (Internal/Alpha/Beta/Production)
3. **Publish** the new version
4. **Test device must have** the lower version installed via Play Store

See [Testing](#testing) section for detailed testing guide.

## 🚀 Quick Start

### 1. Register in DI Container

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupInAppUpdate() {
  getIt.registerLazySingleton<InAppUpdateService>(
    () => AndroidInAppUpdateServiceImpl(),
  );
}
```

### 2. Initialize Service

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  setupInAppUpdate();
  
  final updateService = getIt<InAppUpdateService>();
  final initResult = await updateService.initialize();
  
  initResult.fold(
    (failure) => print('Update service init failed: $failure'),
    (_) => print('Update service ready'),
  );
  
  runApp(MyApp());
}
```

### 3. Check for Updates

```dart
Future<void> checkForUpdates() async {
  final updateService = getIt<InAppUpdateService>();
  
  final result = await updateService.checkForUpdate();
  
  result.fold(
    (failure) {
      print('Check failed: $failure');
    },
    (updateInfo) {
      if (updateInfo.isUpdateAvailable) {
        print('Update available!');
        print('Version: ${updateInfo.availableVersionCode}');
        print('Priority: ${updateInfo.updatePriority}');
        
        // Decide update type based on priority
        if (updateInfo.shouldBeImmediate) {
          performImmediateUpdate();
        } else {
          startFlexibleUpdate();
        }
      } else {
        print('App is up to date');
      }
    },
  );
}
```

## 📦 Update Types

### 1. Immediate Update (Full-Screen)

**Best for:**
- Critical security patches
- Breaking backend API changes
- High-priority bugs
- Updates with priority >= 4

**User Experience:**
- Shows full-screen blocking UI
- User cannot use app until update completes
- App restarts automatically after installation

**Code:**

```dart
Future<void> performImmediateUpdate() async {
  final updateService = getIt<InAppUpdateService>();
  
  final result = await updateService.performImmediateUpdate();
  
  result.fold(
    (failure) {
      if (failure.code == 'UPDATE_CANCELLED') {
        // User cancelled update
        showCancelledMessage();
      } else {
        showError('Update failed: ${failure.message}');
      }
    },
    (_) {
      // Update completed, app will restart
      print('Update installed successfully');
    },
  );
}
```

### 2. Flexible Update (Background)

**Best for:**
- Non-critical feature updates
- Performance improvements
- Minor bug fixes
- Updates with priority < 4

**User Experience:**
- Downloads in background
- User can continue using app
- Prompt user when download completes
- User chooses when to install

**Code:**

```dart
Future<void> startFlexibleUpdate() async {
  final updateService = getIt<InAppUpdateService>();
  
  // Start download
  final startResult = await updateService.startFlexibleUpdate();
  
  startResult.fold(
    (failure) => showError('Download failed: ${failure.message}'),
    (_) {
      showSnackbar('Downloading update in background...');
      listenToInstallStatus();
    },
  );
}

void listenToInstallStatus() {
  final updateService = getIt<InAppUpdateService>();
  
  updateService.installStatusStream.listen((status) {
    switch (status) {
      case InstallStatus.downloading:
        showSnackbar('Downloading update...');
        break;
        
      case InstallStatus.downloaded:
        // Update ready to install
        showInstallPrompt();
        break;
        
      case InstallStatus.installing:
        showSnackbar('Installing update...');
        break;
        
      case InstallStatus.installed:
        showSnackbar('Update installed!');
        break;
        
      case InstallStatus.failed:
        showError('Update failed');
        break;
        
      case InstallStatus.canceled:
        showSnackbar('Update cancelled');
        break;
        
      default:
        break;
    }
  });
}

Future<void> completeFlexibleUpdate() async {
  final updateService = getIt<InAppUpdateService>();
  
  final result = await updateService.completeFlexibleUpdate();
  
  result.fold(
    (failure) => showError('Install failed: ${failure.message}'),
    (_) {
      // App will restart
      showSnackbar('Installing update...');
    },
  );
}
```

## 📚 Usage Examples

### Complete Update Flow

```dart
class UpdateManager {
  final InAppUpdateService _updateService;
  
  UpdateManager(this._updateService);
  
  /// Check for updates on app start
  Future<void> checkOnStartup() async {
    final result = await _updateService.checkForUpdate();
    
    await result.fold(
      (failure) async {
        // Handle error silently or log
        print('Update check failed: $failure');
      },
      (info) async {
        if (!info.isUpdateAvailable) {
          return;
        }
        
        // High priority -> immediate update
        if (info.updatePriority >= 4) {
          await _performImmediateUpdate();
          return;
        }
        
        // Old version -> suggest immediate update
        if (info.clientVersionStalenessDays != null &&
            info.clientVersionStalenessDays! >= 7) {
          await _showUpdateDialog(isRequired: true);
          return;
        }
        
        // Normal priority -> flexible update
        await _startFlexibleUpdate();
      },
    );
  }
  
  Future<void> _performImmediateUpdate() async {
    final result = await _updateService.performImmediateUpdate();
    
    result.fold(
      (failure) {
        // User cancelled or error occurred
        print('Immediate update failed: $failure');
      },
      (_) {
        // Success - app will restart
      },
    );
  }
  
  Future<void> _startFlexibleUpdate() async {
    final result = await _updateService.startFlexibleUpdate();
    
    result.fold(
      (failure) {
        print('Flexible update failed: $failure');
      },
      (_) {
        _listenToInstallStatus();
      },
    );
  }
  
  void _listenToInstallStatus() {
    _updateService.installStatusStream.listen((status) {
      if (status.isDownloaded) {
        _showInstallPrompt();
      }
    });
  }
  
  Future<void> _showUpdateDialog({required bool isRequired}) async {
    // Show dialog to user
    final shouldUpdate = await showDialog<bool>(
      context: context,
      barrierDismissible: !isRequired,
      builder: (context) => AlertDialog(
        title: Text(isRequired ? 'Update Required' : 'Update Available'),
        content: Text(
          isRequired
              ? 'Please update to continue using the app.'
              : 'A new version is available. Update now?',
        ),
        actions: [
          if (!isRequired)
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Later'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Update'),
          ),
        ],
      ),
    );
    
    if (shouldUpdate == true) {
      await _performImmediateUpdate();
    }
  }
  
  Future<void> _showInstallPrompt() async {
    // Show snackbar or dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Update downloaded. Install now?'),
        action: SnackBarAction(
          label: 'INSTALL',
          onPressed: () async {
            await _updateService.completeFlexibleUpdate();
          },
        ),
        duration: Duration(seconds: 10),
      ),
    );
  }
}
```

### Smart Update Strategy

```dart
class SmartUpdateStrategy {
  final InAppUpdateService _updateService;
  final StorageService _storage;
  
  SmartUpdateStrategy(this._updateService, this._storage);
  
  /// Check for updates with smart timing
  Future<void> checkForUpdates() async {
    // Don't check too frequently
    final lastCheck = await _getLastCheckTime();
    if (lastCheck != null) {
      final hoursSinceCheck = 
          DateTime.now().difference(lastCheck).inHours;
      
      if (hoursSinceCheck < 24) {
        return; // Check once per day
      }
    }
    
    // Update last check time
    await _saveLastCheckTime(DateTime.now());
    
    // Check for update
    final result = await _updateService.checkForUpdate();
    
    await result.fold(
      (failure) async {
        // Handle error
      },
      (info) async {
        if (info.isUpdateAvailable) {
          await _handleUpdate(info);
        }
      },
    );
  }
  
  Future<void> _handleUpdate(AppUpdateInfo info) async {
    // Critical update -> force immediate
    if (info.updatePriority == 5) {
      await _updateService.performImmediateUpdate();
      return;
    }
    
    // High priority -> suggest immediate
    if (info.updatePriority >= 4) {
      _showUpdateDialog(required: true);
      return;
    }
    
    // Normal priority -> flexible update
    await _updateService.startFlexibleUpdate();
  }
  
  Future<DateTime?> _getLastCheckTime() async {
    final result = await _storage.get<String>('last_update_check');
    return result.fold(
      (_) => null,
      (value) => value != null ? DateTime.parse(value) : null,
    );
  }
  
  Future<void> _saveLastCheckTime(DateTime time) async {
    await _storage.save('last_update_check', time.toIso8601String());
  }
}
```

## 🧪 Testing

### Important: Testing Requirements

**⚠️ In-app updates CANNOT be tested locally!**

You must:
1. ✅ Upload app to Play Console (Internal/Alpha/Beta track)
2. ✅ Install app on device via Google Play
3. ✅ Have higher version code available on Play Store
4. ❌ Cannot test with APK installed directly
5. ❌ Cannot test with local builds

### Testing Steps

#### 1. Prepare Test Versions

**Current Version (v1.0.0):**
```yaml
# pubspec.yaml
version: 1.0.0+1
```

**New Version (v1.0.1):**
```yaml
# pubspec.yaml
version: 1.0.1+2  # Higher version code
```

#### 2. Upload to Play Console

1. Build release APK/AAB for v1.0.0
2. Upload to Internal Test track
3. Publish and install on device via Play Store
4. Build and upload v1.0.1 to Internal Test track
5. Publish v1.0.1

#### 3. Test on Device

```dart
Future<void> testUpdate() async {
  final updateService = getIt<InAppUpdateService>();
  
  // Should return update available
  final result = await updateService.checkForUpdate();
  
  result.fold(
    (failure) {
      print('Error: ${failure.code} - ${failure.message}');
      
      if (failure.code == 'ERROR_API_NOT_AVAILABLE') {
        print('App not installed via Play Store!');
      }
    },
    (info) {
      print('Update available: ${info.isUpdateAvailable}');
      print('Available version: ${info.availableVersionCode}');
      print('Immediate allowed: ${info.immediateUpdateAllowed}');
      print('Flexible allowed: ${info.flexibleUpdateAllowed}');
    },
  );
}
```

#### 4. Common Test Scenarios

| Scenario | Expected Result |
|----------|----------------|
| App installed via Play Store + update available | Returns AppUpdateInfo with isUpdateAvailable = true |
| App installed via Play Store + no update | Returns AppUpdateInfo with isUpdateNotAvailable = true |
| App installed directly (APK) | Returns ERROR_API_NOT_AVAILABLE |
| On iOS device | Returns PLATFORM_NOT_SUPPORTED |
| Immediate update flow | Shows full-screen update UI |
| Flexible update flow | Downloads in background |

### Mock for Testing Business Logic

```dart
class MockInAppUpdateService implements InAppUpdateService {
  bool _updateAvailable = false;
  int _availableVersionCode = 2;
  
  @override
  Future<Either<InAppUpdateFailure, AppUpdateInfo>> checkForUpdate() async {
    return Right(
      AppUpdateInfo(
        updateAvailability: _updateAvailable
            ? UpdateAvailability.updateAvailable
            : UpdateAvailability.updateNotAvailable,
        immediateUpdateAllowed: true,
        flexibleUpdateAllowed: true,
        availableVersionCode: _availableVersionCode,
        installStatus: InstallStatus.unknown,
        packageName: 'com.example.app',
        updatePriority: 3,
      ),
    );
  }
  
  // Mock other methods...
}
```

## 💡 Best Practices

### 1. Update Timing

```dart
// ✅ GOOD: Check on app startup
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await checkForUpdates();
  runApp(MyApp());
}

// ✅ GOOD: Check on resume from background
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkForUpdates();
    }
  }
}

// ❌ BAD: Check too frequently
Timer.periodic(Duration(minutes: 5), (_) => checkForUpdates());
```

### 2. Update Priority Mapping

```dart
// Recommended priority thresholds
const int PRIORITY_CRITICAL = 5;    // Force immediate update
const int PRIORITY_HIGH = 4;        // Suggest immediate update
const int PRIORITY_MEDIUM = 3;      // Flexible with prompts
const int PRIORITY_LOW = 1-2;       // Flexible silent download

Future<void> handleUpdate(AppUpdateInfo info) async {
  if (info.updatePriority == PRIORITY_CRITICAL) {
    // Must update to continue
    await performImmediateUpdate();
  } else if (info.updatePriority >= PRIORITY_HIGH) {
    // Strongly recommend
    await showUpdateDialog(required: false);
  } else {
    // Optional update
    await startFlexibleUpdate();
  }
}
```

### 3. User Experience

```dart
// ✅ GOOD: Non-intrusive flexible update
Future<void> startFlexibleUpdate() async {
  await updateService.startFlexibleUpdate();
  
  // Show subtle notification
  showSnackBar('Update downloading in background');
  
  // Prompt only when ready
  updateService.installStatusStream.listen((status) {
    if (status.isDownloaded) {
      showInstallPrompt(); // User can choose when to install
    }
  });
}

// ❌ BAD: Forcing immediate update for minor changes
Future<void> forceUpdateForMinorFeature() async {
  await updateService.performImmediateUpdate(); // Blocks user!
}
```

### 4. Error Handling

```dart
// ✅ GOOD: Graceful error handling
Future<void> checkForUpdates() async {
  final result = await updateService.checkForUpdate();
  
  result.fold(
    (failure) {
      // Log error but don't block user
      analyticsService.logError('update_check_failed', failure);
      
      // Don't show error to user unless critical
      if (failure.code == 'ERROR_API_NOT_AVAILABLE') {
        // App not from Play Store - this is expected in development
        debugPrint('In-app update not available (expected in dev)');
      }
    },
    (info) {
      // Handle update
    },
  );
}

// ❌ BAD: Showing technical errors to users
Future<void> badErrorHandling() async {
  final result = await updateService.checkForUpdate();
  
  result.fold(
    (failure) {
      // Don't show raw error codes to users!
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error: ${failure.code}'),
          content: Text(failure.message),
        ),
      );
    },
    (_) {},
  );
}
```

### 5. Staleness Handling

```dart
// ✅ GOOD: Escalate based on version age
Future<void> handleStaleness(AppUpdateInfo info) async {
  final stalenessDays = info.clientVersionStalenessDays ?? 0;
  
  if (stalenessDays >= 30) {
    // Very old version - force update
    await performImmediateUpdate();
  } else if (stalenessDays >= 7) {
    // Old version - strong prompt
    await showUpdateDialog(required: true);
  } else if (stalenessDays >= 3) {
    // Somewhat old - gentle reminder
    await showUpdateBanner();
  } else {
    // Recent update - flexible download
    await startFlexibleUpdate();
  }
}
```

## 🔧 Troubleshooting

### Error: ERROR_API_NOT_AVAILABLE

**Problem:** App not installed via Google Play Store.

**Solutions:**
- Upload app to Play Console (Internal Test track is fine)
- Install app on device via Play Store link
- Cannot test with local APK/AAB installation

### Error: ERROR_UPDATE_NOT_AVAILABLE

**Problem:** No update available or version code not higher.

**Solutions:**
- Ensure new version has **higher version code** (not just version name)
- Upload new version to same or higher track in Play Console
- Wait a few minutes after publishing for update to propagate

### Error: ERROR_UPDATE_UNAVAILABLE

**Problem:** Update exists but cannot be performed.

**Solutions:**
- Check if device meets minimum requirements (API 21+)
- Ensure sufficient storage space
- Check network connectivity

### Error: PLATFORM_NOT_SUPPORTED

**Problem:** Running on non-Android platform.

**Solutions:**
- Use platform checks before calling update methods
- Implement alternative update mechanisms for iOS
- Consider using `upgrader` package for iOS

### Flexible Update Not Installing

**Problem:** Download completes but app doesn't install.

**Solutions:**
- Must call `completeFlexibleUpdate()` after download completes
- Check `installStatusStream` for `downloaded` status
- User must confirm installation (don't force silently)

### Update Checking Too Slow

**Problem:** `checkForUpdate()` takes too long.

**Solutions:**
- Call asynchronously, don't block UI
- Cache last check time, check max once per day
- Show loading indicator if checking on user action

## 📖 Additional Resources

- **Android Docs**: [In-App Updates API](https://developer.android.com/guide/playcore/in-app-updates)
- **Testing Guide**: [Test In-App Updates](https://developer.android.com/guide/playcore/in-app-updates/test)
- **Package**: [in_app_update on pub.dev](https://pub.dev/packages/in_app_update)
- **BUMA Core**: [Architecture Guidelines](../../../../ARCHITECTURE.md)

## 🤝 Support

For issues specific to:
- **This wrapper**: Open issue in BUMA Core repository
- **in_app_update package**: See [package issues](https://github.com/erikas/in_app_update/issues)
- **Google Play API**: See [Android documentation](https://developer.android.com/guide/playcore/in-app-updates)

---

**Need a quick reference?** See [QUICK_START.md](QUICK_START.md) for condensed setup and usage guide.


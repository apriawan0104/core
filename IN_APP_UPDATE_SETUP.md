# In-App Update Setup Guide

This guide will help you integrate the In-App Update service into your Flutter app.

## 📋 Prerequisites

- Flutter app targeting Android
- Google Play Store distribution
- Android API Level 21+ (Android 5.0+)

## 📦 Installation

### 1. Add Dependencies

Add to your app's `pubspec.yaml`:

```yaml
dependencies:
  # BUMA Core library
  app_core:
    path: ../core  # or your core library path
  
  # In-App Update package
  in_app_update: ^4.2.5
  
  # Dependency Injection (if not already added)
  get_it: ^7.6.0
  
  # Functional programming (if not already added)
  dartz: ^0.10.1
```

### 2. Install Packages

```bash
flutter pub get
```

## 🔧 Configuration

### Android Setup

**Minimum Requirements:**
- `minSdkVersion` 21 or higher
- App must be distributed via Google Play Store

Update your `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Required
        targetSdkVersion 33
        // ...
    }
}
```

**No additional Android configuration needed!** The package works automatically with Google Play.

### iOS (Not Supported)

In-app updates are not supported on iOS. The service will return a `PLATFORM_NOT_SUPPORTED` error.

For iOS update prompts, consider:
- [`upgrader`](https://pub.dev/packages/upgrader) package
- Custom version checking with App Store API
- Native iOS review prompts

## 💻 Code Integration

### 1. Register Service

Create a DI setup file (e.g., `lib/core/di/service_locator.dart`):

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupInAppUpdate() {
  // Register in-app update service
  getIt.registerLazySingleton<InAppUpdateService>(
    () => AndroidInAppUpdateServiceImpl(),
  );
}
```

### 2. Initialize in Main

Update your `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup services
  setupInAppUpdate();
  
  // Initialize update service
  final updateService = getIt<InAppUpdateService>();
  final result = await updateService.initialize();
  
  result.fold(
    (failure) => print('Update service init failed: $failure'),
    (_) => print('Update service ready'),
  );
  
  runApp(MyApp());
}
```

### 3. Implement Update Check

Create an update manager (e.g., `lib/features/update/update_manager.dart`):

```dart
import 'package:app_core/app_core.dart';

class UpdateManager {
  final InAppUpdateService _updateService;
  
  UpdateManager(this._updateService);
  
  Future<void> checkForUpdates() async {
    final result = await _updateService.checkForUpdate();
    
    await result.fold(
      (failure) async {
        // Handle error (log or ignore)
        print('Update check failed: $failure');
      },
      (info) async {
        if (!info.isUpdateAvailable) {
          print('App is up to date');
          return;
        }
        
        // Handle based on priority
        if (info.updatePriority >= 4) {
          // High priority -> immediate update
          await _updateService.performImmediateUpdate();
        } else {
          // Normal priority -> flexible update
          await _startFlexibleUpdate();
        }
      },
    );
  }
  
  Future<void> _startFlexibleUpdate() async {
    final result = await _updateService.startFlexibleUpdate();
    
    result.fold(
      (failure) => print('Download failed: $failure'),
      (_) {
        // Listen for download completion
        _updateService.installStatusStream.listen((status) {
          if (status.isDownloaded) {
            _showInstallPrompt();
          }
        });
      },
    );
  }
  
  void _showInstallPrompt() {
    // Show dialog or snackbar
    // When user confirms, call:
    // await _updateService.completeFlexibleUpdate();
  }
}
```

### 4. Trigger Update Check

Check for updates on app startup or resume:

```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late UpdateManager _updateManager;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _updateManager = UpdateManager(getIt<InAppUpdateService>());
    
    // Check on startup
    _updateManager.checkForUpdates();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check when app resumes
      _updateManager.checkForUpdates();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Your app
    );
  }
}
```

## 🧪 Testing

### ⚠️ Important: Local Testing NOT Possible!

In-app updates **cannot** be tested with:
- ❌ Local APK installation
- ❌ Debug builds installed via USB
- ❌ Emulators (unless installed via Play Store)
- ❌ iOS devices

### Testing Requirements

1. **Upload to Play Console**
   - Go to [Google Play Console](https://play.google.com/console)
   - Create Internal Test track (or use Alpha/Beta)
   - Upload APK/AAB with version code 1

2. **Install on Test Device**
   - Add test users to Internal Test track
   - Share the opt-in link with testers
   - Install app via Play Store on test device

3. **Publish Update**
   - Increment version code to 2 (or higher)
   - Upload new APK/AAB to same track
   - Publish the update

4. **Test**
   - Open app on test device
   - Update check should detect new version
   - Test immediate and flexible update flows

### Testing Checklist

- [ ] App uploaded to Play Console (Internal Test track)
- [ ] Test user added and opted in
- [ ] Version 1 installed via Play Store
- [ ] Version 2 uploaded and published
- [ ] Update priority set in Play Console
- [ ] Test device has internet connection
- [ ] Test immediate update flow
- [ ] Test flexible update flow
- [ ] Test error handling

### Setting Update Priority

In Google Play Console:
1. Go to your app release
2. Edit release notes
3. Set **In-app update priority** (1-5)
   - **5**: Critical (force immediate update)
   - **4**: High (suggest immediate)
   - **3**: Medium (flexible with prompts)
   - **1-2**: Low (silent flexible)

## 🔍 Verification

### Check Service Registration

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupInAppUpdate();
  
  // Verify registration
  final updateService = getIt<InAppUpdateService>();
  print('Service registered: ${updateService != null}');
  
  // Check platform support
  final supported = await updateService.isUpdateSupported();
  supported.fold(
    (failure) => print('Error: $failure'),
    (isSupported) => print('In-app updates supported: $isSupported'),
  );
  
  runApp(MyApp());
}
```

### Test Update Check

```dart
Future<void> testUpdateCheck() async {
  final updateService = getIt<InAppUpdateService>();
  
  final result = await updateService.checkForUpdate();
  
  result.fold(
    (failure) {
      print('Error Code: ${failure.code}');
      print('Message: ${failure.message}');
      
      // Common errors:
      if (failure.code == 'ERROR_API_NOT_AVAILABLE') {
        print('❌ App not installed via Play Store');
      } else if (failure.code == 'PLATFORM_NOT_SUPPORTED') {
        print('❌ Platform not supported (iOS?)');
      }
    },
    (info) {
      print('✅ Update check successful');
      print('Update available: ${info.isUpdateAvailable}');
      print('Available version: ${info.availableVersionCode}');
      print('Priority: ${info.updatePriority}');
      print('Immediate allowed: ${info.immediateUpdateAllowed}');
      print('Flexible allowed: ${info.flexibleUpdateAllowed}');
    },
  );
}
```

## 🐛 Troubleshooting

### Error: ERROR_API_NOT_AVAILABLE

**Problem:** App not installed via Google Play Store.

**Solution:**
```bash
# 1. Upload to Play Console
# 2. Get opt-in link from Internal Test track
# 3. Install app via Play Store on test device
# DO NOT install APK directly!
```

### Error: ERROR_UPDATE_NOT_AVAILABLE

**Problem:** No update available or version code not higher.

**Solution:**
```yaml
# pubspec.yaml - Ensure version CODE is higher
# Current version
version: 1.0.0+1  # +1 is the version code

# New version - MUST increase the version code
version: 1.0.1+2  # +2 is higher than +1
```

### Error: PLATFORM_NOT_SUPPORTED

**Problem:** Running on non-Android platform.

**Solution:**
```dart
import 'dart:io';

Future<void> checkForUpdates() async {
  // Only check on Android
  if (!Platform.isAndroid) {
    print('In-app updates only available on Android');
    return;
  }
  
  final updateService = getIt<InAppUpdateService>();
  await updateService.checkForUpdate();
}
```

### Update Not Appearing

**Checklist:**
1. ✅ App installed via Play Store (not APK)
2. ✅ New version has **higher version code**
3. ✅ New version is published in Play Console
4. ✅ Device has internet connection
5. ✅ Waited a few minutes after publishing
6. ✅ Not testing on iOS device

## 📚 Additional Resources

- **Example**: See `example/in_app_update_example.dart` for complete implementation
- **Documentation**: See `lib/src/infrastructure/in_app_update/doc/README.md`
- **Quick Start**: See `lib/src/infrastructure/in_app_update/doc/QUICK_START.md`
- **Android Docs**: https://developer.android.com/guide/playcore/in-app-updates
- **Testing Guide**: https://developer.android.com/guide/playcore/in-app-updates/test

## 🤝 Support

If you encounter issues:

1. **Check logs**: Enable debug logging to see detailed error messages
2. **Verify setup**: Follow this guide step by step
3. **Test requirements**: Ensure all testing requirements are met
4. **Play Console**: Check release status in Play Console
5. **Example app**: Run the example app to verify setup

Common causes:
- App not installed via Play Store (90% of issues)
- Version code not incremented
- Update not published yet
- Testing on iOS device

---

**Next Steps:**
1. Complete setup following this guide
2. Upload test version to Play Console
3. Test update flows on real device
4. Implement smart update strategy
5. Configure update priorities in Play Console


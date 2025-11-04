# Path Provider Setup Guide

Complete setup guide for integrating the Path Provider service into your Flutter app.

## 📋 Overview

The Path Provider service provides platform-independent access to commonly used directories on the filesystem, including:

- Temporary directory
- Application documents directory
- Application support directory
- Application cache directory
- Downloads directory
- Application library directory (iOS/macOS)
- External storage directories (Android)

## 🚀 Quick Setup

### Step 1: Add Dependency

The `path_provider` package is already included in the `app_core` library, so no additional dependencies are needed in your app's `pubspec.yaml`.

### Step 2: Register Service in DI Container

Add the path provider service to your dependency injection setup:

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServices() {
  // Register path provider service
  getIt.registerLazySingleton<PathProviderService>(
    () => PathProviderServiceImpl(),
  );
}
```

### Step 3: Call Setup in Main

Initialize the service in your app's `main()` function:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup DI
  setupServices();
  
  runApp(MyApp());
}
```

### Step 4: Use the Service

Inject and use the service in your app:

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

class MyService {
  final PathProviderService _pathProvider;
  
  MyService(this._pathProvider);
  
  Future<void> saveFile(String content) async {
    final result = await _pathProvider.getApplicationDocumentsDirectory();
    
    result.fold(
      (failure) => print('Error: ${failure.message}'),
      (directory) async {
        final file = File('${directory.path}/data.txt');
        await file.writeAsString(content);
        print('File saved at: ${file.path}');
      },
    );
  }
}

// Usage in widgets
class MyWidget extends StatelessWidget {
  final pathProvider = GetIt.instance<PathProviderService>();
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _loadDocuments,
      child: Text('Load Documents'),
    );
  }
  
  Future<void> _loadDocuments() async {
    final result = await pathProvider.getApplicationDocumentsDirectory();
    
    result.fold(
      (failure) => _showError(failure.message),
      (directory) => _showDirectory(directory),
    );
  }
}
```

## 📖 Common Use Cases

### 1. Caching Images

```dart
Future<void> cacheImage(String url, Uint8List imageData) async {
  final pathProvider = getIt<PathProviderService>();
  final result = await pathProvider.getApplicationCacheDirectory();
  
  result.fold(
    (failure) => print('Cache error: ${failure.message}'),
    (cacheDir) async {
      final fileName = url.split('/').last;
      final file = File('${cacheDir.path}/$fileName');
      await file.writeAsBytes(imageData);
      print('Image cached: ${file.path}');
    },
  );
}
```

### 2. Storing User Settings

```dart
Future<void> saveSettings(Map<String, dynamic> settings) async {
  final pathProvider = getIt<PathProviderService>();
  final result = await pathProvider.getApplicationSupportDirectory();
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (supportDir) async {
      final file = File('${supportDir.path}/settings.json');
      await file.writeAsString(jsonEncode(settings));
    },
  );
}

Future<Map<String, dynamic>?> loadSettings() async {
  final pathProvider = getIt<PathProviderService>();
  final result = await pathProvider.getApplicationSupportDirectory();
  
  return result.fold(
    (failure) => null,
    (supportDir) async {
      final file = File('${supportDir.path}/settings.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content);
      }
      return null;
    },
  );
}
```

### 3. Managing Temporary Files

```dart
Future<void> processLargeFile(String inputPath) async {
  final pathProvider = getIt<PathProviderService>();
  final result = await pathProvider.getTemporaryDirectory();
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (tempDir) async {
      // Create temporary file for processing
      final tempFile = File('${tempDir.path}/processing_${DateTime.now().millisecondsSinceEpoch}.tmp');
      
      // Process file...
      
      // Cleanup
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    },
  );
}
```

### 4. Exporting User Documents

```dart
Future<void> exportDocument(String content, String filename) async {
  final pathProvider = getIt<PathProviderService>();
  final result = await pathProvider.getDownloadsDirectory();
  
  result.fold(
    (failure) {
      if (failure is DirectoryNotSupportedFailure) {
        // Fallback to documents directory
        _saveToDocuments(content, filename);
      } else {
        print('Error: ${failure.message}');
      }
    },
    (downloadsDir) async {
      if (downloadsDir != null) {
        final file = File('${downloadsDir.path}/$filename');
        await file.writeAsString(content);
        print('Exported to: ${file.path}');
      } else {
        _saveToDocuments(content, filename);
      }
    },
  );
}

Future<void> _saveToDocuments(String content, String filename) async {
  final pathProvider = getIt<PathProviderService>();
  final result = await pathProvider.getApplicationDocumentsDirectory();
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (docsDir) async {
      final file = File('${docsDir.path}/$filename');
      await file.writeAsString(content);
      print('Saved to documents: ${file.path}');
    },
  );
}
```

## 📱 Platform-Specific Setup

### Android

For external storage access on Android, add permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <!-- Add these permissions for external storage access -->
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
      android:maxSdkVersion="32" />
  
  <application ...>
    ...
  </application>
</manifest>
```

**Note**: For Android 13+ (API 33+), these permissions are not needed for app-specific directories.

### iOS

No additional setup required. All directories work out of the box.

To make documents visible in the Files app, add to `ios/Runner/Info.plist`:

```xml
<key>UIFileSharingEnabled</key>
<true/>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
```

### macOS

For macOS apps, you may need to enable app sandbox entitlements in `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

### Windows

No additional setup required.

### Linux

No additional setup required.

## 🎯 Best Practices

### 1. Always Handle Failures

```dart
// ✅ GOOD: Handle all cases
final result = await pathProvider.getApplicationDocumentsDirectory();
result.fold(
  (failure) {
    // Handle error appropriately
    _showError(failure.message);
  },
  (directory) {
    // Use directory
    _saveToDirectory(directory);
  },
);

// ❌ BAD: Ignore errors
final result = await pathProvider.getApplicationDocumentsDirectory();
result.fold((_) {}, (dir) => _saveToDirectory(dir));
```

### 2. Check for Null on Optional Directories

```dart
// ✅ GOOD: Check for null
final result = await pathProvider.getDownloadsDirectory();
result.fold(
  (failure) => _handleError(failure),
  (directory) {
    if (directory != null) {
      _useDirectory(directory);
    } else {
      _useAlternativeDirectory();
    }
  },
);
```

### 3. Platform Checks for Platform-Specific Features

```dart
// ✅ GOOD: Check platform first
if (Platform.isAndroid) {
  final result = await pathProvider.getExternalStorageDirectory();
  // Handle result
}

// ❌ BAD: Call without checking
final result = await pathProvider.getExternalStorageDirectory();
// Will fail on non-Android platforms
```

### 4. Clean Up Temporary Files Regularly

```dart
// Implement periodic cleanup
class TempFileCleanupService {
  final PathProviderService _pathProvider;
  
  TempFileCleanupService(this._pathProvider);
  
  Future<void> cleanupOldFiles(Duration maxAge) async {
    final result = await _pathProvider.getTemporaryDirectory();
    
    result.fold(
      (failure) => print('Cleanup failed: ${failure.message}'),
      (tempDir) async {
        final now = DateTime.now();
        final files = tempDir.listSync();
        
        for (var file in files) {
          if (file is File) {
            final stat = await file.stat();
            if (now.difference(stat.modified) > maxAge) {
              await file.delete();
            }
          }
        }
      },
    );
  }
}
```

### 5. Use Constants for Storage Types

```dart
// ✅ GOOD: Use predefined constants
final result = await pathProvider.getExternalStorageDirectories(
  type: PathProviderConstants.storageTypePictures,
);

// ❌ BAD: Use magic strings
final result = await pathProvider.getExternalStorageDirectories(
  type: 'pictures',
);
```

## 🧪 Testing

### Mocking the Service

```dart
import 'package:mocktail/mocktail.dart';

class MockPathProviderService extends Mock implements PathProviderService {}

void main() {
  late MockPathProviderService mockPathProvider;
  
  setUp(() {
    mockPathProvider = MockPathProviderService();
  });
  
  test('should save file to documents directory', () async {
    // Arrange
    final testDir = Directory.systemTemp.createTempSync('test_docs');
    when(() => mockPathProvider.getApplicationDocumentsDirectory())
        .thenAnswer((_) async => Right(testDir));
    
    final service = FileService(mockPathProvider);
    
    // Act
    await service.saveFile('test content');
    
    // Assert
    verify(() => mockPathProvider.getApplicationDocumentsDirectory())
        .called(1);
    
    final savedFile = File('${testDir.path}/data.txt');
    expect(await savedFile.exists(), true);
    expect(await savedFile.readAsString(), 'test content');
    
    // Cleanup
    testDir.deleteSync(recursive: true);
  });
}
```

## 🐛 Troubleshooting

### Issue: Downloads directory returns null

**Solution**: Check platform support and provide fallback:

```dart
final result = await pathProvider.getDownloadsDirectory();
result.fold(
  (failure) => _useDocumentsDirectory(),
  (directory) {
    if (directory != null) {
      _useDownloads(directory);
    } else {
      _useDocumentsDirectory();
    }
  },
);
```

### Issue: Permission denied on Android

**Solution**: Add storage permissions to AndroidManifest.xml and request runtime permissions for Android 6.0+:

```dart
// Use permission_handler package
import 'package:permission_handler/permission_handler.dart';

Future<void> requestStoragePermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted
    } else {
      // Permission denied
    }
  }
}
```

### Issue: Files disappear from temp directory

**Cause**: System automatically clears temp directory

**Solution**: Use appropriate directory for persistent files:

```dart
// For persistent files - use documents or support directory
final result = await pathProvider.getApplicationDocumentsDirectory();

// For cache files that can be recreated - use cache directory
final result = await pathProvider.getApplicationCacheDirectory();

// Only for truly temporary files - use temp directory
final result = await pathProvider.getTemporaryDirectory();
```

## 📚 Additional Resources

- [Quick Start Guide](lib/src/infrastructure/path_provider/doc/QUICK_START.md)
- [Full Documentation](lib/src/infrastructure/path_provider/doc/README.md)
- [Example App](example/path_provider_example.dart)
- [path_provider Package](https://pub.dev/packages/path_provider)

## 📋 Platform Support Matrix

| Directory                     | Android | iOS   | Linux | macOS | Windows |
|------------------------------|---------|-------|-------|-------|---------|
| Temporary                    | ✔️      | ✔️    | ✔️    | ✔️    | ✔️      |
| Application Support          | ✔️      | ✔️    | ✔️    | ✔️    | ✔️      |
| Application Documents        | ✔️      | ✔️    | ✔️    | ✔️    | ✔️      |
| Application Cache            | ✔️      | ✔️    | ✔️    | ✔️    | ✔️      |
| Application Library          | ❌      | ✔️    | ❌    | ✔️    | ❌      |
| Downloads                    | ✔️      | ✔️    | ✔️    | ✔️    | ✔️      |
| External Storage             | ✔️      | ❌    | ❌    | ❌    | ❌      |
| External Cache               | ✔️      | ❌    | ❌    | ❌    | ❌      |
| External Storage Directories | ✔️      | ❌    | ❌    | ❌    | ❌      |

## 🎓 Next Steps

1. ✅ Follow the setup steps above
2. ✅ Test the service in your app
3. ✅ Implement file operations using the service
4. ✅ Add error handling and platform checks
5. ✅ Review the [example app](example/path_provider_example.dart) for more use cases

---

**Need Help?** Check the [Quick Start Guide](lib/src/infrastructure/path_provider/doc/QUICK_START.md) or see the [full documentation](lib/src/infrastructure/path_provider/doc/README.md).


# Path Provider Service

**Platform-independent access to commonly used directories on the filesystem.**

The Path Provider service provides a clean, dependency-independent abstraction for accessing common directories like temporary, documents, cache, and downloads folders across all platforms.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Platform Support](#platform-support)
- [Architecture](#architecture)
- [Installation](#installation)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Platform-Specific Behavior](#platform-specific-behavior)
- [Best Practices](#best-practices)
- [Testing](#testing)
- [Migration Guide](#migration-guide)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

The Path Provider service wraps the `path_provider` package to provide:

- ✅ **Dependency-independent design** - Easy to switch implementations
- ✅ **Type-safe error handling** - Using `Either<Failure, T>` pattern
- ✅ **Cross-platform support** - Android, iOS, Linux, macOS, Windows
- ✅ **Well-documented API** - Clear usage examples
- ✅ **Testable** - Easy to mock for unit tests
- ✅ **Platform-aware** - Handles platform-specific limitations gracefully

### Why Use This Service?

```dart
// ❌ Without abstraction - tightly coupled to path_provider
import 'package:path_provider/path_provider.dart';

Future<void> saveFile() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    // Direct usage - hard to test, hard to replace
  } catch (e) {
    // Unclear error handling
  }
}

// ✅ With abstraction - clean, testable, replaceable
final pathProvider = getIt<PathProviderService>();

Future<void> saveFile() async {
  final result = await pathProvider.getApplicationDocumentsDirectory();
  
  result.fold(
    (failure) => _handleError(failure), // Type-safe error handling
    (directory) => _saveToDirectory(directory), // Success path
  );
}
```

## ✨ Features

### Core Features

- **Temporary Directory**: Access system temp directory for short-lived files
- **Application Documents**: User-facing documents directory
- **Application Support**: Internal app data storage
- **Application Cache**: Cached data that can be cleared
- **Downloads Directory**: User downloads folder
- **Application Library**: iOS/macOS library directory

### Platform-Specific Features

- **External Storage** (Android): Access to external SD card storage
- **External Cache** (Android): External cache directories
- **Storage Directories** (Android): Type-specific directories (Music, Pictures, etc.)

### Developer Features

- **Type-safe error handling** with `Either` pattern
- **Null-safe API** with proper null handling
- **Platform detection** to prevent unsupported calls
- **Detailed error messages** for debugging
- **Constants** for storage types and common directory names

## 🖥️ Platform Support

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

### Minimum Platform Versions

- **Android**: API 16+ (Android 4.1+)
- **iOS**: 12.0+
- **macOS**: 10.14+
- **Windows**: Windows 10+
- **Linux**: Any

## 🏗️ Architecture

### Design Principles

Following BUMA Core's **Dependency Independence** principle:

```
┌─────────────────────────────────────┐
│   Consumer App (Your Flutter App)   │
│   - Business Logic                  │
│   - UI Components                   │
└─────────────┬───────────────────────┘
              │ depends on interface
              ▼
┌─────────────────────────────────────┐
│   PathProviderService (Interface)   │
│   - Abstract methods                │
│   - Own types only                  │
└─────────────┬───────────────────────┘
              │ implemented by
              ▼
┌─────────────────────────────────────┐
│  PathProviderServiceImpl            │
│  - Wraps path_provider package      │
│  - Converts to own types            │
└─────────────┬───────────────────────┘
              │ uses
              ▼
┌─────────────────────────────────────┐
│   path_provider package             │
│   - Third-party dependency          │
└─────────────────────────────────────┘
```

### File Structure

```
infrastructure/path_provider/
├── contract/
│   ├── path_provider.service.dart   # Interface
│   └── contracts.dart                # Barrel export
├── impl/
│   ├── path_provider.service.impl.dart  # Implementation
│   └── impl.dart                     # Barrel export
├── constants/
│   ├── path_provider.constant.dart  # Constants
│   └── constants.dart                # Barrel export
├── doc/
│   ├── README.md                     # This file
│   └── QUICK_START.md                # Quick start guide
└── path_provider.dart                # Main barrel export
```

## 📦 Installation

The path provider service is already included in the BUMA Core library.

### Dependencies

The following dependencies are automatically included:

```yaml
dependencies:
  path_provider: ^2.1.5
  path_provider_android: ^2.2.0
  path_provider_foundation: ^2.3.0
  path_provider_linux: ^2.2.0
  path_provider_platform_interface: ^2.1.0
  path_provider_windows: ^2.2.0
```

## 🚀 Usage

### Basic Setup

**1. Register the service in your DI container:**

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

void setupPathProvider() {
  GetIt.instance.registerLazySingleton<PathProviderService>(
    () => PathProviderServiceImpl(),
  );
}
```

**2. Use the service:**

```dart
class FileService {
  final PathProviderService _pathProvider;
  
  FileService(this._pathProvider);
  
  Future<void> saveFile(String content) async {
    final result = await _pathProvider.getApplicationDocumentsDirectory();
    
    result.fold(
      (failure) => print('Error: ${failure.message}'),
      (directory) async {
        final file = File('${directory.path}/data.txt');
        await file.writeAsString(content);
      },
    );
  }
}
```

### Common Use Cases

#### 1. Caching Data

```dart
Future<void> cacheData(String key, String data) async {
  final pathProvider = getIt<PathProviderService>();
  final result = await pathProvider.getApplicationCacheDirectory();
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (cacheDir) async {
      final cacheFile = File('${cacheDir.path}/$key.cache');
      await cacheFile.writeAsString(data);
      print('Data cached successfully');
    },
  );
}

Future<String?> getCachedData(String key) async {
  final pathProvider = getIt<PathProviderService>();
  final result = await pathProvider.getApplicationCacheDirectory();
  
  return result.fold(
    (failure) => null,
    (cacheDir) async {
      final cacheFile = File('${cacheDir.path}/$key.cache');
      if (await cacheFile.exists()) {
        return await cacheFile.readAsString();
      }
      return null;
    },
  );
}
```

#### 2. Storing User Documents

```dart
Future<void> saveUserDocument(String filename, Uint8List data) async {
  final pathProvider = getIt<PathProviderService>();
  final result = await pathProvider.getApplicationDocumentsDirectory();
  
  result.fold(
    (failure) => _showError(failure.message),
    (docsDir) async {
      final file = File('${docsDir.path}/$filename');
      await file.writeAsBytes(data);
      _showSuccess('Document saved at: ${file.path}');
    },
  );
}
```

#### 3. Managing Temporary Files

```dart
class TempFileManager {
  final PathProviderService _pathProvider;
  
  TempFileManager(this._pathProvider);
  
  Future<File?> createTempFile(String name) async {
    final result = await _pathProvider.getTemporaryDirectory();
    
    return result.fold(
      (failure) {
        print('Error: ${failure.message}');
        return null;
      },
      (tempDir) => File('${tempDir.path}/$name'),
    );
  }
  
  Future<void> cleanupTempFiles() async {
    final result = await _pathProvider.getTemporaryDirectory();
    
    result.fold(
      (failure) => print('Error: ${failure.message}'),
      (tempDir) async {
        final files = tempDir.listSync();
        for (var file in files) {
          if (file is File) {
            await file.delete();
          }
        }
        print('Temp files cleaned');
      },
    );
  }
}
```

#### 4. Platform-Specific Storage

```dart
Future<void> saveToOptimalLocation(String data) async {
  final pathProvider = getIt<PathProviderService>();
  
  if (Platform.isAndroid) {
    // Try external storage first on Android
    final extResult = await pathProvider.getExternalStorageDirectory();
    
    extResult.fold(
      (failure) => _useInternalStorage(data),
      (extDir) async {
        if (extDir != null) {
          final file = File('${extDir.path}/data.txt');
          await file.writeAsString(data);
        } else {
          _useInternalStorage(data);
        }
      },
    );
  } else {
    // Use documents directory on other platforms
    _useInternalStorage(data);
  }
}

Future<void> _useInternalStorage(String data) async {
  final pathProvider = getIt<PathProviderService>();
  final result = await pathProvider.getApplicationDocumentsDirectory();
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (docsDir) async {
      final file = File('${docsDir.path}/data.txt');
      await file.writeAsString(data);
    },
  );
}
```

#### 5. Using Storage Type Constants

```dart
Future<void> saveToPictures(Uint8List imageData) async {
  final pathProvider = getIt<PathProviderService>();
  
  final result = await pathProvider.getExternalStorageDirectories(
    type: PathProviderConstants.storageTypePictures,
  );
  
  result.fold(
    (failure) {
      if (failure is DirectoryNotSupportedFailure) {
        print('Pictures directory only available on Android');
        _useAlternativeLocation(imageData);
      } else {
        print('Error: ${failure.message}');
      }
    },
    (directories) async {
      if (directories != null && directories.isNotEmpty) {
        final picturesDir = directories.first;
        final file = File('${picturesDir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(imageData);
        print('Photo saved to Pictures');
      } else {
        _useAlternativeLocation(imageData);
      }
    },
  );
}
```

## 📖 API Reference

### Methods

#### `getTemporaryDirectory()`

Gets the temporary directory for short-lived files.

```dart
Future<Either<PathProviderFailure, Directory>> getTemporaryDirectory()
```

**Supported Platforms**: All  
**Returns**: Directory path or PathProviderFailure

---

#### `getApplicationSupportDirectory()`

Gets the application support directory for internal app files.

```dart
Future<Either<PathProviderFailure, Directory>> getApplicationSupportDirectory()
```

**Supported Platforms**: All  
**Returns**: Directory path or PathProviderFailure

---

#### `getApplicationDocumentsDirectory()`

Gets the application documents directory for user documents.

```dart
Future<Either<PathProviderFailure, Directory>> getApplicationDocumentsDirectory()
```

**Supported Platforms**: All  
**Returns**: Directory path or PathProviderFailure

---

#### `getApplicationCacheDirectory()`

Gets the application cache directory for cached data.

```dart
Future<Either<PathProviderFailure, Directory>> getApplicationCacheDirectory()
```

**Supported Platforms**: All  
**Returns**: Directory path or PathProviderFailure

---

#### `getDownloadsDirectory()`

Gets the downloads directory. May return null if not available.

```dart
Future<Either<PathProviderFailure, Directory?>> getDownloadsDirectory()
```

**Supported Platforms**: All  
**Returns**: Directory path (or null) or PathProviderFailure

---

#### `getApplicationLibraryDirectory()`

Gets the application library directory (iOS/macOS only).

```dart
Future<Either<PathProviderFailure, Directory>> getApplicationLibraryDirectory()
```

**Supported Platforms**: iOS, macOS  
**Returns**: Directory path or DirectoryNotSupportedFailure

---

#### `getExternalStorageDirectory()`

Gets external storage directory (Android only).

```dart
Future<Either<PathProviderFailure, Directory?>> getExternalStorageDirectory()
```

**Supported Platforms**: Android  
**Returns**: Directory path (or null) or DirectoryNotSupportedFailure

---

#### `getExternalStorageDirectories()`

Gets external storage directories by type (Android only).

```dart
Future<Either<PathProviderFailure, List<Directory>?>> getExternalStorageDirectories({
  String? type,
})
```

**Supported Platforms**: Android  
**Parameters**: 
- `type` - Storage directory type (use `PathProviderConstants.storageType*`)

**Returns**: List of directories (or null) or DirectoryNotSupportedFailure

---

#### `getExternalCacheDirectories()`

Gets external cache directories (Android only).

```dart
Future<Either<PathProviderFailure, List<Directory>?>> getExternalCacheDirectories()
```

**Supported Platforms**: Android  
**Returns**: List of directories (or null) or DirectoryNotSupportedFailure

---

### Error Types

#### `PathProviderFailure`
Base failure class for all path provider errors.

#### `DirectoryNotSupportedFailure`
Thrown when a directory is not supported on the current platform.

#### `DirectoryAccessFailure`
Thrown when unable to access a directory.

#### `DirectoryNotFoundFailure`
Thrown when a directory does not exist.

#### `DirectoryCreationFailure`
Thrown when unable to create a directory.

---

### Constants

```dart
// Storage types (Android)
PathProviderConstants.storageTypeMusic
PathProviderConstants.storageTypePictures
PathProviderConstants.storageTypeMovies
PathProviderConstants.storageTypeDownloads
PathProviderConstants.storageTypeDcim
PathProviderConstants.storageTypeDocuments
// ... and more

// Common directory names
PathProviderConstants.dirNameCache
PathProviderConstants.dirNameData
PathProviderConstants.dirNameTemp
PathProviderConstants.dirNameLogs
// ... and more
```

## 🖥️ Platform-Specific Behavior

### Android

```dart
// ✅ All methods supported
await pathProvider.getTemporaryDirectory();
await pathProvider.getApplicationDocumentsDirectory();
await pathProvider.getApplicationSupportDirectory();
await pathProvider.getApplicationCacheDirectory();
await pathProvider.getDownloadsDirectory();
await pathProvider.getExternalStorageDirectory(); // Android only
await pathProvider.getExternalStorageDirectories(); // Android only
await pathProvider.getExternalCacheDirectories(); // Android only
```

**Location Examples**:
- Temp: `/data/data/com.example.app/cache/`
- Documents: `/data/data/com.example.app/app_flutter/`
- Support: `/data/data/com.example.app/files/`
- External: `/storage/emulated/0/Android/data/com.example.app/files/`

### iOS

```dart
// ✅ Supported
await pathProvider.getTemporaryDirectory();
await pathProvider.getApplicationDocumentsDirectory();
await pathProvider.getApplicationSupportDirectory();
await pathProvider.getApplicationCacheDirectory();
await pathProvider.getDownloadsDirectory(); // iOS 13+
await pathProvider.getApplicationLibraryDirectory(); // iOS only

// ❌ Not supported
await pathProvider.getExternalStorageDirectory(); // Returns DirectoryNotSupportedFailure
```

**Location Examples**:
- Documents: `<App Home>/Documents/`
- Support: `<App Home>/Library/Application Support/`
- Library: `<App Home>/Library/`

### macOS

```dart
// ✅ Supported (same as iOS)
await pathProvider.getApplicationLibraryDirectory();

// Standard directories
await pathProvider.getApplicationDocumentsDirectory(); // ~/Documents
await pathProvider.getDownloadsDirectory(); // ~/Downloads
```

### Windows

```dart
// ✅ All standard directories supported
await pathProvider.getTemporaryDirectory(); // %TEMP%
await pathProvider.getApplicationDocumentsDirectory(); // %USERPROFILE%\Documents
await pathProvider.getApplicationSupportDirectory(); // %APPDATA%\<AppName>
await pathProvider.getDownloadsDirectory(); // %USERPROFILE%\Downloads

// ❌ Not supported
await pathProvider.getExternalStorageDirectory(); // DirectoryNotSupportedFailure
```

### Linux

```dart
// ✅ Supported
await pathProvider.getTemporaryDirectory(); // /tmp
await pathProvider.getApplicationDocumentsDirectory(); // ~/Documents
await pathProvider.getApplicationSupportDirectory(); // ~/.local/share/<AppName>
await pathProvider.getDownloadsDirectory(); // ~/Downloads

// ❌ Not supported
await pathProvider.getExternalStorageDirectory(); // DirectoryNotSupportedFailure
```

## 💡 Best Practices

### 1. Always Handle Failures

```dart
// ✅ GOOD: Handle all failure cases
final result = await pathProvider.getApplicationDocumentsDirectory();
result.fold(
  (failure) {
    if (failure is DirectoryNotSupportedFailure) {
      // Handle platform not supported
    } else if (failure is DirectoryAccessFailure) {
      // Handle access denied
    } else {
      // Handle other failures
    }
  },
  (directory) => _useDirectory(directory),
);

// ❌ BAD: Ignore failures
final result = await pathProvider.getApplicationDocumentsDirectory();
result.fold((_) {}, (dir) => _useDirectory(dir));
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

// ❌ BAD: Assume non-null
final result = await pathProvider.getDownloadsDirectory();
result.fold(
  (failure) => _handleError(failure),
  (directory) => _useDirectory(directory!), // May crash!
);
```

### 3. Use Platform Checks for Platform-Specific Features

```dart
// ✅ GOOD: Check platform before calling
Future<void> saveToExternalStorage(String data) async {
  if (!Platform.isAndroid) {
    print('External storage only available on Android');
    return;
  }
  
  final result = await pathProvider.getExternalStorageDirectory();
  // ...
}

// ❌ BAD: Call without checking
final result = await pathProvider.getExternalStorageDirectory();
// Will return DirectoryNotSupportedFailure on non-Android platforms
```

### 4. Clean Up Temporary Files

```dart
// ✅ GOOD: Implement cleanup
class TempFileService {
  Future<void> cleanupOldFiles() async {
    final result = await pathProvider.getTemporaryDirectory();
    
    result.fold(
      (failure) => print('Cleanup failed: ${failure.message}'),
      (tempDir) async {
        final now = DateTime.now();
        final files = tempDir.listSync();
        
        for (var file in files) {
          if (file is File) {
            final stat = await file.stat();
            final age = now.difference(stat.modified);
            
            // Delete files older than 7 days
            if (age.inDays > 7) {
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
// ✅ GOOD: Use constants
final result = await pathProvider.getExternalStorageDirectories(
  type: PathProviderConstants.storageTypePictures,
);

// ❌ BAD: Use magic strings
final result = await pathProvider.getExternalStorageDirectories(
  type: 'pictures', // Typo-prone
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
    final testDir = Directory('/test/documents');
    when(() => mockPathProvider.getApplicationDocumentsDirectory())
        .thenAnswer((_) async => Right(testDir));
    
    final fileService = FileService(mockPathProvider);
    
    // Act
    await fileService.saveFile('test content');
    
    // Assert
    verify(() => mockPathProvider.getApplicationDocumentsDirectory())
        .called(1);
  });
  
  test('should handle directory access failure', () async {
    // Arrange
    when(() => mockPathProvider.getApplicationDocumentsDirectory())
        .thenAnswer((_) async => Left(
          DirectoryAccessFailure('Permission denied'),
        ));
    
    final fileService = FileService(mockPathProvider);
    
    // Act & Assert
    await expectLater(
      fileService.saveFile('test'),
      throwsA(isA<FileServiceException>()),
    );
  });
}
```

### Integration Testing

```dart
void main() {
  testWidgets('should display directory path', (tester) async {
    await tester.pumpWidget(MyApp());
    
    // Tap button to show documents directory
    await tester.tap(find.text('Show Documents'));
    await tester.pumpAndSettle();
    
    // Verify path is displayed
    expect(find.textContaining('/Documents'), findsOneWidget);
  });
}
```

## 🔄 Migration Guide

### From Direct path_provider Usage

**Before:**

```dart
import 'package:path_provider/path_provider.dart';

Future<void> saveFile() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data.txt');
    await file.writeAsString('data');
  } catch (e) {
    print('Error: $e');
  }
}
```

**After:**

```dart
import 'package:app_core/app_core.dart';

class FileService {
  final PathProviderService _pathProvider;
  
  FileService(this._pathProvider);
  
  Future<void> saveFile() async {
    final result = await _pathProvider.getApplicationDocumentsDirectory();
    
    result.fold(
      (failure) => print('Error: ${failure.message}'),
      (directory) async {
        final file = File('${directory.path}/data.txt');
        await file.writeAsString('data');
      },
    );
  }
}
```

### Switching Implementations

Thanks to the dependency-independent design, you can easily switch implementations:

```dart
// Current implementation (path_provider)
getIt.registerLazySingleton<PathProviderService>(
  () => PathProviderServiceImpl(),
);

// Future: Switch to custom implementation
getIt.registerLazySingleton<PathProviderService>(
  () => CustomPathProviderImpl(),
);

// No changes needed in business logic! ✅
```

## 🐛 Troubleshooting

### Issue: Downloads directory returns null

**Cause**: Downloads directory may not be available on some platforms or OS versions.

**Solution**: Always check for null and provide a fallback:

```dart
final result = await pathProvider.getDownloadsDirectory();
result.fold(
  (failure) => _useAlternative(),
  (directory) {
    if (directory != null) {
      _useDownloads(directory);
    } else {
      _useAlternative();
    }
  },
);
```

### Issue: Permission denied on Android external storage

**Cause**: Missing storage permissions in AndroidManifest.xml

**Solution**: Add permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### Issue: DirectoryNotSupportedFailure on iOS

**Cause**: Calling Android-specific methods on iOS

**Solution**: Check platform before calling:

```dart
if (Platform.isAndroid) {
  final result = await pathProvider.getExternalStorageDirectory();
  // ...
}
```

### Issue: Files disappear from temp directory

**Cause**: System automatically clears temp directory

**Solution**: Use app support or documents directory for persistent files:

```dart
// For persistent files
final result = await pathProvider.getApplicationSupportDirectory();

// For temporary files (expected to be cleared)
final result = await pathProvider.getTemporaryDirectory();
```

## 📚 Additional Resources

- [Quick Start Guide](QUICK_START.md)
- [Example App](../../../../example/path_provider_example.dart)
- [path_provider Package](https://pub.dev/packages/path_provider)
- [BUMA Core Architecture](../../../ARCHITECTURE.md)

## 🤝 Contributing

When contributing to the Path Provider service:

1. ✅ Follow the [Project Guidelines](../../../../PROJECT_GUIDELINES.md)
2. ✅ Maintain dependency independence
3. ✅ Never expose `path_provider` types in the interface
4. ✅ Add comprehensive documentation
5. ✅ Include usage examples
6. ✅ Write tests for new features

## 📝 License

Part of the BUMA Core library. See LICENSE for details.

---

**Need Help?** Check the [Quick Start Guide](QUICK_START.md) or see the [example app](../../../../example/path_provider_example.dart).


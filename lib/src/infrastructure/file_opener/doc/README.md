# File Opener Service

Layanan untuk membuka file dengan aplikasi native di Flutter.

## 📋 Daftar Isi

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Platform Support](#platform-support)
- [Installation](#installation)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Error Handling](#error-handling)
- [Testing](#testing)
- [Migration Guide](#migration-guide)

## Overview

File Opener Service adalah wrapper dependency-independent untuk membuka file dengan aplikasi native. Service ini mengabstraksi package `open_file` sehingga mudah untuk:

- ✅ Switch implementation tanpa ubah consumer code
- ✅ Test dengan mock implementations
- ✅ Handle errors secara konsisten
- ✅ Support semua platform (Android, iOS, macOS, Linux, Windows, Web)

### Design Principles

Service ini mengikuti prinsip **Dependency Independence** dari BUMA Core:

1. **No third-party types exposed** - Public API hanya menggunakan domain types
2. **Easy to replace** - Ganti dari `open_file` ke package lain hanya butuh buat implementation baru
3. **Testable** - Mudah create mock untuk testing
4. **Consistent error handling** - Menggunakan `Either<Failure, Result>`

## Features

### ✅ Basic Features

- Open file dengan default system application
- Open file dengan specific MIME type/UTI
- Check file existence
- Get MIME type from file extension
- Get UTI (iOS) from file extension
- Support all major file types (PDF, images, videos, documents, etc.)

### 🎯 Advanced Features

- Custom MIME type mapping
- Platform-specific type handling (MIME for Android, UTI for iOS)
- Detailed error types (FileNotFound, NoAppFound, PermissionDenied, etc.)
- File existence validation
- Type detection utilities

### 📱 Platform Support

| Platform | Status | Implementation |
|----------|--------|----------------|
| Android  | ✅     | Intent |
| iOS      | ✅     | UIDocumentInteractionController |
| macOS    | ✅     | NSWorkspace |
| Linux    | ✅     | xdg-open |
| Windows  | ✅     | ShellExecute |
| Web      | ✅     | dart:html |

## Architecture

### Layer Structure

```
file_opener/
├── constants/          # Constants & configurations
│   ├── file_opener.constant.dart
│   └── constants.dart
├── contract/           # Abstract interfaces (NO third-party types!)
│   ├── file_opener.service.dart
│   └── contracts.dart
├── impl/              # Implementations (can use third-party)
│   ├── open_file.service.impl.dart
│   └── impl.dart
├── models/            # Domain models
│   ├── file_open_result.model.dart
│   └── models.dart
├── doc/               # Documentation
│   ├── README.md
│   └── QUICK_START.md
└── file_opener.dart   # Barrel export
```

### Dependency Flow

```
Consumer App
     ↓
FileOpenerService (interface)
     ↓
OpenFileServiceImpl (implementation)
     ↓
open_file package (third-party)
```

**Key Point**: Consumer app hanya depend ke `FileOpenerService` interface, TIDAK ke `open_file` package!

### Contract vs Implementation

#### Contract (Abstract Interface)

```dart
abstract class FileOpenerService {
  /// NO third-party types in signature!
  Future<Either<FileOpenerFailure, FileOpenResult>> openFile(String filePath);
  Future<Either<FileOpenerFailure, FileOpenResult>> openFileWithType(
    String filePath, {
    String? mimeType,
    String? uti,
  });
  Future<Either<FileOpenerFailure, bool>> fileExists(String filePath);
  String? getMimeType(String filePath);
  String? getUTI(String filePath);
}
```

#### Implementation

```dart
class OpenFileServiceImpl implements FileOpenerService {
  // Can use third-party types internally
  @override
  Future<Either<FileOpenerFailure, FileOpenResult>> openFile(
    String filePath,
  ) async {
    // Uses open_file package internally
    final result = await open_file.OpenFile.open(filePath);
    return _handleResult(result); // Convert to domain types
  }
}
```

## Installation

### 1. Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  app_core:
    git:
      url: https://github.com/your-org/core.git
      ref: main
  
  # Implementation dependency
  open_file: ^3.5.10
```

### 2. Platform Setup

#### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          xmlns:tools="http://schemas.android.com/tools"
          package="com.example.yourapp">
    
    <!-- Permissions -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    
    <!-- Android 13+ granular permissions -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
    
    <application>
        <!-- FileProvider (if conflict with other plugins) -->
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileProvider"
            android:exported="false"
            android:grantUriPermissions="true"
            tools:replace="android:authorities">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/filepaths"
                tools:replace="android:resource" />
        </provider>
    </application>
</manifest>
```

#### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>UIFileSharingEnabled</key>
<true/>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
```

### 3. Register Service

```dart
// lib/core/di/locator.dart
import 'package:get_it/get_it.dart';
import 'package:app_core/app_core.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Register File Opener service
  getIt.registerLazySingleton<FileOpenerService>(
    () => const OpenFileServiceImpl(),
  );
}
```

## Usage

### Basic Usage

```dart
import 'package:app_core/app_core.dart';

class DocumentViewer {
  final FileOpenerService fileOpener;
  
  DocumentViewer(this.fileOpener);
  
  Future<void> openDocument(String filePath) async {
    final result = await fileOpener.openFile(filePath);
    
    result.fold(
      (failure) {
        print('Error: ${failure.message}');
      },
      (result) {
        if (result.isSuccess) {
          print('File opened successfully');
        } else if (result.isNoAppFound) {
          print('No app available to open this file');
        }
      },
    );
  }
}
```

### With Dependency Injection

```dart
class MyWidget extends StatelessWidget {
  final fileOpener = GetIt.instance<FileOpenerService>();
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _openFile(),
      child: Text('Open PDF'),
    );
  }
  
  Future<void> _openFile() async {
    final result = await fileOpener.openFile('/path/to/file.pdf');
    // Handle result...
  }
}
```

### Advanced Usage

```dart
// Open with specific MIME type
await fileOpener.openFileWithType(
  '/path/to/custom.dwg',
  mimeType: 'application/x-autocad',
  uti: 'com.autodesk.dwg',
);

// Check existence first
final exists = await fileOpener.fileExists('/path/to/file.pdf');
exists.fold(
  (failure) => print('Error checking file'),
  (exists) {
    if (exists) {
      // Open file
    } else {
      print('File not found');
    }
  },
);

// Get MIME type
final mimeType = fileOpener.getMimeType('.pdf');
print(mimeType); // 'application/pdf'

// Get UTI (iOS)
final uti = fileOpener.getUTI('.docx');
print(uti); // 'org.openxmlformats.wordprocessingml.document'
```

## API Reference

### FileOpenerService

#### Methods

##### `openFile(String filePath)`

Open file dengan default system application.

**Parameters:**
- `filePath`: Absolute path ke file

**Returns:** `Either<FileOpenerFailure, FileOpenResult>`

**Example:**
```dart
final result = await fileOpener.openFile('/path/to/document.pdf');
```

##### `openFileWithType(String filePath, {String? mimeType, String? uti})`

Open file dengan specific MIME type (Android) atau UTI (iOS).

**Parameters:**
- `filePath`: Absolute path ke file
- `mimeType`: MIME type untuk Android (optional)
- `uti`: UTI untuk iOS (optional)

**Returns:** `Either<FileOpenerFailure, FileOpenResult>`

**Example:**
```dart
final result = await fileOpener.openFileWithType(
  '/path/to/file.dwg',
  mimeType: 'application/x-autocad',
  uti: 'com.autodesk.dwg',
);
```

##### `openFileObject(File file, {String? mimeType, String? uti})`

Open File object dengan optional type override.

**Parameters:**
- `file`: File object to open
- `mimeType`: MIME type untuk Android (optional)
- `uti`: UTI untuk iOS (optional)

**Returns:** `Either<FileOpenerFailure, FileOpenResult>`

**Example:**
```dart
final file = File('/path/to/document.pdf');
final result = await fileOpener.openFileObject(file);
```

##### `fileExists(String filePath)`

Check apakah file exists di path tertentu.

**Parameters:**
- `filePath`: Path to check

**Returns:** `Either<FileOpenerFailure, bool>`

**Example:**
```dart
final result = await fileOpener.fileExists('/path/to/file.pdf');
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (exists) => print('File exists: $exists'),
);
```

##### `getMimeType(String filePath)`

Get MIME type berdasarkan file extension.

**Parameters:**
- `filePath`: File path atau extension (e.g., '.pdf' atau '/path/file.pdf')

**Returns:** `String?` - MIME type, atau null jika unknown

**Example:**
```dart
final mimeType = fileOpener.getMimeType('.pdf');
print(mimeType); // 'application/pdf'
```

##### `getUTI(String filePath)`

Get UTI (Uniform Type Identifier) untuk iOS berdasarkan file extension.

**Parameters:**
- `filePath`: File path atau extension

**Returns:** `String?` - UTI for iOS/macOS, null on other platforms atau unknown extension

**Example:**
```dart
final uti = fileOpener.getUTI('.docx');
print(uti); // 'org.openxmlformats.wordprocessingml.document' (iOS)
```

### FileOpenResult

Result model yang berisi informasi tentang hasil file opening operation.

#### Properties

- `bool success` - Whether operation was successful
- `String message` - Result message dari platform
- `String filePath` - File path yang di-open

#### Getters

- `bool isSuccess` - Check if truly successful (success && message == 'done')
- `bool isNoAppFound` - No app found to open file
- `bool isFileNotFound` - File not found
- `bool isPermissionDenied` - Permission denied
- `bool isUnknownError` - Unknown error

**Example:**
```dart
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (result) {
    if (result.isSuccess) {
      print('Success!');
    } else if (result.isNoAppFound) {
      print('No app found');
    } else if (result.isFileNotFound) {
      print('File not found');
    } else if (result.isPermissionDenied) {
      print('Permission denied');
    }
  },
);
```

## Error Handling

### Failure Types

File Opener service menggunakan typed failures untuk better error handling:

#### `FileNotFoundFailure`

File tidak ditemukan di path yang diberikan.

```dart
class FileNotFoundFailure extends FileOpenerFailure {
  final String filePath;
  const FileNotFoundFailure(this.filePath);
}
```

#### `NoAppFoundFailure`

Tidak ada aplikasi yang bisa open file type tersebut.

```dart
class NoAppFoundFailure extends FileOpenerFailure {
  final String fileType;
  const NoAppFoundFailure(this.fileType);
}
```

#### `PermissionDeniedFailure`

Tidak ada permission untuk open file.

```dart
class PermissionDeniedFailure extends FileOpenerFailure {
  final String filePath;
  const PermissionDeniedFailure(this.filePath);
}
```

#### `InvalidFilePathFailure`

File path invalid atau malformed.

```dart
class InvalidFilePathFailure extends FileOpenerFailure {
  final String filePath;
  const InvalidFilePathFailure(this.filePath);
}
```

#### `FileOpenTimeoutFailure`

Operation timeout.

```dart
class FileOpenTimeoutFailure extends FileOpenerFailure {
  const FileOpenTimeoutFailure();
}
```

#### `UnknownFileOpenerFailure`

Unknown/unexpected error.

```dart
class UnknownFileOpenerFailure extends FileOpenerFailure {
  final String? details;
  const UnknownFileOpenerFailure([this.details]);
}
```

### Handling Failures

```dart
Future<void> openWithFullErrorHandling(String filePath) async {
  final result = await fileOpener.openFile(filePath);
  
  result.fold(
    (failure) {
      if (failure is FileNotFoundFailure) {
        showError('File not found: ${failure.filePath}');
      } else if (failure is NoAppFoundFailure) {
        showError(
          'No app available to open ${failure.fileType} files.\n'
          'Please install a compatible app.',
        );
      } else if (failure is PermissionDeniedFailure) {
        showError('Permission denied. Please grant storage permission.');
      } else if (failure is InvalidFilePathFailure) {
        showError('Invalid file path: ${failure.filePath}');
      } else {
        showError('Unknown error: ${failure.message}');
      }
    },
    (result) {
      if (result.isSuccess) {
        showSuccess('File opened successfully');
      } else {
        showError('Failed to open: ${result.message}');
      }
    },
  );
}
```

## Testing

### Mock Implementation

```dart
class MockFileOpenerService implements FileOpenerService {
  @override
  Future<Either<FileOpenerFailure, FileOpenResult>> openFile(
    String filePath,
  ) async {
    return Right(FileOpenResult(
      success: true,
      message: 'done',
      filePath: filePath,
    ));
  }
  
  @override
  Future<Either<FileOpenerFailure, FileOpenResult>> openFileWithType(
    String filePath, {
    String? mimeType,
    String? uti,
  }) async {
    return Right(FileOpenResult(
      success: true,
      message: 'done',
      filePath: filePath,
    ));
  }
  
  @override
  Future<Either<FileOpenerFailure, FileOpenResult>> openFileObject(
    File file, {
    String? mimeType,
    String? uti,
  }) async {
    return openFile(file.path);
  }
  
  @override
  Future<Either<FileOpenerFailure, bool>> fileExists(String filePath) async {
    return const Right(true);
  }
  
  @override
  String? getMimeType(String filePath) {
    if (filePath.endsWith('.pdf')) return 'application/pdf';
    if (filePath.endsWith('.jpg')) return 'image/jpeg';
    return null;
  }
  
  @override
  String? getUTI(String filePath) {
    if (filePath.endsWith('.pdf')) return 'com.adobe.pdf';
    return null;
  }
}
```

### Unit Tests

```dart
void main() {
  late MockFileOpenerService fileOpener;
  
  setUp(() {
    fileOpener = MockFileOpenerService();
  });
  
  group('FileOpenerService', () {
    test('should open file successfully', () async {
      final result = await fileOpener.openFile('/test/file.pdf');
      
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (result) {
          expect(result.isSuccess, true);
          expect(result.filePath, '/test/file.pdf');
        },
      );
    });
    
    test('should check file existence', () async {
      final result = await fileOpener.fileExists('/test/file.pdf');
      
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (exists) => expect(exists, true),
      );
    });
    
    test('should get MIME type', () {
      final mimeType = fileOpener.getMimeType('.pdf');
      expect(mimeType, 'application/pdf');
    });
  });
}
```

## Migration Guide

### Switching from Direct `open_file` Usage

If you're currently using `open_file` package directly, here's how to migrate:

#### Before (Direct Usage)

```dart
import 'package:open_file/open_file.dart';

class MyWidget {
  Future<void> openFile() async {
    final result = await OpenFile.open('/path/to/file.pdf');
    if (result.type == ResultType.done) {
      print('Opened');
    }
  }
}
```

#### After (Using FileOpenerService)

```dart
import 'package:app_core/app_core.dart';

class MyWidget {
  final FileOpenerService fileOpener;
  
  MyWidget(this.fileOpener);
  
  Future<void> openFile() async {
    final result = await fileOpener.openFile('/path/to/file.pdf');
    result.fold(
      (failure) => print('Error: ${failure.message}'),
      (result) {
        if (result.isSuccess) {
          print('Opened');
        }
      },
    );
  }
}
```

### Benefits of Migration

1. ✅ **Testable** - Easy to mock for testing
2. ✅ **Consistent** - Follows BUMA Core patterns
3. ✅ **Flexible** - Easy to switch implementations
4. ✅ **Type-safe** - Proper error types

### Switching to Different Package

If you want to use a different package instead of `open_file`:

1. Create new implementation:

```dart
class CustomFileOpenerImpl implements FileOpenerService {
  // Implement using your preferred package
}
```

2. Update DI registration:

```dart
getIt.registerLazySingleton<FileOpenerService>(
  () => CustomFileOpenerImpl(), // Changed one line!
);
```

3. **No changes needed** in consumer code! 🎉

## Contributing

When adding features or fixing bugs:

1. ✅ Keep contract (interface) stable
2. ✅ Never expose third-party types in public API
3. ✅ Add proper error types
4. ✅ Update documentation
5. ✅ Add tests
6. ✅ Follow BUMA Core architecture principles

## License

See [LICENSE](../../../../LICENSE) file in root project.

## Support

- 📖 [Quick Start Guide](QUICK_START.md)
- 💼 [Example App](/example/file_opener_example.dart)
- 🏗️ [Architecture Guide](/ARCHITECTURE.md)
- 📝 [Main README](/README.md)


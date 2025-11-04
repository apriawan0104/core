# File Opener Setup Guide

Panduan lengkap setup File Opener service untuk BUMA Core.

## 📋 Daftar Isi

- [Overview](#overview)
- [Installation](#installation)
- [Platform Configuration](#platform-configuration)
- [Registration](#registration)
- [Basic Usage](#basic-usage)
- [Troubleshooting](#troubleshooting)

## Overview

File Opener Service memungkinkan aplikasi Anda membuka file dengan aplikasi native di device. Service ini support berbagai jenis file dan platform (Android, iOS, macOS, Linux, Windows, Web).

### Supported File Types

- **Documents**: PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX, TXT, RTF, CSV
- **Images**: JPG, PNG, GIF, BMP, WEBP, SVG
- **Videos**: MP4, AVI, MOV, WMV, FLV, MKV, WEBM, 3GP
- **Audio**: MP3, WAV, OGG, M4A, FLAC, AAC
- **Archives**: ZIP, RAR, 7Z, TAR, GZ
- **Others**: HTML, JSON, XML, APK, dan lainnya

## Installation

### 1. Add Package Dependencies

Add to your `pubspec.yaml`:

```yaml
dependencies:
  # BUMA Core library
  app_core:
    git:
      url: https://github.com/your-org/core.git
      ref: main
  
  # File opener implementation package
  open_file: ^3.5.10
  
  # (Optional) Path provider for file paths
  path_provider: ^2.1.5
```

Run:

```bash
flutter pub get
```

### 2. Import Package

```dart
import 'package:app_core/app_core.dart';
```

## Platform Configuration

### Android Setup

#### 1. AndroidManifest.xml Configuration

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          xmlns:tools="http://schemas.android.com/tools"
          package="com.example.yourapp">
    
    <!-- Storage Permissions -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    
    <!-- Android 13+ Granular Media Permissions -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
    
    <application
        android:label="Your App Name"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Your app activities, services, etc. -->
        
        <!-- FileProvider Configuration -->
        <!-- Only add if you get FileProvider conflict errors -->
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

#### 2. FileProvider Paths (Optional)

Create `android/app/src/main/res/xml/filepaths.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-path name="external_files" path="." />
    <cache-path name="cache" path="." />
    <files-path name="files" path="." />
</paths>
```

#### 3. Gradle Configuration (If Needed)

If you encounter dependency conflict errors, add to `android/build.gradle`:

```gradle
subprojects {
    project.configurations.all {
        resolutionStrategy.eachDependency { details ->
            if (details.requested.group == 'com.android.support'
                    && !details.requested.name.contains('multidex') ) {
                details.useVersion "28.0.0"
            }
        }
    }
}
```

### iOS Setup

#### 1. Info.plist Configuration

Add to `ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Existing keys... -->
    
    <!-- Enable file sharing -->
    <key>UIFileSharingEnabled</key>
    <true/>
    
    <!-- Allow opening documents in place -->
    <key>LSSupportsOpeningDocumentsInPlace</key>
    <true/>
    
    <!-- (Optional) If you need to declare specific document types -->
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>PDF Document</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>com.adobe.pdf</string>
            </array>
        </dict>
        <!-- Add more document types as needed -->
    </array>
    
</dict>
</plist>
```

#### 2. Minimum iOS Version

Ensure minimum iOS version in `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

### macOS Setup

#### 1. Entitlements

Add to `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Existing entitlements... -->
    
    <!-- Allow file access -->
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    
    <!-- (Optional) If you need full file system access -->
    <key>com.apple.security.files.downloads.read-write</key>
    <true/>
    
</dict>
</plist>
```

### Linux Setup

No additional configuration needed. Ensure `xdg-open` is available on the system.

### Windows Setup

No additional configuration needed. Uses Windows shell to open files.

### Web Setup

No additional configuration needed. Files will be downloaded/opened in browser.

## Registration

### Setup Dependency Injection

Create or update your DI setup file:

```dart
// lib/core/di/locator.dart
import 'package:get_it/get_it.dart';
import 'package:app_core/app_core.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Register File Opener Service
  getIt.registerLazySingleton<FileOpenerService>(
    () => const OpenFileServiceImpl(),
  );
  
  // (Optional) Register other services you need
  // getIt.registerLazySingleton<PathProviderService>(
  //   () => PathProviderServiceImpl(),
  // );
}
```

### Initialize in main.dart

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'core/di/locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup dependency injection
  setupLocator();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: MyHomePage(),
    );
  }
}
```

## Basic Usage

### 1. Simple File Opening

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

class DocumentViewer extends StatelessWidget {
  final fileOpener = GetIt.instance<FileOpenerService>();
  
  Future<void> openPdf() async {
    final filePath = '/path/to/document.pdf';
    
    final result = await fileOpener.openFile(filePath);
    
    result.fold(
      (failure) {
        // Handle error
        print('Error: ${failure.message}');
      },
      (result) {
        if (result.isSuccess) {
          print('File opened successfully!');
        } else if (result.isNoAppFound) {
          print('No PDF reader installed');
        }
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: openPdf,
      child: Text('Open PDF'),
    );
  }
}
```

### 2. With Error Handling

```dart
Future<void> openFileWithErrorHandling(String filePath) async {
  final fileOpener = GetIt.instance<FileOpenerService>();
  
  // Check if file exists first
  final existsResult = await fileOpener.fileExists(filePath);
  
  await existsResult.fold(
    (failure) async {
      _showError('Error checking file: ${failure.message}');
    },
    (exists) async {
      if (!exists) {
        _showError('File not found');
        return;
      }
      
      // Open the file
      final openResult = await fileOpener.openFile(filePath);
      
      openResult.fold(
        (failure) {
          if (failure is FileNotFoundFailure) {
            _showError('File not found: ${failure.filePath}');
          } else if (failure is NoAppFoundFailure) {
            _showError(
              'No app available to open ${failure.fileType} files.\n'
              'Please install a compatible app from Play Store/App Store.',
            );
          } else if (failure is PermissionDeniedFailure) {
            _showError(
              'Permission denied.\n'
              'Please grant storage permission in Settings.',
            );
          } else {
            _showError('Error: ${failure.message}');
          }
        },
        (result) {
          if (result.isSuccess) {
            _showSuccess('File opened successfully');
          } else {
            _showError('Failed: ${result.message}');
          }
        },
      );
    },
  );
}

void _showError(String message) {
  // Show error to user
  print('ERROR: $message');
}

void _showSuccess(String message) {
  // Show success to user
  print('SUCCESS: $message');
}
```

### 3. Custom MIME Type

```dart
Future<void> openCustomFile() async {
  final fileOpener = GetIt.instance<FileOpenerService>();
  
  // Open CAD file with specific MIME type
  final result = await fileOpener.openFileWithType(
    '/path/to/drawing.dwg',
    mimeType: 'application/x-autocad',  // Android
    uti: 'com.autodesk.dwg',            // iOS
  );
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (result) => print('Opened CAD file'),
  );
}
```

### 4. Download and Open

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

Future<void> downloadAndOpenFile(String url, String fileName) async {
  final fileOpener = GetIt.instance<FileOpenerService>();
  
  try {
    // 1. Get downloads directory
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    
    // 2. Download file
    print('Downloading $fileName...');
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode != 200) {
      throw Exception('Download failed: ${response.statusCode}');
    }
    
    // 3. Save to file
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    print('Downloaded to: $filePath');
    
    // 4. Open the file
    final result = await fileOpener.openFile(filePath);
    
    result.fold(
      (failure) => print('Cannot open file: ${failure.message}'),
      (result) {
        if (result.isSuccess) {
          print('File opened successfully');
        } else if (result.isNoAppFound) {
          print('No app available to open this file type');
        }
      },
    );
    
  } catch (e) {
    print('Error: $e');
  }
}

// Usage
await downloadAndOpenFile(
  'https://example.com/document.pdf',
  'report.pdf',
);
```

## Troubleshooting

### Common Issues

#### 1. "File not found" Error

**Problem**: File path is incorrect or file doesn't exist.

**Solution**:
- Use absolute paths, not relative paths
- Check file existence before opening:
  ```dart
  final exists = await fileOpener.fileExists(filePath);
  ```
- Use `path_provider` to get correct directory paths

#### 2. "No app found" Error

**Problem**: No application installed that can handle this file type.

**Solution**:
- Check if appropriate viewer app is installed (PDF reader, image viewer, etc.)
- Provide helpful message to user suggesting which app to install
- Consider implementing fallback (e.g., web view for some file types)

#### 3. "Permission denied" Error (Android)

**Problem**: App doesn't have storage permission.

**Solution**:
- Request permission before opening file:
  ```dart
  // Use permission_handler package
  import 'package:permission_handler/permission_handler.dart';
  
  final status = await Permission.storage.request();
  if (status.isGranted) {
    await fileOpener.openFile(filePath);
  } else {
    print('Storage permission denied');
  }
  ```

#### 4. FileProvider Conflict (Android)

**Problem**: Multiple plugins defining FileProvider.

**Solution**: Add `tools:replace` in AndroidManifest.xml (see Android Setup above).

#### 5. FileUriExposedException (Android 7+)

**Problem**: Trying to expose file:// URI on Android 7+.

**Solution**: The `open_file` package handles this automatically via FileProvider. Ensure your AndroidManifest.xml is configured correctly.

#### 6. File Opens but Shows "Cannot Display"

**Problem**: File is corrupted or wrong MIME type.

**Solution**:
- Verify file is not corrupted
- Try specifying explicit MIME type:
  ```dart
  await fileOpener.openFileWithType(
    filePath,
    mimeType: 'application/pdf',
  );
  ```

#### 7. iOS: "Cannot Open File"

**Problem**: Missing Info.plist configuration.

**Solution**: Add required keys to Info.plist (see iOS Setup above).

### Platform-Specific Notes

#### Android

- Requires FileProvider for Android 7+ (handled automatically)
- May show app chooser if multiple apps can open the file
- Storage permissions required for external files
- Android 13+ requires granular media permissions

#### iOS

- Uses UIDocumentInteractionController
- Shows iOS share sheet if no default app
- Files app integration available with proper configuration
- UTI (Uniform Type Identifier) preferred over MIME type

#### macOS

- Requires proper entitlements for file access
- Opens with default app set in macOS
- May need additional permissions for certain folders

#### Linux

- Depends on `xdg-open` being available
- Default app based on desktop environment settings
- May not work properly in some minimal environments

#### Windows

- Uses ShellExecute
- Opens with default Windows app
- File association based on Windows registry

#### Web

- Downloads file to browser's download folder
- Browser may block automatic downloads
- Opening behavior depends on browser settings

### Debug Tips

1. **Check MIME Type**:
   ```dart
   final mimeType = fileOpener.getMimeType(filePath);
   print('MIME type: $mimeType');
   ```

2. **Check File Existence**:
   ```dart
   final exists = await fileOpener.fileExists(filePath);
   print('File exists: $exists');
   ```

3. **Try Explicit Type**:
   ```dart
   // Instead of:
   await fileOpener.openFile(filePath);
   
   // Try:
   await fileOpener.openFileWithType(
     filePath,
     mimeType: 'application/pdf',
   );
   ```

4. **Check Platform**:
   ```dart
   import 'dart:io';
   
   if (Platform.isAndroid) {
     print('Running on Android');
   } else if (Platform.isIOS) {
     print('Running on iOS');
   }
   ```

5. **Enable Logging**:
   ```dart
   result.fold(
     (failure) => print('FAILURE: ${failure.runtimeType} - ${failure.message}'),
     (result) => print('SUCCESS: ${result.success} - ${result.message}'),
   );
   ```

## Next Steps

- 📖 Read [QUICK_START.md](lib/src/infrastructure/file_opener/doc/QUICK_START.md) for quick examples
- 📚 See [README.md](lib/src/infrastructure/file_opener/doc/README.md) for complete API documentation
- 💼 Check [example app](example/file_opener_example.dart) for full working examples
- 🏗️ Learn [Architecture](ARCHITECTURE.md) to understand the design

## Support

For issues or questions:
- Check [Common Issues](#common-issues) above
- Review [open_file package documentation](https://pub.dev/packages/open_file)
- Create issue in repository

## References

- [open_file package](https://pub.dev/packages/open_file)
- [path_provider package](https://pub.dev/packages/path_provider)
- [permission_handler package](https://pub.dev/packages/permission_handler)
- [Android FileProvider Guide](https://developer.android.com/reference/androidx/core/content/FileProvider)
- [iOS Document Interaction](https://developer.apple.com/documentation/uikit/uidocumentinteractioncontroller)


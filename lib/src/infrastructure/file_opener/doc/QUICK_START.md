# File Opener - Quick Start Guide

Quick start guide untuk menggunakan File Opener service di BUMA Core.

## 📦 Installation

### 1. Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  app_core:
    git:
      url: https://github.com/your-org/core.git
      ref: main
  
  # Implementation dependency (open_file package)
  open_file: ^3.5.10
```

### 2. Platform Configuration

#### Android (AndroidManifest.xml)

Jika terjadi konflik dengan FileProvider dari plugin lain, tambahkan kode ini:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          xmlns:tools="http://schemas.android.com/tools"
          package="com.example.yourapp">
    <application>
        <!-- ... other config ... -->
        
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

#### iOS (Info.plist)

Jika app Anda perlu membuka file dari external storage atau iCloud:

```xml
<key>UIFileSharingEnabled</key>
<true/>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
```

#### Permissions

Untuk membuka file dari external storage, tambahkan permission:

**Android** (AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
```

**Android 13+** (Granular permissions):
```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
```

## 🚀 Basic Usage

### 1. Register Service

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

### 2. Open a File

```dart
import 'package:app_core/app_core.dart';

class MyWidget extends StatelessWidget {
  final FileOpenerService fileOpener = getIt<FileOpenerService>();

  Future<void> openDocument() async {
    final filePath = '/path/to/document.pdf';
    
    final result = await fileOpener.openFile(filePath);

    result.fold(
      (failure) => print('Error: ${failure.message}'),
      (result) {
        if (result.isSuccess) {
          print('File opened successfully!');
        } else if (result.isNoAppFound) {
          print('No app available to open this file');
        }
      },
    );
  }
}
```

### 3. Open with Specific MIME Type

```dart
Future<void> openCustomFile() async {
  final result = await fileOpener.openFileWithType(
    '/path/to/custom.dwg',
    mimeType: 'application/x-autocad',  // For Android
    uti: 'com.autodesk.dwg',            // For iOS
  );

  result.fold(
    (failure) => showErrorDialog(failure.message),
    (result) {
      if (result.isSuccess) {
        showSuccessMessage('File opened!');
      }
    },
  );
}
```

### 4. Check File Exists Before Opening

```dart
Future<void> openFileSafely(String filePath) async {
  // Check if file exists first
  final existsResult = await fileOpener.fileExists(filePath);
  
  await existsResult.fold(
    (failure) async {
      print('Error checking file: ${failure.message}');
    },
    (exists) async {
      if (exists) {
        // File exists, proceed to open
        final openResult = await fileOpener.openFile(filePath);
        openResult.fold(
          (failure) => print('Error: ${failure.message}'),
          (result) => print('File opened'),
        );
      } else {
        print('File does not exist');
      }
    },
  );
}
```

## 📄 Common File Types

### Open PDF

```dart
Future<void> openPdf(String pdfPath) async {
  final result = await fileOpener.openFile(pdfPath);
  // Automatically uses 'application/pdf' mime type
  
  result.fold(
    (failure) => print('Cannot open PDF: ${failure.message}'),
    (result) => print('PDF opened'),
  );
}
```

### Open Image

```dart
Future<void> openImage(String imagePath) async {
  final result = await fileOpener.openFile(imagePath);
  // Automatically detects image/jpeg or image/png
  
  result.fold(
    (failure) => print('Cannot open image: ${failure.message}'),
    (result) => print('Image opened'),
  );
}
```

### Open Video

```dart
Future<void> openVideo(String videoPath) async {
  final result = await fileOpener.openFile(videoPath);
  // Automatically detects video/mp4, etc.
  
  result.fold(
    (failure) => print('Cannot open video: ${failure.message}'),
    (result) => print('Video opened'),
  );
}
```

### Open Office Documents

```dart
// Word document
await fileOpener.openFile('/path/to/document.docx');

// Excel spreadsheet
await fileOpener.openFile('/path/to/spreadsheet.xlsx');

// PowerPoint presentation
await fileOpener.openFile('/path/to/presentation.pptx');
```

## 🔍 Get MIME Type from Extension

```dart
// Get MIME type for a file
final mimeType = fileOpener.getMimeType('/path/to/file.pdf');
print(mimeType); // 'application/pdf'

// Works with just extension too
final mimeType2 = fileOpener.getMimeType('.jpg');
print(mimeType2); // 'image/jpeg'

// Returns null for unknown types
final mimeType3 = fileOpener.getMimeType('.unknown');
print(mimeType3); // null
```

## 🍎 iOS-Specific: UTI (Uniform Type Identifier)

```dart
// Get UTI for iOS
final uti = fileOpener.getUTI('/path/to/file.pdf');
print(uti); // 'com.adobe.pdf' (on iOS/macOS)

// Returns null on non-iOS platforms
final uti2 = fileOpener.getUTI('.docx');
// Android: null
// iOS: 'org.openxmlformats.wordprocessingml.document'
```

## 📂 Open Downloaded Files

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> openDownloadedFile(String fileName) async {
  // Get downloads directory
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';
  
  // Check if file exists
  final file = File(filePath);
  if (!await file.exists()) {
    print('File not found');
    return;
  }
  
  // Open the file
  final result = await fileOpener.openFile(filePath);
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (result) => print('Opened: $fileName'),
  );
}
```

## 🎨 Custom File Types

```dart
// Define custom MIME type mappings
const customTypes = {
  '.dwg': 'application/x-autocad',
  '.skp': 'application/vnd.sketchup.skp',
  '.blend': 'application/x-blender',
};

Future<void> openCustomFileType(String filePath) async {
  final extension = path.extension(filePath);
  final mimeType = customTypes[extension];
  
  final result = await fileOpener.openFileWithType(
    filePath,
    mimeType: mimeType,
  );
  
  result.fold(
    (failure) {
      if (failure is NoAppFoundFailure) {
        print('Please install an app that can open $extension files');
      } else {
        print('Error: ${failure.message}');
      }
    },
    (result) => print('File opened'),
  );
}
```

## ⚠️ Error Handling

```dart
Future<void> openFileWithFullErrorHandling(String filePath) async {
  final result = await fileOpener.openFile(filePath);

  result.fold(
    (failure) {
      // Handle different types of failures
      if (failure is FileNotFoundFailure) {
        showDialog(context, 'File not found: ${failure.filePath}');
      } else if (failure is NoAppFoundFailure) {
        showDialog(
          context,
          'No app available to open ${failure.fileType} files.\n'
          'Please install a compatible app.',
        );
      } else if (failure is PermissionDeniedFailure) {
        showDialog(
          context,
          'Permission denied. Please grant storage permission.',
        );
      } else if (failure is InvalidFilePathFailure) {
        showDialog(context, 'Invalid file path');
      } else {
        showDialog(context, 'Error: ${failure.message}');
      }
    },
    (result) {
      if (result.isSuccess) {
        print('File opened successfully');
      } else if (result.isNoAppFound) {
        showDialog(context, 'No app to open this file');
      } else if (result.isFileNotFound) {
        showDialog(context, 'File not found');
      } else if (result.isPermissionDenied) {
        showDialog(context, 'Permission denied');
      } else {
        showDialog(context, 'Error: ${result.message}');
      }
    },
  );
}
```

## 📱 Platform-Specific Behavior

### Android

- Uses Intent to open files
- MIME type determines which app to use
- User may see app chooser if multiple apps available
- Requires FileProvider for Android 7+ (handled automatically)

### iOS

- Uses UIDocumentInteractionController
- UTI (Uniform Type Identifier) preferred over MIME type
- Shows iOS share sheet if no default app
- Files app integration available

### macOS

- Uses NSWorkspace to open files
- Default app based on file extension
- Same behavior as "Open With" in Finder

### Linux

- Uses xdg-open command
- Default app based on desktop environment settings

### Windows

- Uses ShellExecute
- Default app based on file association

### Web

- Uses dart:html to download/open files
- Browser-dependent behavior

## 🔧 Testing

```dart
// Create mock for testing
class MockFileOpenerService implements FileOpenerService {
  @override
  Future<Either<FileOpenerFailure, FileOpenResult>> openFile(
    String filePath,
  ) async {
    // Mock implementation
    return Right(FileOpenResult(
      success: true,
      message: 'done',
      filePath: filePath,
    ));
  }

  @override
  Future<Either<FileOpenerFailure, bool>> fileExists(
    String filePath,
  ) async {
    return const Right(true);
  }

  // Implement other methods...
}

// Use in tests
void main() {
  test('should open file successfully', () async {
    final mockOpener = MockFileOpenerService();
    final result = await mockOpener.openFile('/test/file.pdf');
    
    expect(result.isRight(), true);
  });
}
```

## 📚 Next Steps

- See [README.md](README.md) for detailed documentation
- Check [example app](/example/file_opener_example.dart) for more examples
- Read about [architecture patterns](/ARCHITECTURE.md)

## 🆘 Common Issues

### "File not found" error

**Cause**: File path is incorrect or file doesn't exist

**Solution**: 
- Check file path is absolute, not relative
- Use `fileOpener.fileExists()` to verify before opening
- Use path_provider to get correct directory paths

```dart
// ❌ BAD: Relative path
await fileOpener.openFile('documents/file.pdf');

// ✅ GOOD: Absolute path
final directory = await getApplicationDocumentsDirectory();
await fileOpener.openFile('${directory.path}/file.pdf');
```

### "No app found" error

**Cause**: No app installed to handle this file type

**Solution**:
- Check if appropriate app is installed (PDF reader, image viewer, etc.)
- Provide helpful error message to user
- Consider opening in web view as fallback

```dart
result.fold(
  (failure) {
    if (failure is NoAppFoundFailure) {
      showDialog(
        context,
        'Please install a PDF reader to view this document',
      );
    }
  },
  (result) { /* success */ },
);
```

### "Permission denied" error (Android)

**Cause**: App doesn't have storage permission

**Solution**: Request permission before opening file

```dart
// Use permission_handler package
if (await Permission.storage.request().isGranted) {
  await fileOpener.openFile(filePath);
} else {
  print('Storage permission denied');
}
```

### FileProvider conflict (Android)

**Cause**: Multiple plugins defining FileProvider

**Solution**: Add `tools:replace` in AndroidManifest.xml (see Platform Configuration above)

### File opens but shows error on Android 7+

**Cause**: FileUriExposedException (need FileProvider)

**Solution**: The `open_file` package handles this automatically, but ensure your AndroidManifest.xml is configured correctly.

## 💡 Pro Tips

1. **Always check file existence first** - Use `fileExists()` to avoid errors
2. **Handle NoAppFound gracefully** - Guide users to install appropriate apps
3. **Use correct paths** - Always use absolute paths, not relative
4. **Request permissions** - Check and request storage permissions on Android
5. **Test on real devices** - File associations may differ from emulators
6. **Provide fallbacks** - Consider web view or custom viewer for common types
7. **Log MIME types** - Use `getMimeType()` to debug file type detection
8. **Custom types need explicit MIME** - Use `openFileWithType()` for unusual extensions

## 🎯 Real-World Examples

### Download and Open PDF Report

```dart
Future<void> downloadAndOpenReport(String url) async {
  try {
    // 1. Download file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/report.pdf';
    
    final dio = Dio();
    await dio.download(url, filePath);
    
    // 2. Check if downloaded successfully
    final existsResult = await fileOpener.fileExists(filePath);
    final exists = existsResult.fold((_) => false, (exists) => exists);
    
    if (!exists) {
      showError('Download failed');
      return;
    }
    
    // 3. Open the file
    final openResult = await fileOpener.openFile(filePath);
    openResult.fold(
      (failure) => showError('Cannot open file: ${failure.message}'),
      (result) {
        if (result.isSuccess) {
          showSuccess('Report opened');
        } else if (result.isNoAppFound) {
          showError('Please install a PDF reader');
        }
      },
    );
  } catch (e) {
    showError('Error: $e');
  }
}
```

### View Cached Image

```dart
Future<void> viewCachedImage(String imageUrl) async {
  final cacheDir = await getTemporaryDirectory();
  final fileName = imageUrl.split('/').last;
  final filePath = '${cacheDir.path}/$fileName';
  
  final result = await fileOpener.openFile(filePath);
  result.fold(
    (failure) {
      if (failure is FileNotFoundFailure) {
        print('Image not in cache, downloading...');
        // Trigger download
      } else {
        print('Error: ${failure.message}');
      }
    },
    (_) => print('Image opened'),
  );
}
```

### Open Attachment from Email

```dart
Future<void> openEmailAttachment(Attachment attachment) async {
  // Save attachment to temporary directory
  final tempDir = await getTemporaryDirectory();
  final filePath = '${tempDir.path}/${attachment.fileName}';
  
  final file = File(filePath);
  await file.writeAsBytes(attachment.bytes);
  
  // Open with specific type if known
  final result = await fileOpener.openFileWithType(
    filePath,
    mimeType: attachment.mimeType,
  );
  
  result.fold(
    (failure) => showSnackbar('Cannot open ${attachment.fileName}'),
    (_) => showSnackbar('Opening ${attachment.fileName}'),
  );
}
```


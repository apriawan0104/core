# Path Provider - Quick Start Guide

Get started with the Path Provider service in your Flutter app in just a few minutes.

## 📦 Installation

The path provider dependencies are already included in the core library.

## 🚀 Quick Setup (3 Steps)

### Step 1: Register Service in DI Container

Add to your DI setup file (e.g., `lib/config/di/app_module.dart`):

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupPathProvider() {
  // Register path provider service
  getIt.registerLazySingleton<PathProviderService>(
    () => PathProviderServiceImpl(),
  );
}
```

### Step 2: Call Setup in Main

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup DI
  setupPathProvider();
  
  runApp(MyApp());
}
```

### Step 3: Use the Service

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

class MyWidget extends StatelessWidget {
  final pathProvider = GetIt.instance<PathProviderService>();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _saveFile,
      child: Text('Save File'),
    );
  }

  Future<void> _saveFile() async {
    // Get app documents directory
    final result = await pathProvider.getApplicationDocumentsDirectory();
    
    result.fold(
      (failure) {
        print('Error: ${failure.message}');
      },
      (directory) {
        // Use the directory
        final file = File('${directory.path}/my_file.txt');
        file.writeAsString('Hello World!');
        print('File saved at: ${file.path}');
      },
    );
  }
}
```

## 🎯 Common Use Cases

### 1. Cache Images

```dart
final pathProvider = getIt<PathProviderService>();

Future<void> cacheImage(Uint8List imageData) async {
  final result = await pathProvider.getApplicationCacheDirectory();
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (cacheDir) async {
      final imageFile = File('${cacheDir.path}/cached_image.jpg');
      await imageFile.writeAsBytes(imageData);
      print('Image cached successfully');
    },
  );
}
```

### 2. Save User Documents

```dart
Future<void> saveUserDocument(String content) async {
  final pathProvider = getIt<PathProviderService>();
  final result = await pathProvider.getApplicationDocumentsDirectory();
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (docsDir) async {
      final docFile = File('${docsDir.path}/user_document.txt');
      await docFile.writeAsString(content);
      print('Document saved at: ${docFile.path}');
    },
  );
}
```

### 3. Store Temporary Files

```dart
Future<void> createTempFile(String data) async {
  final pathProvider = getIt<PathProviderService>();
  final result = await pathProvider.getTemporaryDirectory();
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (tempDir) async {
      final tempFile = File('${tempDir.path}/temp_data.json');
      await tempFile.writeAsString(data);
      print('Temp file created');
    },
  );
}
```

### 4. Export to Downloads (with Null Check)

```dart
Future<void> exportToDownloads(String content) async {
  final pathProvider = getIt<PathProviderService>();
  final result = await pathProvider.getDownloadsDirectory();
  
  result.fold(
    (failure) {
      if (failure is DirectoryNotSupportedFailure) {
        print('Downloads directory not supported on this platform');
        // Use alternative directory
        _useAlternativeDirectory(content);
      } else {
        print('Error: ${failure.message}');
      }
    },
    (downloadsDir) async {
      if (downloadsDir != null) {
        final file = File('${downloadsDir.path}/export.txt');
        await file.writeAsString(content);
        print('File exported to: ${file.path}');
      } else {
        print('Downloads directory not available');
        _useAlternativeDirectory(content);
      }
    },
  );
}

Future<void> _useAlternativeDirectory(String content) async {
  // Fallback: use app documents directory
  final pathProvider = getIt<PathProviderService>();
  final result = await pathProvider.getApplicationDocumentsDirectory();
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (docsDir) async {
      final file = File('${docsDir.path}/export.txt');
      await file.writeAsString(content);
      print('File saved to documents: ${file.path}');
    },
  );
}
```

## 📱 Platform-Specific Usage

### Android External Storage

```dart
Future<void> saveToExternalStorage() async {
  final pathProvider = getIt<PathProviderService>();
  final result = await pathProvider.getExternalStorageDirectory();
  
  result.fold(
    (failure) {
      if (failure is DirectoryNotSupportedFailure) {
        print('Only available on Android');
      } else {
        print('Error: ${failure.message}');
      }
    },
    (extDir) async {
      if (extDir != null) {
        final file = File('${extDir.path}/data.txt');
        await file.writeAsString('External data');
      }
    },
  );
}
```

### iOS/macOS Library Directory

```dart
Future<void> saveToLibrary() async {
  final pathProvider = getIt<PathProviderService>();
  final result = await pathProvider.getApplicationLibraryDirectory();
  
  result.fold(
    (failure) {
      if (failure is DirectoryNotSupportedFailure) {
        print('Only available on iOS and macOS');
      } else {
        print('Error: ${failure.message}');
      }
    },
    (libDir) async {
      final file = File('${libDir.path}/internal_data.db');
      await file.writeAsString('Library data');
    },
  );
}
```

## ⚙️ Advanced: Using Storage Type Constants

```dart
import 'package:app_core/app_core.dart';

Future<void> saveToPictures() async {
  final pathProvider = getIt<PathProviderService>();
  
  // Use predefined constants for storage types
  final result = await pathProvider.getExternalStorageDirectories(
    type: PathProviderConstants.storageTypePictures,
  );
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (directories) async {
      if (directories != null && directories.isNotEmpty) {
        final picturesDir = directories.first;
        final image = File('${picturesDir.path}/photo.jpg');
        // Save photo
      }
    },
  );
}
```

## 🎨 UI Integration Example

```dart
class FileManagerScreen extends StatefulWidget {
  @override
  _FileManagerScreenState createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  final pathProvider = GetIt.instance<PathProviderService>();
  String? _currentPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('File Manager')),
      body: Column(
        children: [
          if (_currentPath != null)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text('Current: $_currentPath'),
            ),
          ElevatedButton(
            onPressed: _showTemporaryDir,
            child: Text('Show Temp Directory'),
          ),
          ElevatedButton(
            onPressed: _showDocumentsDir,
            child: Text('Show Documents Directory'),
          ),
          ElevatedButton(
            onPressed: _showCacheDir,
            child: Text('Show Cache Directory'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTemporaryDir() async {
    final result = await pathProvider.getTemporaryDirectory();
    result.fold(
      (failure) => _showError(failure.message),
      (directory) => setState(() => _currentPath = directory.path),
    );
  }

  Future<void> _showDocumentsDir() async {
    final result = await pathProvider.getApplicationDocumentsDirectory();
    result.fold(
      (failure) => _showError(failure.message),
      (directory) => setState(() => _currentPath = directory.path),
    );
  }

  Future<void> _showCacheDir() async {
    final result = await pathProvider.getApplicationCacheDirectory();
    result.fold(
      (failure) => _showError(failure.message),
      (directory) => setState(() => _currentPath = directory.path),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
```

## 🔧 Testing

Mock the service for testing:

```dart
class MockPathProviderService extends Mock implements PathProviderService {}

void main() {
  test('should save file to documents directory', () async {
    // Arrange
    final mockPathProvider = MockPathProviderService();
    final testDir = Directory('/test/documents');
    
    when(() => mockPathProvider.getApplicationDocumentsDirectory())
        .thenAnswer((_) async => Right(testDir));
    
    // Act
    final result = await mockPathProvider.getApplicationDocumentsDirectory();
    
    // Assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Should not fail'),
      (directory) => expect(directory.path, '/test/documents'),
    );
  });
}
```

## 📚 Next Steps

- Read the [Full Documentation](README.md) for more details
- Check the [Example App](../../../../example/path_provider_example.dart)
- Learn about [Platform-Specific Behavior](README.md#platform-specific-behavior)

## 🆘 Common Issues

### Issue: Directory returns null

**Solution**: Some directories may not be available on all platforms. Always check for null:

```dart
final result = await pathProvider.getDownloadsDirectory();
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (directory) {
    if (directory != null) {
      // Use directory
    } else {
      // Handle null case
    }
  },
);
```

### Issue: Permission denied on Android

**Solution**: For external storage, you might need to request permissions:

```dart
// Add to AndroidManifest.xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

---

**That's it!** You're now ready to use the Path Provider service in your app. 🎉


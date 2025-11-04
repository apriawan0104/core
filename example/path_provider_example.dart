// ignore_for_file: avoid_print

import 'dart:io';

import 'package:app_core/app_core.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Example app demonstrating the Path Provider Service
///
/// This example shows how to:
/// 1. Setup the path provider service
/// 2. Access different types of directories
/// 3. Save and read files from different locations
/// 4. Handle platform-specific directories
/// 5. Implement proper error handling
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  _setupDI();

  runApp(const PathProviderExampleApp());
}

/// Setup dependency injection
void _setupDI() {
  final getIt = GetIt.instance;

  // Register path provider service
  getIt.registerLazySingleton<PathProviderService>(
    () => PathProviderServiceImpl(),
  );
}

class PathProviderExampleApp extends StatelessWidget {
  const PathProviderExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Path Provider Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PathProviderHomePage(),
    );
  }
}

class PathProviderHomePage extends StatefulWidget {
  const PathProviderHomePage({super.key});

  @override
  State<PathProviderHomePage> createState() => _PathProviderHomePageState();
}

class _PathProviderHomePageState extends State<PathProviderHomePage> {
  final pathProvider = GetIt.instance<PathProviderService>();

  String _status = 'Ready';
  String _currentPath = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Path Provider Example'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_currentPath.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Current Path:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SelectableText(
                        _currentPath,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Basic Directories Section
            const Text(
              'Basic Directories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildDirectoryButton(
              'Temporary Directory',
              Icons.access_time,
              _showTemporaryDirectory,
              'Short-lived files (can be cleared by system)',
            ),

            _buildDirectoryButton(
              'Documents Directory',
              Icons.folder,
              _showDocumentsDirectory,
              'User-facing documents',
            ),

            _buildDirectoryButton(
              'Support Directory',
              Icons.support,
              _showSupportDirectory,
              'Internal app data',
            ),

            _buildDirectoryButton(
              'Cache Directory',
              Icons.cached,
              _showCacheDirectory,
              'Cached data (can be cleared)',
            ),

            _buildDirectoryButton(
              'Downloads Directory',
              Icons.download,
              _showDownloadsDirectory,
              'User downloads folder',
            ),

            const SizedBox(height: 24),

            // Platform-Specific Section
            const Text(
              'Platform-Specific Directories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (Platform.isIOS || Platform.isMacOS)
              _buildDirectoryButton(
                'Library Directory',
                Icons.library_books,
                _showLibraryDirectory,
                'iOS/macOS library directory',
              ),

            if (Platform.isAndroid) ...[
              _buildDirectoryButton(
                'External Storage',
                Icons.sd_storage,
                _showExternalStorage,
                'Android external storage',
              ),
              _buildDirectoryButton(
                'External Cache',
                Icons.sd_card,
                _showExternalCache,
                'Android external cache',
              ),
              _buildDirectoryButton(
                'Pictures Directory',
                Icons.image,
                _showPicturesDirectory,
                'Android pictures folder',
              ),
            ],

            const SizedBox(height: 24),

            // File Operations Section
            const Text(
              'File Operations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildActionButton(
              'Save Test File',
              Icons.save,
              _saveTestFile,
              Colors.green,
            ),

            _buildActionButton(
              'Read Test File',
              Icons.file_open,
              _readTestFile,
              Colors.blue,
            ),

            _buildActionButton(
              'Cache Data',
              Icons.storage,
              _cacheData,
              Colors.orange,
            ),

            _buildActionButton(
              'Clear Cache',
              Icons.clear_all,
              _clearCache,
              Colors.red,
            ),

            const SizedBox(height: 24),

            // Advanced Operations
            const Text(
              'Advanced Operations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildActionButton(
              'List All Directories',
              Icons.list,
              _listAllDirectories,
              Colors.purple,
            ),

            _buildActionButton(
              'Check Storage Space',
              Icons.storage,
              _checkStorageSpace,
              Colors.teal,
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectoryButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
    String description,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onPressed,
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Icon(Icons.play_arrow, color: color),
        onTap: onPressed,
      ),
    );
  }

  void _setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  void _updateStatus(String status, [String path = '']) {
    if (mounted) {
      setState(() {
        _status = status;
        _currentPath = path;
      });
    }
  }

  // Directory Display Methods

  Future<void> _showTemporaryDirectory() async {
    _setLoading(true);
    final result = await pathProvider.getTemporaryDirectory();

    result.fold(
      (failure) => _updateStatus('Error: ${failure.message}'),
      (directory) => _updateStatus(
        'Temporary directory retrieved',
        directory.path,
      ),
    );
    _setLoading(false);
  }

  Future<void> _showDocumentsDirectory() async {
    _setLoading(true);
    final result = await pathProvider.getApplicationDocumentsDirectory();

    result.fold(
      (failure) => _updateStatus('Error: ${failure.message}'),
      (directory) => _updateStatus(
        'Documents directory retrieved',
        directory.path,
      ),
    );
    _setLoading(false);
  }

  Future<void> _showSupportDirectory() async {
    _setLoading(true);
    final result = await pathProvider.getApplicationSupportDirectory();

    result.fold(
      (failure) => _updateStatus('Error: ${failure.message}'),
      (directory) => _updateStatus(
        'Support directory retrieved',
        directory.path,
      ),
    );
    _setLoading(false);
  }

  Future<void> _showCacheDirectory() async {
    _setLoading(true);
    final result = await pathProvider.getApplicationCacheDirectory();

    result.fold(
      (failure) => _updateStatus('Error: ${failure.message}'),
      (directory) => _updateStatus(
        'Cache directory retrieved',
        directory.path,
      ),
    );
    _setLoading(false);
  }

  Future<void> _showDownloadsDirectory() async {
    _setLoading(true);
    final result = await pathProvider.getDownloadsDirectory();

    result.fold(
      (failure) => _updateStatus('Error: ${failure.message}'),
      (directory) {
        if (directory != null) {
          _updateStatus('Downloads directory retrieved', directory.path);
        } else {
          _updateStatus('Downloads directory not available on this platform');
        }
      },
    );
    _setLoading(false);
  }

  Future<void> _showLibraryDirectory() async {
    _setLoading(true);
    final result = await pathProvider.getApplicationLibraryDirectory();

    result.fold(
      (failure) {
        if (failure is DirectoryNotSupportedFailure) {
          _updateStatus('Library directory only available on iOS/macOS');
        } else {
          _updateStatus('Error: ${failure.message}');
        }
      },
      (directory) => _updateStatus(
        'Library directory retrieved',
        directory.path,
      ),
    );
    _setLoading(false);
  }

  Future<void> _showExternalStorage() async {
    _setLoading(true);
    final result = await pathProvider.getExternalStorageDirectory();

    result.fold(
      (failure) {
        if (failure is DirectoryNotSupportedFailure) {
          _updateStatus('External storage only available on Android');
        } else {
          _updateStatus('Error: ${failure.message}');
        }
      },
      (directory) {
        if (directory != null) {
          _updateStatus('External storage retrieved', directory.path);
        } else {
          _updateStatus('External storage not available');
        }
      },
    );
    _setLoading(false);
  }

  Future<void> _showExternalCache() async {
    _setLoading(true);
    final result = await pathProvider.getExternalCacheDirectories();

    result.fold(
      (failure) {
        if (failure is DirectoryNotSupportedFailure) {
          _updateStatus('External cache only available on Android');
        } else {
          _updateStatus('Error: ${failure.message}');
        }
      },
      (directories) {
        if (directories != null && directories.isNotEmpty) {
          _updateStatus(
            'External cache directories: ${directories.length}',
            directories.first.path,
          );
        } else {
          _updateStatus('External cache not available');
        }
      },
    );
    _setLoading(false);
  }

  Future<void> _showPicturesDirectory() async {
    _setLoading(true);
    final result = await pathProvider.getExternalStorageDirectories(
      type: PathProviderConstants.storageTypePictures,
    );

    result.fold(
      (failure) {
        if (failure is DirectoryNotSupportedFailure) {
          _updateStatus('Pictures directory only available on Android');
        } else {
          _updateStatus('Error: ${failure.message}');
        }
      },
      (directories) {
        if (directories != null && directories.isNotEmpty) {
          _updateStatus(
            'Pictures directory retrieved',
            directories.first.path,
          );
        } else {
          _updateStatus('Pictures directory not available');
        }
      },
    );
    _setLoading(false);
  }

  // File Operations

  Future<void> _saveTestFile() async {
    _setLoading(true);
    final result = await pathProvider.getApplicationDocumentsDirectory();

    result.fold(
      (failure) => _updateStatus('Error: ${failure.message}'),
      (directory) async {
        try {
          final file = File('${directory.path}/test_file.txt');
          final timestamp = DateTime.now().toIso8601String();
          await file.writeAsString('Test file created at $timestamp');

          _updateStatus(
            'File saved successfully',
            file.path,
          );
        } catch (e) {
          _updateStatus('Error saving file: $e');
        }
      },
    );
    _setLoading(false);
  }

  Future<void> _readTestFile() async {
    _setLoading(true);
    final result = await pathProvider.getApplicationDocumentsDirectory();

    result.fold(
      (failure) => _updateStatus('Error: ${failure.message}'),
      (directory) async {
        try {
          final file = File('${directory.path}/test_file.txt');

          if (await file.exists()) {
            final content = await file.readAsString();
            _updateStatus(
              'File read successfully:\n$content',
              file.path,
            );
          } else {
            _updateStatus('File does not exist. Create it first!');
          }
        } catch (e) {
          _updateStatus('Error reading file: $e');
        }
      },
    );
    _setLoading(false);
  }

  Future<void> _cacheData() async {
    _setLoading(true);
    final result = await pathProvider.getApplicationCacheDirectory();

    result.fold(
      (failure) => _updateStatus('Error: ${failure.message}'),
      (directory) async {
        try {
          final file = File('${directory.path}/cached_data.json');
          final data = '''
{
  "timestamp": "${DateTime.now().toIso8601String()}",
  "data": "This is cached data",
  "version": "1.0.0"
}
''';
          await file.writeAsString(data);

          _updateStatus(
            'Data cached successfully',
            file.path,
          );
        } catch (e) {
          _updateStatus('Error caching data: $e');
        }
      },
    );
    _setLoading(false);
  }

  Future<void> _clearCache() async {
    _setLoading(true);
    final result = await pathProvider.getApplicationCacheDirectory();

    result.fold(
      (failure) => _updateStatus('Error: ${failure.message}'),
      (directory) async {
        try {
          final files = directory.listSync();
          int deletedCount = 0;

          for (var file in files) {
            if (file is File) {
              await file.delete();
              deletedCount++;
            }
          }

          _updateStatus(
            'Cache cleared: $deletedCount file(s) deleted',
            directory.path,
          );
        } catch (e) {
          _updateStatus('Error clearing cache: $e');
        }
      },
    );
    _setLoading(false);
  }

  Future<void> _listAllDirectories() async {
    _setLoading(true);

    final directories = <String, String>{};

    // Get all standard directories
    final tempResult = await pathProvider.getTemporaryDirectory();
    tempResult.fold(
      (_) {},
      (dir) => directories['Temporary'] = dir.path,
    );

    final docsResult = await pathProvider.getApplicationDocumentsDirectory();
    docsResult.fold(
      (_) {},
      (dir) => directories['Documents'] = dir.path,
    );

    final supportResult = await pathProvider.getApplicationSupportDirectory();
    supportResult.fold(
      (_) {},
      (dir) => directories['Support'] = dir.path,
    );

    final cacheResult = await pathProvider.getApplicationCacheDirectory();
    cacheResult.fold(
      (_) {},
      (dir) => directories['Cache'] = dir.path,
    );

    final downloadsResult = await pathProvider.getDownloadsDirectory();
    downloadsResult.fold(
      (_) {},
      (dir) {
        if (dir != null) directories['Downloads'] = dir.path;
      },
    );

    // Platform-specific
    if (Platform.isIOS || Platform.isMacOS) {
      final libResult = await pathProvider.getApplicationLibraryDirectory();
      libResult.fold(
        (_) {},
        (dir) => directories['Library'] = dir.path,
      );
    }

    if (Platform.isAndroid) {
      final extResult = await pathProvider.getExternalStorageDirectory();
      extResult.fold(
        (_) {},
        (dir) {
          if (dir != null) directories['External Storage'] = dir.path;
        },
      );
    }

    final summary = directories.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n\n');

    _updateStatus(
      'Found ${directories.length} directories:\n\n$summary',
    );

    _setLoading(false);
  }

  Future<void> _checkStorageSpace() async {
    _setLoading(true);
    final result = await pathProvider.getApplicationDocumentsDirectory();

    result.fold(
      (failure) => _updateStatus('Error: ${failure.message}'),
      (directory) async {
        try {
          final stat = await directory.stat();
          final size = await _getDirectorySize(directory);
          final sizeInMB = (size / (1024 * 1024)).toStringAsFixed(2);

          _updateStatus(
            'Directory Info:\n'
            'Path: ${directory.path}\n'
            'Size: $sizeInMB MB\n'
            'Modified: ${stat.modified}\n'
            'Type: ${stat.type}',
            directory.path,
          );
        } catch (e) {
          _updateStatus('Error checking storage: $e');
        }
      },
    );
    _setLoading(false);
  }

  Future<int> _getDirectorySize(Directory directory) async {
    int totalSize = 0;

    try {
      if (await directory.exists()) {
        final files = directory.listSync(recursive: true);
        for (var file in files) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
    } catch (e) {
      print('Error calculating directory size: $e');
    }

    return totalSize;
  }
}

/// Example of a service class using PathProviderService
class FileManagerService {
  final PathProviderService _pathProvider;

  FileManagerService(this._pathProvider);

  /// Save data to documents directory
  Future<Either<String, String>> saveDocument(
    String filename,
    String content,
  ) async {
    final result = await _pathProvider.getApplicationDocumentsDirectory();

    return result.fold(
      (failure) => Left(failure.message),
      (directory) async {
        try {
          final file = File('${directory.path}/$filename');
          await file.writeAsString(content);
          return Right(file.path);
        } catch (e) {
          return Left('Failed to save document: $e');
        }
      },
    );
  }

  /// Cache data with expiration
  Future<Either<String, void>> cacheWithExpiration(
    String key,
    String data,
    Duration expiration,
  ) async {
    final result = await _pathProvider.getApplicationCacheDirectory();

    return result.fold(
      (failure) => Left(failure.message),
      (directory) async {
        try {
          final file = File('${directory.path}/$key.cache');
          final expiryTime =
              DateTime.now().add(expiration).millisecondsSinceEpoch;

          final cacheData = '''
{
  "data": "$data",
  "expiry": $expiryTime
}
''';

          await file.writeAsString(cacheData);
          return const Right(null);
        } catch (e) {
          return Left('Failed to cache data: $e');
        }
      },
    );
  }

  /// Get cached data if not expired
  Future<Either<String, String?>> getCachedData(String key) async {
    final result = await _pathProvider.getApplicationCacheDirectory();

    return result.fold(
      (failure) => Left(failure.message),
      (directory) async {
        try {
          final file = File('${directory.path}/$key.cache');

          if (!await file.exists()) {
            return const Right(null);
          }

          final content = await file.readAsString();
          // In real app, parse JSON and check expiry
          // For simplicity, just return the content
          return Right(content);
        } catch (e) {
          return Left('Failed to read cached data: $e');
        }
      },
    );
  }

  /// Clean up old files
  Future<Either<String, int>> cleanupOldFiles(Duration age) async {
    final result = await _pathProvider.getTemporaryDirectory();

    return result.fold(
      (failure) => Left(failure.message),
      (directory) async {
        try {
          int deletedCount = 0;
          final now = DateTime.now();
          final files = directory.listSync();

          for (var file in files) {
            if (file is File) {
              final stat = await file.stat();
              final fileAge = now.difference(stat.modified);

              if (fileAge > age) {
                await file.delete();
                deletedCount++;
              }
            }
          }

          return Right(deletedCount);
        } catch (e) {
          return Left('Failed to cleanup files: $e');
        }
      },
    );
  }
}


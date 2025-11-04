// ignore_for_file: avoid_print

import 'dart:io';

import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Example app demonstrating the File Opener Service
///
/// This example shows how to:
/// 1. Setup the file opener service
/// 2. Open various file types with native applications
/// 3. Open files with specific MIME types/UTI
/// 4. Check file existence before opening
/// 5. Handle different file opening scenarios
/// 6. Implement proper error handling
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  _setupDI();

  runApp(const FileOpenerExampleApp());
}

/// Setup dependency injection
void _setupDI() {
  final getIt = GetIt.instance;

  // Register file opener service
  getIt.registerLazySingleton<FileOpenerService>(
    () => const OpenFileServiceImpl(),
  );

  // Register path provider for creating test files
  getIt.registerLazySingleton<PathProviderService>(
    () => PathProviderServiceImpl(),
  );
}

class FileOpenerExampleApp extends StatelessWidget {
  const FileOpenerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Opener Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const FileOpenerHomePage(),
    );
  }
}

class FileOpenerHomePage extends StatefulWidget {
  const FileOpenerHomePage({super.key});

  @override
  State<FileOpenerHomePage> createState() => _FileOpenerHomePageState();
}

class _FileOpenerHomePageState extends State<FileOpenerHomePage> {
  final fileOpener = GetIt.instance<FileOpenerService>();
  final pathProvider = GetIt.instance<PathProviderService>();

  String _status = 'Ready';
  String _currentFilePath = '';
  bool _isLoading = false;
  final List<String> _createdFiles = [];

  @override
  void initState() {
    super.initState();
    _createSampleFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Opener Example'),
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
                    if (_currentFilePath.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Current File:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _currentFilePath,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              // Basic File Operations
              _buildSectionHeader('Basic File Operations'),
              _buildActionButton(
                'Open Text File',
                'Open a sample text file with default app',
                Icons.text_snippet,
                Colors.blue,
                _openTextFile,
              ),
              _buildActionButton(
                'Open HTML File',
                'Open an HTML file in browser',
                Icons.web,
                Colors.orange,
                _openHtmlFile,
              ),
              _buildActionButton(
                'Open Image File',
                'Open an image with default viewer',
                Icons.image,
                Colors.green,
                _openImageFile,
              ),

              const SizedBox(height: 16),

              // Advanced Operations
              _buildSectionHeader('Advanced Operations'),
              _buildActionButton(
                'Open with Custom MIME Type',
                'Open file with specific MIME type',
                Icons.settings,
                Colors.purple,
                _openWithCustomMimeType,
              ),
              _buildActionButton(
                'Check File Existence',
                'Check if a file exists before opening',
                Icons.search,
                Colors.teal,
                _checkFileExistence,
              ),
              _buildActionButton(
                'Get MIME Type',
                'Get MIME type for various extensions',
                Icons.info,
                Colors.indigo,
                _getMimeTypes,
              ),

              const SizedBox(height: 16),

              // Error Handling
              _buildSectionHeader('Error Handling'),
              _buildActionButton(
                'Open Non-Existent File',
                'Try to open a file that doesn\'t exist',
                Icons.error,
                Colors.red,
                _openNonExistentFile,
              ),
              _buildActionButton(
                'Open Unsupported File Type',
                'Try to open a file with no default app',
                Icons.warning,
                Colors.amber,
                _openUnsupportedFileType,
              ),

              const SizedBox(height: 16),

              // Created Files List
              if (_createdFiles.isNotEmpty) ...[
                _buildSectionHeader('Created Sample Files'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final file in _createdFiles)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.file_present, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    file,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Utility Actions
              _buildSectionHeader('Utilities'),
              _buildActionButton(
                'Recreate Sample Files',
                'Create new sample files for testing',
                Icons.refresh,
                Colors.blueGrey,
                _createSampleFiles,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onPressed,
      ),
    );
  }

  void _setStatus(String status, [String? filePath]) {
    setState(() {
      _status = status;
      _currentFilePath = filePath ?? '';
      _isLoading = false;
    });
  }

  void _setLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  /// Create sample files for testing
  Future<void> _createSampleFiles() async {
    _setLoading();

    try {
      final result = await pathProvider.getApplicationDocumentsDirectory();

      await result.fold(
        (failure) async {
          _setStatus('Error getting documents directory: ${failure.message}');
        },
        (directory) async {
          _createdFiles.clear();

          // Create text file
          final textFile = File('${directory.path}/sample.txt');
          await textFile.writeAsString(
            'This is a sample text file created by File Opener Example.\n\n'
            'You can open this file with any text editor installed on your device.\n\n'
            'Timestamp: ${DateTime.now()}',
          );
          _createdFiles.add(textFile.path);

          // Create HTML file
          final htmlFile = File('${directory.path}/sample.html');
          await htmlFile.writeAsString(
            '<!DOCTYPE html>\n'
            '<html>\n'
            '<head><title>Sample HTML</title></head>\n'
            '<body>\n'
            '<h1>File Opener Example</h1>\n'
            '<p>This is a sample HTML file.</p>\n'
            '<p>Created at: ${DateTime.now()}</p>\n'
            '</body>\n'
            '</html>',
          );
          _createdFiles.add(htmlFile.path);

          // Create a JSON file (might not have default app on some platforms)
          final jsonFile = File('${directory.path}/sample.json');
          await jsonFile.writeAsString(
            '{\n'
            '  "app": "File Opener Example",\n'
            '  "version": "1.0.0",\n'
            '  "timestamp": "${DateTime.now()}",\n'
            '  "features": ["open files", "check existence", "MIME types"]\n'
            '}',
          );
          _createdFiles.add(jsonFile.path);

          _setStatus(
            'Created ${_createdFiles.length} sample files in:\n${directory.path}',
          );

          print('Sample files created successfully:');
          for (final file in _createdFiles) {
            print('  - $file');
          }
        },
      );
    } catch (e) {
      _setStatus('Error creating sample files: $e');
      print('Error: $e');
    }
  }

  /// Open a text file
  Future<void> _openTextFile() async {
    _setLoading();

    if (_createdFiles.isEmpty) {
      _setStatus('No files created yet. Creating sample files...');
      await _createSampleFiles();
      return;
    }

    final textFile = _createdFiles.firstWhere(
      (file) => file.endsWith('.txt'),
      orElse: () => '',
    );

    if (textFile.isEmpty) {
      _setStatus('Text file not found');
      return;
    }

    print('Opening text file: $textFile');

    final result = await fileOpener.openFile(textFile);

    result.fold(
      (failure) {
        _setStatus('Failed to open text file: ${failure.message}', textFile);
        print('Error: ${failure.message}');
      },
      (openResult) {
        if (openResult.isSuccess) {
          _setStatus('Text file opened successfully!', textFile);
          print('Success: ${openResult.message}');
        } else if (openResult.isNoAppFound) {
          _setStatus('No app found to open text files', textFile);
          print('No app found: ${openResult.message}');
        } else {
          _setStatus('Failed: ${openResult.message}', textFile);
          print('Failed: ${openResult.message}');
        }
      },
    );
  }

  /// Open an HTML file
  Future<void> _openHtmlFile() async {
    _setLoading();

    if (_createdFiles.isEmpty) {
      _setStatus('No files created yet. Creating sample files...');
      await _createSampleFiles();
      return;
    }

    final htmlFile = _createdFiles.firstWhere(
      (file) => file.endsWith('.html'),
      orElse: () => '',
    );

    if (htmlFile.isEmpty) {
      _setStatus('HTML file not found');
      return;
    }

    print('Opening HTML file: $htmlFile');

    final result = await fileOpener.openFile(htmlFile);

    result.fold(
      (failure) {
        _setStatus('Failed to open HTML file: ${failure.message}', htmlFile);
        print('Error: ${failure.message}');
      },
      (openResult) {
        if (openResult.isSuccess) {
          _setStatus('HTML file opened in browser!', htmlFile);
          print('Success: ${openResult.message}');
        } else {
          _setStatus('Failed: ${openResult.message}', htmlFile);
          print('Failed: ${openResult.message}');
        }
      },
    );
  }

  /// Open an image file (create one first if needed)
  Future<void> _openImageFile() async {
    _setLoading();
    _setStatus(
      'This example would open an image file.\n\n'
      'To test with a real image, place an image in your documents directory '
      'and update the code with the correct path.',
    );
  }

  /// Open file with custom MIME type
  Future<void> _openWithCustomMimeType() async {
    _setLoading();

    if (_createdFiles.isEmpty) {
      _setStatus('No files created yet. Creating sample files...');
      await _createSampleFiles();
      return;
    }

    final jsonFile = _createdFiles.firstWhere(
      (file) => file.endsWith('.json'),
      orElse: () => '',
    );

    if (jsonFile.isEmpty) {
      _setStatus('JSON file not found');
      return;
    }

    print('Opening JSON file with custom MIME type: $jsonFile');

    // Try to open as text/plain to force text editor
    final result = await fileOpener.openFileWithType(
      jsonFile,
      mimeType: 'text/plain',
    );

    result.fold(
      (failure) {
        _setStatus(
          'Failed to open with custom MIME type: ${failure.message}',
          jsonFile,
        );
        print('Error: ${failure.message}');
      },
      (openResult) {
        if (openResult.isSuccess) {
          _setStatus(
            'JSON file opened with text/plain MIME type!',
            jsonFile,
          );
          print('Success: ${openResult.message}');
        } else if (openResult.isNoAppFound) {
          _setStatus('No text editor found', jsonFile);
          print('No app found: ${openResult.message}');
        } else {
          _setStatus('Failed: ${openResult.message}', jsonFile);
          print('Failed: ${openResult.message}');
        }
      },
    );
  }

  /// Check if file exists before opening
  Future<void> _checkFileExistence() async {
    _setLoading();

    if (_createdFiles.isEmpty) {
      _setStatus('No files created yet. Creating sample files...');
      await _createSampleFiles();
      return;
    }

    final textFile = _createdFiles.firstWhere(
      (file) => file.endsWith('.txt'),
      orElse: () => '',
    );

    if (textFile.isEmpty) {
      _setStatus('Text file not found in created files list');
      return;
    }

    print('Checking if file exists: $textFile');

    final existsResult = await fileOpener.fileExists(textFile);

    await existsResult.fold(
      (failure) async {
        _setStatus(
          'Error checking file existence: ${failure.message}',
          textFile,
        );
        print('Error: ${failure.message}');
      },
      (exists) async {
        if (exists) {
          _setStatus('File exists! Opening...', textFile);
          print('File exists, opening...');

          // Now open the file
          final openResult = await fileOpener.openFile(textFile);
          openResult.fold(
            (failure) {
              _setStatus('Failed to open: ${failure.message}', textFile);
              print('Error: ${failure.message}');
            },
            (result) {
              if (result.isSuccess) {
                _setStatus('File opened successfully!', textFile);
                print('Success: ${result.message}');
              } else {
                _setStatus('Failed: ${result.message}', textFile);
                print('Failed: ${result.message}');
              }
            },
          );
        } else {
          _setStatus('File does not exist', textFile);
          print('File does not exist');
        }
      },
    );
  }

  /// Get MIME types for various extensions
  void _getMimeTypes() {
    final extensions = [
      '.pdf',
      '.doc',
      '.docx',
      '.txt',
      '.jpg',
      '.png',
      '.mp4',
      '.mp3',
      '.zip',
      '.apk',
      '.unknown',
    ];

    final buffer = StringBuffer('MIME Types:\n\n');

    for (final ext in extensions) {
      final mimeType = fileOpener.getMimeType(ext);
      buffer.write('$ext: ${mimeType ?? "Unknown"}\n');
      print('$ext -> $mimeType');
    }

    // Also get UTI types on iOS/macOS
    if (Platform.isIOS || Platform.isMacOS) {
      buffer.write('\n\nUTI Types (iOS/macOS):\n\n');
      for (final ext in extensions) {
        final uti = fileOpener.getUTI(ext);
        buffer.write('$ext: ${uti ?? "Unknown"}\n');
        print('$ext (UTI) -> $uti');
      }
    }

    _setStatus(buffer.toString());
  }

  /// Try to open a non-existent file
  Future<void> _openNonExistentFile() async {
    _setLoading();

    const nonExistentFile = '/path/to/nonexistent/file.txt';
    print('Attempting to open non-existent file: $nonExistentFile');

    final result = await fileOpener.openFile(nonExistentFile);

    result.fold(
      (failure) {
        if (failure is FileNotFoundFailure) {
          _setStatus(
            'Expected error: File not found!\n\n${failure.message}',
            nonExistentFile,
          );
          print('Expected failure (FileNotFoundFailure): ${failure.message}');
        } else {
          _setStatus(
            'Unexpected error: ${failure.message}',
            nonExistentFile,
          );
          print('Unexpected failure: ${failure.message}');
        }
      },
      (openResult) {
        _setStatus(
          'Unexpected success (file should not exist)',
          nonExistentFile,
        );
        print('Unexpected success: ${openResult.message}');
      },
    );
  }

  /// Try to open a file with unsupported type
  Future<void> _openUnsupportedFileType() async {
    _setLoading();

    // Create a file with unusual extension
    final result = await pathProvider.getApplicationDocumentsDirectory();

    await result.fold(
      (failure) async {
        _setStatus('Error getting directory: ${failure.message}');
      },
      (directory) async {
        final unusualFile = File('${directory.path}/sample.xyz123');
        await unusualFile.writeAsString('This file has an unusual extension');

        print('Opening file with unsupported type: ${unusualFile.path}');

        final openResult = await fileOpener.openFile(unusualFile.path);

        openResult.fold(
          (failure) {
            if (failure is NoAppFoundFailure) {
              _setStatus(
                'Expected: No app found for this file type!\n\n${failure.message}',
                unusualFile.path,
              );
              print('Expected failure (NoAppFoundFailure): ${failure.message}');
            } else {
              _setStatus(
                'Error: ${failure.message}',
                unusualFile.path,
              );
              print('Error: ${failure.message}');
            }
          },
          (result) {
            if (result.isNoAppFound) {
              _setStatus(
                'Expected: No app found for this file type!\n\n${result.message}',
                unusualFile.path,
              );
              print('Expected: No app found (${result.message})');
            } else if (result.isSuccess) {
              _setStatus(
                'Unexpected: File opened (an app was found)',
                unusualFile.path,
              );
              print('Unexpected success: ${result.message}');
            } else {
              _setStatus(
                'Result: ${result.message}',
                unusualFile.path,
              );
              print('Result: ${result.message}');
            }
          },
        );

        // Clean up
        if (await unusualFile.exists()) {
          await unusualFile.delete();
          print('Cleaned up test file: ${unusualFile.path}');
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

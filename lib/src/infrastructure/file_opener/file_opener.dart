/// File opener infrastructure
/// 
/// Provides cross-platform file opening capabilities.
/// 
/// This module wraps file opening functionality in a dependency-independent
/// interface, making it easy to switch between different file opening
/// implementations without affecting consumer code.
/// 
/// ## Features
/// 
/// - Open files with native applications
/// - Support for custom MIME types and UTI
/// - Cross-platform support (Android, iOS, macOS, Linux, Windows, Web)
/// - Check file existence before opening
/// - Get MIME type and UTI from file extensions
/// 
/// ## Platform Support
/// 
/// - **Android**: Uses Intent to open files
/// - **iOS**: Uses UIDocumentInteractionController with UTI
/// - **macOS**: Uses NSWorkspace
/// - **Linux**: Uses xdg-open
/// - **Windows**: Uses ShellExecute
/// - **Web**: Uses dart:html
/// 
/// ## Usage
/// 
/// ```dart
/// // Register in DI
/// getIt.registerLazySingleton<FileOpenerService>(
///   () => OpenFileServiceImpl(),
/// );
/// 
/// // Use in app
/// final fileOpener = getIt<FileOpenerService>();
/// 
/// // Open a file
/// final result = await fileOpener.openFile('/path/to/document.pdf');
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (result) {
///     if (result.isSuccess) {
///       print('File opened successfully');
///     }
///   },
/// );
/// 
/// // Open with specific type
/// final result2 = await fileOpener.openFileWithType(
///   '/path/to/file.dwg',
///   mimeType: 'application/x-autocad',
/// );
/// ```
/// 
/// ## Setup
/// 
/// See `doc/FILE_OPENER_SETUP.md` for detailed setup instructions.
library file_opener;

export 'constants/constants.dart';
export 'contract/contracts.dart';
export 'impl/impl.dart';
export 'models/models.dart';


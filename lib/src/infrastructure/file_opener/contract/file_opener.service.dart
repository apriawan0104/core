import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../errors/file_opener_failure.dart';
import '../models/models.dart';

/// Abstract service for opening files with native applications
/// 
/// This interface provides file opening capabilities without exposing
/// third-party dependencies. Any implementation (open_file, custom handlers, etc.)
/// can be swapped without changing consumer code.
/// 
/// ### Platform Support
/// 
/// - **Android**: Uses Intent to open files
/// - **iOS**: Uses UIDocumentInteractionController with UTI
/// - **macOS**: Uses NSWorkspace
/// - **Linux**: Uses xdg-open
/// - **Windows**: Uses ShellExecute
/// - **Web**: Uses dart:html to download/open files
/// 
/// ### Example Implementations
/// 
/// - `OpenFileServiceImpl` (using open_file package)
/// - Custom implementation for specific file types
/// - Mock implementation for testing
/// 
/// ### Usage Example
/// 
/// ```dart
/// final fileOpener = getIt<FileOpenerService>();
/// 
/// // Open a PDF file
/// final result = await fileOpener.openFile('/path/to/document.pdf');
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (result) {
///     if (result.isSuccess) {
///       print('File opened successfully');
///     } else {
///       print('Failed: ${result.message}');
///     }
///   },
/// );
/// 
/// // Open with specific MIME type
/// final result2 = await fileOpener.openFileWithType(
///   '/path/to/file.xyz',
///   mimeType: 'application/custom',
/// );
/// ```
abstract class FileOpenerService {
  /// Open a file with the default system application
  /// 
  /// The system will determine the appropriate application based on the
  /// file extension. If no application is found, an error will be returned.
  /// 
  /// [filePath] - Absolute path to the file to open
  /// 
  /// Returns [Right(FileOpenResult)] with success status and message
  /// Returns [Left(FileOpenerFailure)] if an error occurs
  /// 
  /// ### Example
  /// 
  /// ```dart
  /// final result = await fileOpener.openFile('/sdcard/document.pdf');
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (result) {
  ///     if (result.isSuccess) {
  ///       print('File opened successfully');
  ///     } else if (result.isNoAppFound) {
  ///       print('No app available to open this file type');
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<FileOpenerFailure, FileOpenResult>> openFile(String filePath);

  /// Open a file with a specific MIME type (Android) or UTI (iOS)
  /// 
  /// This allows you to specify the exact type of file when the extension
  /// is ambiguous or for custom file types.
  /// 
  /// [filePath] - Absolute path to the file to open
  /// [mimeType] - MIME type for Android (e.g., 'application/pdf')
  /// [uti] - UTI (Uniform Type Identifier) for iOS (e.g., 'com.adobe.pdf')
  /// 
  /// If [uti] is not provided on iOS, the service will attempt to determine
  /// it from the file extension.
  /// 
  /// Returns [Right(FileOpenResult)] with success status and message
  /// Returns [Left(FileOpenerFailure)] if an error occurs
  /// 
  /// ### Example
  /// 
  /// ```dart
  /// // Open a custom file type
  /// final result = await fileOpener.openFileWithType(
  ///   '/path/to/drawing.dwg',
  ///   mimeType: 'application/x-autocad',
  ///   uti: 'com.autodesk.dwg',
  /// );
  /// 
  /// // Open PDF with explicit type
  /// final result2 = await fileOpener.openFileWithType(
  ///   '/path/to/document.pdf',
  ///   mimeType: 'application/pdf',
  ///   uti: 'com.adobe.pdf',
  /// );
  /// ```
  Future<Either<FileOpenerFailure, FileOpenResult>> openFileWithType(
    String filePath, {
    String? mimeType,
    String? uti,
  });

  /// Check if a file exists at the given path
  /// 
  /// This is a utility method to verify file existence before attempting
  /// to open it. Useful for providing better error messages to users.
  /// 
  /// [filePath] - Path to check
  /// 
  /// Returns [Right(true)] if file exists
  /// Returns [Right(false)] if file does not exist
  /// Returns [Left(FileOpenerFailure)] if check fails
  /// 
  /// ### Example
  /// 
  /// ```dart
  /// final exists = await fileOpener.fileExists('/path/to/file.pdf');
  /// exists.fold(
  ///   (failure) => print('Error checking file: ${failure.message}'),
  ///   (exists) {
  ///     if (exists) {
  ///       // Proceed to open file
  ///       await fileOpener.openFile('/path/to/file.pdf');
  ///     } else {
  ///       print('File does not exist');
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<FileOpenerFailure, bool>> fileExists(String filePath);

  /// Get the MIME type for a file based on its extension
  /// 
  /// This is a utility method that returns the appropriate MIME type
  /// for common file extensions. Useful when you need to know the type
  /// before opening or for other file operations.
  /// 
  /// [filePath] - File path or extension (e.g., '/path/file.pdf' or '.pdf')
  /// 
  /// Returns the MIME type string, or null if unknown
  /// 
  /// ### Example
  /// 
  /// ```dart
  /// final mimeType = fileOpener.getMimeType('/path/document.pdf');
  /// print(mimeType); // 'application/pdf'
  /// 
  /// final mimeType2 = fileOpener.getMimeType('.jpg');
  /// print(mimeType2); // 'image/jpeg'
  /// 
  /// final mimeType3 = fileOpener.getMimeType('.unknown');
  /// print(mimeType3); // null
  /// ```
  String? getMimeType(String filePath);

  /// Get the UTI (Uniform Type Identifier) for iOS based on file extension
  /// 
  /// This is specifically for iOS platform to properly identify file types.
  /// Returns null on non-iOS platforms or for unknown extensions.
  /// 
  /// [filePath] - File path or extension (e.g., '/path/file.pdf' or '.pdf')
  /// 
  /// Returns the UTI string for iOS, or null if unknown
  /// 
  /// ### Example
  /// 
  /// ```dart
  /// final uti = fileOpener.getUTI('/path/document.pdf');
  /// print(uti); // 'com.adobe.pdf' (on iOS)
  /// 
  /// final uti2 = fileOpener.getUTI('.docx');
  /// print(uti2); // 'org.openxmlformats.wordprocessingml.document'
  /// ```
  String? getUTI(String filePath);

  /// Open a file with additional options
  /// 
  /// This method provides more control over how the file is opened,
  /// with platform-specific options.
  /// 
  /// [file] - File object to open
  /// [mimeType] - Optional MIME type override
  /// [uti] - Optional UTI override for iOS
  /// 
  /// Returns [Right(FileOpenResult)] with success status
  /// Returns [Left(FileOpenerFailure)] if an error occurs
  /// 
  /// ### Example
  /// 
  /// ```dart
  /// final file = File('/path/to/document.pdf');
  /// final result = await fileOpener.openFileObject(
  ///   file,
  ///   mimeType: 'application/pdf',
  /// );
  /// ```
  Future<Either<FileOpenerFailure, FileOpenResult>> openFileObject(
    File file, {
    String? mimeType,
    String? uti,
  });
}


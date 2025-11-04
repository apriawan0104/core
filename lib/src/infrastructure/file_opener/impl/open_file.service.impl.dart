import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:open_file/open_file.dart' as open_file_package;
import 'package:path/path.dart' as path;

import '../../../errors/file_opener_failure.dart';
import '../constants/constants.dart';
import '../contract/contracts.dart';
import '../models/models.dart';

/// Implementation of [FileOpenerService] using the open_file package
///
/// This implementation wraps the `open_file` package to provide a
/// dependency-independent interface for opening files.
///
/// ### Platform Support
///
/// - Android: Uses Intent with proper MIME types
/// - iOS: Uses UIDocumentInteractionController with UTI
/// - macOS: Uses NSWorkspace
/// - Linux: Uses xdg-open
/// - Windows: Uses ShellExecute
/// - Web: Uses dart:html
///
/// ### Setup Required
///
/// See FILE_OPENER_SETUP.md for platform-specific setup instructions.
///
/// ### Example Usage
///
/// ```dart
/// // Register in DI
/// getIt.registerLazySingleton<FileOpenerService>(
///   () => OpenFileServiceImpl(),
/// );
///
/// // Use in app
/// final fileOpener = getIt<FileOpenerService>();
/// final result = await fileOpener.openFile('/path/to/file.pdf');
/// ```
class OpenFileServiceImpl implements FileOpenerService {
  /// Create an instance of OpenFileServiceImpl
  const OpenFileServiceImpl();

  @override
  Future<Either<FileOpenerFailure, FileOpenResult>> openFile(
    String filePath,
  ) async {
    try {
      // Check if file exists first
      final file = File(filePath);
      if (!await file.exists()) {
        return Left(FileNotFoundFailure(filePath));
      }

      // Open file using open_file package
      final result = await open_file_package.OpenFile.open(filePath);

      return _handleOpenFileResult(result, filePath);
    } catch (e) {
      return Left(UnknownFileOpenerFailure(e.toString()));
    }
  }

  @override
  Future<Either<FileOpenerFailure, FileOpenResult>> openFileWithType(
    String filePath, {
    String? mimeType,
    String? uti,
  }) async {
    try {
      // Check if file exists first
      final file = File(filePath);
      if (!await file.exists()) {
        return Left(FileNotFoundFailure(filePath));
      }

      // Determine the type to use
      // On iOS/macOS, prefer UTI if provided, otherwise use MIME type
      // On other platforms, use MIME type
      String? type;
      if (Platform.isIOS || Platform.isMacOS) {
        type = uti ?? mimeType ?? getUTI(filePath) ?? getMimeType(filePath);
      } else {
        type = mimeType ?? getMimeType(filePath);
      }

      // Open file with specified type
      final result = await open_file_package.OpenFile.open(
        filePath,
        type: type,
      );

      return _handleOpenFileResult(result, filePath);
    } catch (e) {
      return Left(UnknownFileOpenerFailure(e.toString()));
    }
  }

  @override
  Future<Either<FileOpenerFailure, FileOpenResult>> openFileObject(
    File file, {
    String? mimeType,
    String? uti,
  }) async {
    return openFileWithType(
      file.path,
      mimeType: mimeType,
      uti: uti,
    );
  }

  @override
  Future<Either<FileOpenerFailure, bool>> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      final exists = await file.exists();
      return Right(exists);
    } catch (e) {
      return Left(UnknownFileOpenerFailure(
        'Error checking file existence: $e',
      ));
    }
  }

  @override
  String? getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return FileOpenerConstants.commonFileTypes[extension];
  }

  @override
  String? getUTI(String filePath) {
    // UTI is only relevant for iOS/macOS
    if (!Platform.isIOS && !Platform.isMacOS) {
      return null;
    }

    final extension = path.extension(filePath).toLowerCase();
    return FileOpenerConstants.iosUTITypes[extension];
  }

  /// Handle the result from open_file package
  ///
  /// Converts the package-specific result into our domain model
  Either<FileOpenerFailure, FileOpenResult> _handleOpenFileResult(
    open_file_package.OpenResult result,
    String filePath,
  ) {
    // Extract message from result
    final message = result.message;

    // Check result type
    switch (result.type) {
      case open_file_package.ResultType.done:
        return Right(FileOpenResult(
          success: true,
          message: message,
          filePath: filePath,
        ));

      case open_file_package.ResultType.fileNotFound:
        return Left(FileNotFoundFailure(filePath));

      case open_file_package.ResultType.noAppToOpen:
        final extension = path.extension(filePath);
        return Left(NoAppFoundFailure(extension));

      case open_file_package.ResultType.permissionDenied:
        return Left(PermissionDeniedFailure(filePath));

      case open_file_package.ResultType.error:
        // Return as result with success=false for other errors
        // This allows consumer to handle gracefully
        return Right(FileOpenResult(
          success: false,
          message: message,
          filePath: filePath,
        ));
    }
  }
}

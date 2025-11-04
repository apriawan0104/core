import 'failures.dart';

/// Base failure for file opener operations
class FileOpenerFailure extends Failure {
  const FileOpenerFailure(String message) : super(message: message);
}

/// Failure when the specified file is not found
class FileNotFoundFailure extends FileOpenerFailure {
  final String filePath;

  const FileNotFoundFailure(this.filePath) : super('File not found: $filePath');
}

/// Failure when no application is available to open the file
class NoAppFoundFailure extends FileOpenerFailure {
  final String fileType;

  const NoAppFoundFailure(this.fileType)
      : super('No application found to open file type: $fileType');
}

/// Failure when permission is denied to open the file
class PermissionDeniedFailure extends FileOpenerFailure {
  final String filePath;

  const PermissionDeniedFailure(this.filePath)
      : super('Permission denied to open file: $filePath');
}

/// Failure when the file path is invalid
class InvalidFilePathFailure extends FileOpenerFailure {
  final String filePath;

  const InvalidFilePathFailure(this.filePath)
      : super('Invalid file path: $filePath');
}

/// Failure when file opening operation times out
class FileOpenTimeoutFailure extends FileOpenerFailure {
  const FileOpenTimeoutFailure() : super('File opening operation timed out');
}

/// Failure for unknown/unexpected errors
class UnknownFileOpenerFailure extends FileOpenerFailure {
  const UnknownFileOpenerFailure([String? details])
      : super(details ?? 'Unknown error occurred while opening file');
}

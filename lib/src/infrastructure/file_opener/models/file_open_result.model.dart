/// Result model for file opening operations
/// 
/// This model contains information about the result of opening a file,
/// including success status and any relevant messages.
class FileOpenResult {
  /// Whether the file was opened successfully
  final bool success;

  /// Result message from the native platform
  /// 
  /// Common messages:
  /// - "done" - File opened successfully
  /// - "no_app_found" - No application found to open the file
  /// - "file_not_found" - File does not exist
  /// - "permission_denied" - No permission to open the file
  /// - "unknown_error" - Unknown error occurred
  final String message;

  /// The file path that was attempted to be opened
  final String filePath;

  const FileOpenResult({
    required this.success,
    required this.message,
    required this.filePath,
  });

  /// Check if the result indicates success
  bool get isSuccess => success && message == 'done';

  /// Check if no app was found to open the file
  bool get isNoAppFound => message.contains('no_app') || message == 'No APP found';

  /// Check if the file was not found
  bool get isFileNotFound => message.contains('file_not_found') || 
      message.contains('not found') ||
      message.contains('does not exist');

  /// Check if permission was denied
  bool get isPermissionDenied => message.contains('permission');

  /// Check if this is an unknown error
  bool get isUnknownError => !isSuccess && 
      !isNoAppFound && 
      !isFileNotFound && 
      !isPermissionDenied;

  @override
  String toString() {
    return 'FileOpenResult(success: $success, message: $message, filePath: $filePath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FileOpenResult &&
        other.success == success &&
        other.message == message &&
        other.filePath == filePath;
  }

  @override
  int get hashCode => success.hashCode ^ message.hashCode ^ filePath.hashCode;

  /// Creates a copy with optional field replacements
  FileOpenResult copyWith({
    bool? success,
    String? message,
    String? filePath,
  }) {
    return FileOpenResult(
      success: success ?? this.success,
      message: message ?? this.message,
      filePath: filePath ?? this.filePath,
    );
  }
}


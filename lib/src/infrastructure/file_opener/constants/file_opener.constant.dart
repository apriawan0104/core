/// Constants for file opener service
class FileOpenerConstants {
  /// Service name for logging and debugging
  static const String serviceName = 'FileOpenerService';

  /// Default timeout for file opening operations (in seconds)
  static const int defaultTimeout = 10;

  /// Common file type mappings
  /// 
  /// These are common MIME types / UTI types for various file extensions.
  /// You can override these when calling the service methods.
  static const Map<String, String> commonFileTypes = {
    // Documents
    '.pdf': 'application/pdf',
    '.doc': 'application/msword',
    '.docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    '.xls': 'application/vnd.ms-excel',
    '.xlsx':
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    '.ppt': 'application/vnd.ms-powerpoint',
    '.pptx':
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    '.txt': 'text/plain',
    '.rtf': 'application/rtf',
    '.csv': 'text/csv',

    // Images
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png': 'image/png',
    '.gif': 'image/gif',
    '.bmp': 'image/bmp',
    '.webp': 'image/webp',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon',

    // Videos
    '.mp4': 'video/mp4',
    '.avi': 'video/x-msvideo',
    '.mov': 'video/quicktime',
    '.wmv': 'video/x-ms-wmv',
    '.flv': 'video/x-flv',
    '.mkv': 'video/x-matroska',
    '.webm': 'video/webm',
    '.3gp': 'video/3gpp',
    '.mpg': 'video/mpeg',
    '.mpeg': 'video/mpeg',

    // Audio
    '.mp3': 'audio/mpeg',
    '.wav': 'audio/wav',
    '.ogg': 'audio/ogg',
    '.m4a': 'audio/mp4',
    '.flac': 'audio/flac',
    '.aac': 'audio/aac',
    '.wma': 'audio/x-ms-wma',

    // Archives
    '.zip': 'application/zip',
    '.rar': 'application/x-rar-compressed',
    '.7z': 'application/x-7z-compressed',
    '.tar': 'application/x-tar',
    '.gz': 'application/gzip',
    '.bz2': 'application/x-bzip2',

    // Code
    '.html': 'text/html',
    '.htm': 'text/html',
    '.xml': 'text/xml',
    '.json': 'application/json',
    '.js': 'application/javascript',
    '.css': 'text/css',
    '.java': 'text/x-java-source',
    '.py': 'text/x-python',
    '.cpp': 'text/x-c++src',
    '.c': 'text/x-c',
    '.dart': 'application/dart',

    // Android specific
    '.apk': 'application/vnd.android.package-archive',

    // Others
    '.bin': 'application/octet-stream',
    '.exe': 'application/x-msdownload',
    '.dmg': 'application/x-apple-diskimage',
  };

  /// iOS UTI (Uniform Type Identifier) mappings
  /// 
  /// Used on iOS platform to identify file types
  static const Map<String, String> iosUTITypes = {
    '.pdf': 'com.adobe.pdf',
    '.txt': 'public.plain-text',
    '.rtf': 'public.rtf',
    '.html': 'public.html',
    '.htm': 'public.html',
    '.xml': 'public.xml',
    '.jpg': 'public.jpeg',
    '.jpeg': 'public.jpeg',
    '.png': 'public.png',
    '.gif': 'com.compuserve.gif',
    '.bmp': 'com.microsoft.bmp',
    '.ico': 'com.microsoft.ico',
    '.mp4': 'public.mpeg-4',
    '.mov': 'public.movie',
    '.avi': 'public.avi',
    '.mp3': 'public.mp3',
    '.wav': 'com.microsoft.waveform-audio',
    '.zip': 'com.pkware.zip-archive',
    '.doc': 'com.microsoft.word.doc',
    '.docx':
        'org.openxmlformats.wordprocessingml.document',
    '.xls': 'com.microsoft.excel.xls',
    '.xlsx': 'org.openxmlformats.spreadsheetml.sheet',
    '.ppt': 'com.microsoft.powerpoint.ppt',
    '.pptx': 'org.openxmlformats.presentationml.presentation',
  };

  /// Error messages
  static const String fileNotFoundError = 'File not found';
  static const String invalidFilePathError = 'Invalid file path';
  static const String noAppToOpenError = 'No application available to open this file';
  static const String permissionDeniedError = 'Permission denied to open file';
  static const String unknownError = 'Unknown error occurred while opening file';
}


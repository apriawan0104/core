/// Constants for path provider service
class PathProviderConstants {
  PathProviderConstants._();

  /// Storage directory types for Android external storage
  ///
  /// These constants represent the different types of external storage
  /// directories available on Android devices.
  ///
  /// ### Usage
  ///
  /// ```dart
  /// final result = await pathProvider.getExternalStorageDirectories(
  ///   type: PathProviderConstants.storageTypeMusic,
  /// );
  /// ```
  static const String storageTypeMusic = 'music';
  static const String storageTypePodcasts = 'podcasts';
  static const String storageTypeRingtones = 'ringtones';
  static const String storageTypeAlarms = 'alarms';
  static const String storageTypeNotifications = 'notifications';
  static const String storageTypePictures = 'pictures';
  static const String storageTypeMovies = 'movies';
  static const String storageTypeDownloads = 'downloads';
  static const String storageTypeDcim = 'dcim';
  static const String storageTypeDocuments = 'documents';

  /// Default directory names
  ///
  /// These are common directory names that might be useful when
  /// creating subdirectories in the app directories.
  static const String dirNameCache = 'cache';
  static const String dirNameData = 'data';
  static const String dirNameTemp = 'temp';
  static const String dirNameLogs = 'logs';
  static const String dirNameBackup = 'backup';
  static const String dirNameDownload = 'downloads';
  static const String dirNameDocuments = 'documents';
  static const String dirNameImages = 'images';
  static const String dirNameVideos = 'videos';
  static const String dirNameAudio = 'audio';

  /// Error messages
  static const String errorPlatformNotSupported =
      'This directory is not supported on the current platform';
  static const String errorDirectoryNotAvailable =
      'The requested directory is not available';
  static const String errorPermissionDenied =
      'Permission denied to access the directory';
  static const String errorUnknown = 'An unknown error occurred';

  /// Platform support information
  ///
  /// These constants help identify which directories are supported
  /// on which platforms (for documentation purposes).
  static const List<String> platformsAll = [
    'Android',
    'iOS',
    'Linux',
    'macOS',
    'Windows',
  ];

  static const List<String> platformsIosAndMacOS = [
    'iOS',
    'macOS',
  ];

  static const List<String> platformsAndroidOnly = [
    'Android',
  ];

  /// Minimum supported versions
  static const String minAndroidVersion = '16';
  static const String minIosVersion = '12.0';
  static const String minMacOsVersion = '10.14';
  static const String minWindowsVersion = '10';
}

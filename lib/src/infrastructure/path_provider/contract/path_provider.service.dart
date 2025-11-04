import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../errors/path_provider_failure.dart';

/// Abstract service for accessing commonly used directories on the filesystem.
///
/// This service provides platform-independent access to directories like
/// temporary, documents, cache, and downloads directories.
///
/// ### Platform Support
///
/// | Directory                 | Android | iOS | Linux | macOS | Windows |
/// |---------------------------|---------|-----|-------|-------|---------|
/// | Temporary                 | ✔️      | ✔️  | ✔️    | ✔️    | ✔️      |
/// | Application Support       | ✔️      | ✔️  | ✔️    | ✔️    | ✔️      |
/// | Application Documents     | ✔️      | ✔️  | ✔️    | ✔️    | ✔️      |
/// | Application Cache         | ✔️      | ✔️  | ✔️    | ✔️    | ✔️      |
/// | Application Library       | ❌️      | ✔️  | ❌️    | ✔️    | ❌️      |
/// | Downloads                 | ✔️      | ✔️  | ✔️    | ✔️    | ✔️      |
/// | External Storage          | ✔️      | ❌   | ❌     | ❌️    | ❌️      |
/// | External Cache            | ✔️      | ❌   | ❌     | ❌️    | ❌️      |
/// | External Storage Dirs     | ✔️      | ❌   | ❌     | ❌️    | ❌️      |
///
/// ### Example
///
/// ```dart
/// final pathProvider = getIt<PathProviderService>();
///
/// // Get temporary directory
/// final result = await pathProvider.getTemporaryDirectory();
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (directory) => print('Temp dir: ${directory.path}'),
/// );
///
/// // Get application documents directory
/// final docsResult = await pathProvider.getApplicationDocumentsDirectory();
/// docsResult.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (directory) => print('Docs dir: ${directory.path}'),
/// );
/// ```
abstract class PathProviderService {
  /// Gets the path to the temporary directory on the device.
  ///
  /// This is a temporary directory that the system can clear at any time.
  /// Files in this directory may be deleted by the OS to free up space.
  ///
  /// **Supported on**: Android, iOS, Linux, macOS, Windows
  ///
  /// ### Example
  ///
  /// ```dart
  /// final result = await pathProvider.getTemporaryDirectory();
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (directory) {
  ///     final file = File('${directory.path}/temp_file.txt');
  ///     await file.writeAsString('Temporary data');
  ///   },
  /// );
  /// ```
  ///
  /// Returns [Either<PathProviderFailure, Directory>]:
  /// - [Right] with [Directory] if successful
  /// - [Left] with [PathProviderFailure] if an error occurs
  Future<Either<PathProviderFailure, Directory>> getTemporaryDirectory();

  /// Gets the path to the application support directory.
  ///
  /// This is where you should store files that your app uses internally.
  /// These files are not visible to users and are backed up on iOS.
  ///
  /// **Supported on**: Android, iOS, Linux, macOS, Windows
  ///
  /// ### Platform Locations
  ///
  /// - **Android**: `/data/data/<package_name>/files`
  /// - **iOS**: `<Application_Home>/Library/Application Support`
  /// - **macOS**: `~/Library/Application Support/<App_Name>`
  /// - **Linux**: `~/.local/share/<App_Name>`
  /// - **Windows**: `%APPDATA%\<App_Name>`
  ///
  /// ### Example
  ///
  /// ```dart
  /// final result = await pathProvider.getApplicationSupportDirectory();
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (directory) {
  ///     final configFile = File('${directory.path}/config.json');
  ///     await configFile.writeAsString('{"theme": "dark"}');
  ///   },
  /// );
  /// ```
  ///
  /// Returns [Either<PathProviderFailure, Directory>]:
  /// - [Right] with [Directory] if successful
  /// - [Left] with [PathProviderFailure] if an error occurs
  Future<Either<PathProviderFailure, Directory>>
      getApplicationSupportDirectory();

  /// Gets the path to the application documents directory.
  ///
  /// This is where you should store user-generated content or files
  /// that users might want to access directly. On iOS, these files
  /// can be made visible in the Files app.
  ///
  /// **Supported on**: Android, iOS, Linux, macOS, Windows
  ///
  /// ### Platform Locations
  ///
  /// - **Android**: `/data/data/<package_name>/app_flutter`
  /// - **iOS**: `<Application_Home>/Documents`
  /// - **macOS**: `~/Documents`
  /// - **Linux**: `~/Documents`
  /// - **Windows**: `%USERPROFILE%\Documents`
  ///
  /// ### Example
  ///
  /// ```dart
  /// final result = await pathProvider.getApplicationDocumentsDirectory();
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (directory) {
  ///     final userFile = File('${directory.path}/my_document.pdf');
  ///     // Save user document
  ///   },
  /// );
  /// ```
  ///
  /// Returns [Either<PathProviderFailure, Directory>]:
  /// - [Right] with [Directory] if successful
  /// - [Left] with [PathProviderFailure] if an error occurs
  Future<Either<PathProviderFailure, Directory>>
      getApplicationDocumentsDirectory();

  /// Gets the path to the application cache directory.
  ///
  /// This is where you should store cached data that can be regenerated.
  /// The system may delete files in this directory when storage is low.
  ///
  /// **Supported on**: Android, iOS, Linux, macOS, Windows
  ///
  /// ### Platform Locations
  ///
  /// - **Android**: `/data/data/<package_name>/cache`
  /// - **iOS**: `<Application_Home>/Library/Caches`
  /// - **macOS**: `~/Library/Caches/<App_Name>`
  /// - **Linux**: `~/.cache/<App_Name>`
  /// - **Windows**: `%LOCALAPPDATA%\<App_Name>\cache`
  ///
  /// ### Example
  ///
  /// ```dart
  /// final result = await pathProvider.getApplicationCacheDirectory();
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (directory) {
  ///     final cacheFile = File('${directory.path}/image_cache.jpg');
  ///     // Store cached image
  ///   },
  /// );
  /// ```
  ///
  /// Returns [Either<PathProviderFailure, Directory>]:
  /// - [Right] with [Directory] if successful
  /// - [Left] with [PathProviderFailure] if an error occurs
  Future<Either<PathProviderFailure, Directory>> getApplicationCacheDirectory();

  /// Gets the path to the downloads directory.
  ///
  /// This is where files downloaded by the user are typically stored.
  /// May return null on some platforms if not available.
  ///
  /// **Supported on**: Android, iOS, Linux, macOS, Windows
  ///
  /// ### Platform Locations
  ///
  /// - **Android**: External storage `/storage/emulated/0/Download`
  /// - **iOS**: `<Application_Home>/Downloads` (iOS 13+)
  /// - **macOS**: `~/Downloads`
  /// - **Linux**: `~/Downloads`
  /// - **Windows**: `%USERPROFILE%\Downloads`
  ///
  /// ### Example
  ///
  /// ```dart
  /// final result = await pathProvider.getDownloadsDirectory();
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (directoryOrNull) {
  ///     if (directoryOrNull != null) {
  ///       final downloadFile = File('${directoryOrNull.path}/report.pdf');
  ///       // Save downloaded file
  ///     } else {
  ///       print('Downloads directory not available');
  ///     }
  ///   },
  /// );
  /// ```
  ///
  /// Returns [Either<PathProviderFailure, Directory?>]:
  /// - [Right] with [Directory] if successful and available
  /// - [Right] with `null` if not supported on the platform
  /// - [Left] with [DirectoryNotSupportedFailure] if not available
  /// - [Left] with [PathProviderFailure] if an error occurs
  Future<Either<PathProviderFailure, Directory?>> getDownloadsDirectory();

  /// Gets the path to the application library directory.
  ///
  /// This is a directory for files that should not be exposed to the user.
  /// **Only supported on iOS and macOS.**
  ///
  /// **Supported on**: iOS, macOS
  ///
  /// ### Platform Locations
  ///
  /// - **iOS**: `<Application_Home>/Library`
  /// - **macOS**: `~/Library`
  ///
  /// ### Example
  ///
  /// ```dart
  /// final result = await pathProvider.getApplicationLibraryDirectory();
  /// result.fold(
  ///   (failure) {
  ///     if (failure is DirectoryNotSupportedFailure) {
  ///       print('Library directory not available on this platform');
  ///     } else {
  ///       print('Error: ${failure.message}');
  ///     }
  ///   },
  ///   (directory) {
  ///     final libraryFile = File('${directory.path}/internal_data.db');
  ///     // Store internal data
  ///   },
  /// );
  /// ```
  ///
  /// Returns [Either<PathProviderFailure, Directory>]:
  /// - [Right] with [Directory] if successful (iOS/macOS only)
  /// - [Left] with [DirectoryNotSupportedFailure] on other platforms
  /// - [Left] with [PathProviderFailure] if an error occurs
  Future<Either<PathProviderFailure, Directory>>
      getApplicationLibraryDirectory();

  /// Gets the path to the external storage directory.
  ///
  /// This is the primary external storage directory on Android.
  /// **Only supported on Android.**
  ///
  /// **Supported on**: Android only
  ///
  /// On Android, this returns `/storage/emulated/0` or similar.
  /// Requires storage permissions on Android.
  ///
  /// ### Example
  ///
  /// ```dart
  /// final result = await pathProvider.getExternalStorageDirectory();
  /// result.fold(
  ///   (failure) {
  ///     if (failure is DirectoryNotSupportedFailure) {
  ///       print('External storage not available on this platform');
  ///     } else {
  ///       print('Error: ${failure.message}');
  ///     }
  ///   },
  ///   (directoryOrNull) {
  ///     if (directoryOrNull != null) {
  ///       final file = File('${directoryOrNull.path}/data.txt');
  ///       // Store in external storage
  ///     }
  ///   },
  /// );
  /// ```
  ///
  /// Returns [Either<PathProviderFailure, Directory?>]:
  /// - [Right] with [Directory] if successful (Android only)
  /// - [Right] with `null` if not available
  /// - [Left] with [DirectoryNotSupportedFailure] on other platforms
  /// - [Left] with [PathProviderFailure] if an error occurs
  Future<Either<PathProviderFailure, Directory?>> getExternalStorageDirectory();

  /// Gets paths to external storage directories for specific types of files.
  ///
  /// This allows access to shared external storage for specific file types
  /// like music, pictures, movies, etc. **Only supported on Android.**
  ///
  /// **Supported on**: Android only
  ///
  /// ### Available Storage Types (Android)
  ///
  /// - `StorageDirectory.music` - Music files
  /// - `StorageDirectory.pictures` - Pictures
  /// - `StorageDirectory.movies` - Movies/Videos
  /// - `StorageDirectory.downloads` - Downloads
  /// - `StorageDirectory.dcim` - Camera photos
  /// - `StorageDirectory.documents` - Documents
  /// - etc.
  ///
  /// ### Example
  ///
  /// ```dart
  /// // Note: You need to define StorageDirectory enum based on
  /// // path_provider's StorageDirectory
  /// final result = await pathProvider.getExternalStorageDirectories(
  ///   type: StorageDirectory.pictures,
  /// );
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (directories) {
  ///     if (directories != null && directories.isNotEmpty) {
  ///       final picturesDir = directories.first;
  ///       final image = File('${picturesDir.path}/photo.jpg');
  ///       // Save photo to Pictures directory
  ///     }
  ///   },
  /// );
  /// ```
  ///
  /// [type] - The type of storage directory to get (e.g., pictures, music)
  ///
  /// Returns [Either<PathProviderFailure, List<Directory>?>]:
  /// - [Right] with [List<Directory>] if successful (Android only)
  /// - [Right] with `null` if not available
  /// - [Left] with [DirectoryNotSupportedFailure] on other platforms
  /// - [Left] with [PathProviderFailure] if an error occurs
  Future<Either<PathProviderFailure, List<Directory>?>>
      getExternalStorageDirectories({
    String? type,
  });

  /// Gets paths to external cache directories.
  ///
  /// Returns paths to all available external cache directories.
  /// **Only supported on Android.**
  ///
  /// **Supported on**: Android only
  ///
  /// These are cache directories on external storage that can be deleted
  /// by the system when storage is low.
  ///
  /// ### Example
  ///
  /// ```dart
  /// final result = await pathProvider.getExternalCacheDirectories();
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (directories) {
  ///     if (directories != null && directories.isNotEmpty) {
  ///       final cacheDir = directories.first;
  ///       final cacheFile = File('${cacheDir.path}/cached_data.json');
  ///       // Store cached data in external cache
  ///     }
  ///   },
  /// );
  /// ```
  ///
  /// Returns [Either<PathProviderFailure, List<Directory>?>]:
  /// - [Right] with [List<Directory>] if successful (Android only)
  /// - [Right] with `null` if not available
  /// - [Left] with [DirectoryNotSupportedFailure] on other platforms
  /// - [Left] with [PathProviderFailure] if an error occurs
  Future<Either<PathProviderFailure, List<Directory>?>>
      getExternalCacheDirectories();
}

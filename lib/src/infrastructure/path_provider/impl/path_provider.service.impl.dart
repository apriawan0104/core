import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart' as pp;

import '../../../errors/path_provider_failure.dart';
import '../contract/path_provider.service.dart';

/// Implementation of [PathProviderService] using the `path_provider` package.
///
/// This implementation wraps the `path_provider` package to provide
/// platform-independent access to common directories on the filesystem.
///
/// ### Setup
///
/// Register this implementation in your DI container:
///
/// ```dart
/// import 'package:get_it/get_it.dart';
///
/// final getIt = GetIt.instance;
///
/// void setupPathProvider() {
///   getIt.registerLazySingleton<PathProviderService>(
///     () => PathProviderServiceImpl(),
///   );
/// }
/// ```
///
/// ### Usage
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
/// ```
class PathProviderServiceImpl implements PathProviderService {
  @override
  Future<Either<PathProviderFailure, Directory>> getTemporaryDirectory() async {
    try {
      final directory = await pp.getTemporaryDirectory();
      return Right(directory);
    } catch (e) {
      return Left(
        DirectoryAccessFailure(
          'Failed to get temporary directory: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<PathProviderFailure, Directory>>
      getApplicationSupportDirectory() async {
    try {
      final directory = await pp.getApplicationSupportDirectory();
      return Right(directory);
    } catch (e) {
      return Left(
        DirectoryAccessFailure(
          'Failed to get application support directory: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<PathProviderFailure, Directory>>
      getApplicationDocumentsDirectory() async {
    try {
      final directory = await pp.getApplicationDocumentsDirectory();
      return Right(directory);
    } catch (e) {
      return Left(
        DirectoryAccessFailure(
          'Failed to get application documents directory: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<PathProviderFailure, Directory>>
      getApplicationCacheDirectory() async {
    try {
      final directory = await pp.getApplicationCacheDirectory();
      return Right(directory);
    } catch (e) {
      return Left(
        DirectoryAccessFailure(
          'Failed to get application cache directory: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<PathProviderFailure, Directory?>>
      getDownloadsDirectory() async {
    try {
      final directory = await pp.getDownloadsDirectory();
      return Right(directory);
    } catch (e) {
      // Check if error is due to platform not supporting downloads directory
      if (e.toString().contains('not supported') ||
          e.toString().contains('UnsupportedError')) {
        return const Left(
          DirectoryNotSupportedFailure(
            'Downloads directory is not supported on this platform',
          ),
        );
      }
      return Left(
        DirectoryAccessFailure(
          'Failed to get downloads directory: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<PathProviderFailure, Directory>>
      getApplicationLibraryDirectory() async {
    try {
      // Check platform - only iOS and macOS support this
      if (!Platform.isIOS && !Platform.isMacOS) {
        return const Left(
          DirectoryNotSupportedFailure(
            'Library directory is only supported on iOS and macOS',
          ),
        );
      }

      final directory = await pp.getLibraryDirectory();
      return Right(directory);
    } catch (e) {
      if (e.toString().contains('not supported') ||
          e.toString().contains('UnsupportedError')) {
        return const Left(
          DirectoryNotSupportedFailure(
            'Library directory is not supported on this platform',
          ),
        );
      }
      return Left(
        DirectoryAccessFailure(
          'Failed to get application library directory: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<PathProviderFailure, Directory?>>
      getExternalStorageDirectory() async {
    try {
      // Check platform - only Android supports this
      if (!Platform.isAndroid) {
        return const Left(
          DirectoryNotSupportedFailure(
            'External storage directory is only supported on Android',
          ),
        );
      }

      final directory = await pp.getExternalStorageDirectory();
      return Right(directory);
    } catch (e) {
      if (e.toString().contains('not supported') ||
          e.toString().contains('UnsupportedError')) {
        return const Left(
          DirectoryNotSupportedFailure(
            'External storage directory is not supported on this platform',
          ),
        );
      }
      return Left(
        DirectoryAccessFailure(
          'Failed to get external storage directory: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<PathProviderFailure, List<Directory>?>>
      getExternalStorageDirectories({
    String? type,
  }) async {
    try {
      // Check platform - only Android supports this
      if (!Platform.isAndroid) {
        return const Left(
          DirectoryNotSupportedFailure(
            'External storage directories are only supported on Android',
          ),
        );
      }

      // Convert string type to StorageDirectory enum if needed
      pp.StorageDirectory? storageType;
      if (type != null) {
        storageType = _parseStorageDirectory(type);
      }

      final directories =
          await pp.getExternalStorageDirectories(type: storageType);
      return Right(directories);
    } catch (e) {
      if (e.toString().contains('not supported') ||
          e.toString().contains('UnsupportedError')) {
        return const Left(
          DirectoryNotSupportedFailure(
            'External storage directories are not supported on this platform',
          ),
        );
      }
      return Left(
        DirectoryAccessFailure(
          'Failed to get external storage directories: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<PathProviderFailure, List<Directory>?>>
      getExternalCacheDirectories() async {
    try {
      // Check platform - only Android supports this
      if (!Platform.isAndroid) {
        return const Left(
          DirectoryNotSupportedFailure(
            'External cache directories are only supported on Android',
          ),
        );
      }

      final directories = await pp.getExternalCacheDirectories();
      return Right(directories);
    } catch (e) {
      if (e.toString().contains('not supported') ||
          e.toString().contains('UnsupportedError')) {
        return const Left(
          DirectoryNotSupportedFailure(
            'External cache directories are not supported on this platform',
          ),
        );
      }
      return Left(
        DirectoryAccessFailure(
          'Failed to get external cache directories: ${e.toString()}',
        ),
      );
    }
  }

  /// Helper method to parse string type to StorageDirectory enum
  pp.StorageDirectory? _parseStorageDirectory(String type) {
    switch (type.toLowerCase()) {
      case 'music':
        return pp.StorageDirectory.music;
      case 'podcasts':
        return pp.StorageDirectory.podcasts;
      case 'ringtones':
        return pp.StorageDirectory.ringtones;
      case 'alarms':
        return pp.StorageDirectory.alarms;
      case 'notifications':
        return pp.StorageDirectory.notifications;
      case 'pictures':
        return pp.StorageDirectory.pictures;
      case 'movies':
        return pp.StorageDirectory.movies;
      case 'downloads':
        return pp.StorageDirectory.downloads;
      case 'dcim':
        return pp.StorageDirectory.dcim;
      case 'documents':
        return pp.StorageDirectory.documents;
      default:
        return null;
    }
  }
}

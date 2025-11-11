import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart' as iap;

import '../../../errors/errors.dart';
import '../contract/contracts.dart';
import '../models/models.dart';

/// Android In-App Update service implementation.
///
/// This implementation uses the `in_app_update` package to provide
/// in-app update functionality for Android apps via Google Play.
///
/// Compatible with in_app_update: ^4.2.5
///
/// ## Platform Support
///
/// - ✅ Android: Fully supported
/// - ❌ iOS: Returns `PLATFORM_NOT_SUPPORTED` error
///
/// ## Important Notes
///
/// **Testing Requirements:**
/// - In-app updates CANNOT be tested locally
/// - App must be uploaded to Play Console (Internal/Alpha/Beta track)
/// - App must be installed via Google Play
/// - Must have a higher version code available on Play Store
///
/// See: https://developer.android.com/guide/playcore/in-app-updates/test
///
/// **Common Issues:**
/// - `ERROR_API_NOT_AVAILABLE`: App not installed via Play Store
/// - Local testing will always fail - must use Play Store distribution
///
/// ## Setup
///
/// ### 1. Add dependency to pubspec.yaml:
///
/// ```yaml
/// dependencies:
///   in_app_update: ^4.2.5
/// ```
///
/// ### 2. Register in DI container:
///
/// ```dart
/// getIt.registerLazySingleton<InAppUpdateService>(
///   () => AndroidInAppUpdateServiceImpl(),
/// );
/// ```
///
/// ### 3. Initialize before use:
///
/// ```dart
/// final updateService = getIt<InAppUpdateService>();
/// await updateService.initialize();
/// ```
///
/// ## Usage Example
///
/// ### Check for Update
///
/// ```dart
/// final result = await updateService.checkForUpdate();
/// result.fold(
///   (failure) => print('Check failed: $failure'),
///   (info) {
///     if (info.isUpdateAvailable) {
///       print('Update available!');
///     }
///   },
/// );
/// ```
///
/// ### Immediate Update
///
/// ```dart
/// await updateService.performImmediateUpdate();
/// // App will restart after update
/// ```
///
/// ### Flexible Update
///
/// ```dart
/// // Start download
/// await updateService.startFlexibleUpdate();
///
/// // Listen for completion
/// updateService.installStatusStream.listen((status) {
///   if (status.isDownloaded) {
///     // Prompt user to install
///     showInstallDialog();
///   }
/// });
///
/// // Install when ready
/// await updateService.completeFlexibleUpdate();
/// ```
class AndroidInAppUpdateServiceImpl implements InAppUpdateService {
  final StreamController<InstallStatus> _installStatusController;
  bool _isInitialized = false;
  bool _isUpdateInProgress = false;

  /// Creates an Android in-app update service.
  AndroidInAppUpdateServiceImpl()
      : _installStatusController = StreamController<InstallStatus>.broadcast();

  @override
  Future<Either<InAppUpdateFailure, void>> initialize() async {
    try {
      // Check platform support
      if (!Platform.isAndroid) {
        return Left(InAppUpdateFailure.platformNotSupported());
      }

      _isInitialized = true;
      return const Right(null);
    } catch (e) {
      return Left(
        InAppUpdateFailure(
          message: 'Failed to initialize in-app update service: $e',
          code: 'INITIALIZATION_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<InAppUpdateFailure, AppUpdateInfo>> checkForUpdate() async {
    try {
      // Ensure initialized
      if (!_isInitialized) {
        return Left(
          InAppUpdateFailure(
            message: 'Service not initialized. Call initialize() first.',
            code: 'SERVICE_NOT_INITIALIZED',
          ),
        );
      }

      // Check platform
      if (!Platform.isAndroid) {
        return Left(InAppUpdateFailure.platformNotSupported());
      }

      // Check for update
      final updateInfo = await iap.InAppUpdate.checkForUpdate();

      // Map to our model
      final appUpdateInfo = _mapToAppUpdateInfo(updateInfo);

      return Right(appUpdateInfo);
    } on PlatformException catch (e) {
      return Left(_mapPlatformException(e));
    } catch (e) {
      return Left(InAppUpdateFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<InAppUpdateFailure, void>> performImmediateUpdate() async {
    try {
      // Ensure initialized
      if (!_isInitialized) {
        return Left(
          InAppUpdateFailure(
            message: 'Service not initialized. Call initialize() first.',
            code: 'SERVICE_NOT_INITIALIZED',
          ),
        );
      }

      // Check platform
      if (!Platform.isAndroid) {
        return Left(InAppUpdateFailure.platformNotSupported());
      }

      // Check if update is already in progress
      if (_isUpdateInProgress) {
        return Left(InAppUpdateFailure.updateInProgress());
      }

      _isUpdateInProgress = true;

      // Perform immediate update
      await iap.InAppUpdate.performImmediateUpdate();

      // If we reach here, update completed successfully
      // (though app should have restarted)
      _isUpdateInProgress = false;
      return const Right(null);
    } on PlatformException catch (e) {
      _isUpdateInProgress = false;
      return Left(_mapPlatformException(e));
    } catch (e) {
      _isUpdateInProgress = false;
      return Left(InAppUpdateFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<InAppUpdateFailure, void>> startFlexibleUpdate() async {
    try {
      // Ensure initialized
      if (!_isInitialized) {
        return Left(
          InAppUpdateFailure(
            message: 'Service not initialized. Call initialize() first.',
            code: 'SERVICE_NOT_INITIALIZED',
          ),
        );
      }

      // Check platform
      if (!Platform.isAndroid) {
        return Left(InAppUpdateFailure.platformNotSupported());
      }

      // Check if update is already in progress
      if (_isUpdateInProgress) {
        return Left(InAppUpdateFailure.updateInProgress());
      }

      _isUpdateInProgress = true;

      // Start flexible update
      await iap.InAppUpdate.startFlexibleUpdate();

      // Emit initial status
      _installStatusController.add(InstallStatus.pending);

      // Note: The actual download happens in background
      // Status updates should be monitored via installStatusStream
      return const Right(null);
    } on PlatformException catch (e) {
      _isUpdateInProgress = false;
      return Left(_mapPlatformException(e));
    } catch (e) {
      _isUpdateInProgress = false;
      return Left(InAppUpdateFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<InAppUpdateFailure, void>> completeFlexibleUpdate() async {
    try {
      // Ensure initialized
      if (!_isInitialized) {
        return Left(
          InAppUpdateFailure(
            message: 'Service not initialized. Call initialize() first.',
            code: 'SERVICE_NOT_INITIALIZED',
          ),
        );
      }

      // Check platform
      if (!Platform.isAndroid) {
        return Left(InAppUpdateFailure.platformNotSupported());
      }

      // Complete the flexible update
      await iap.InAppUpdate.completeFlexibleUpdate();

      // Emit installed status
      _installStatusController.add(InstallStatus.installed);
      _isUpdateInProgress = false;

      // If we reach here, update completed successfully
      // (though app should have restarted)
      return const Right(null);
    } on PlatformException catch (e) {
      return Left(_mapPlatformException(e));
    } catch (e) {
      return Left(InAppUpdateFailure.unknown(e.toString()));
    }
  }

  @override
  Stream<InstallStatus> get installStatusStream =>
      _installStatusController.stream;

  @override
  Future<Either<InAppUpdateFailure, bool>> isUpdateSupported() async {
    try {
      // Only Android is supported
      return Right(Platform.isAndroid);
    } catch (e) {
      return Left(InAppUpdateFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<InAppUpdateFailure, InstallStatus>>
      getCurrentInstallStatus() async {
    try {
      // Ensure initialized
      if (!_isInitialized) {
        return Left(
          InAppUpdateFailure(
            message: 'Service not initialized. Call initialize() first.',
            code: 'SERVICE_NOT_INITIALIZED',
          ),
        );
      }

      // Check platform
      if (!Platform.isAndroid) {
        return Left(InAppUpdateFailure.platformNotSupported());
      }

      // Get current update info
      final updateInfo = await iap.InAppUpdate.checkForUpdate();

      // Map install status
      final installStatus = _mapInstallStatus(updateInfo.installStatus);

      return Right(installStatus);
    } on PlatformException catch (e) {
      return Left(_mapPlatformException(e));
    } catch (e) {
      return Left(InAppUpdateFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<InAppUpdateFailure, void>> dispose() async {
    try {
      await _installStatusController.close();
      _isInitialized = false;
      _isUpdateInProgress = false;
      return const Right(null);
    } catch (e) {
      return Left(InAppUpdateFailure.unknown(e.toString()));
    }
  }

  /// Maps the third-party AppUpdateInfo to our model.
  AppUpdateInfo _mapToAppUpdateInfo(iap.AppUpdateInfo info) {
    return AppUpdateInfo(
      updateAvailability: _mapUpdateAvailability(info.updateAvailability),
      immediateUpdateAllowed: info.immediateUpdateAllowed,
      flexibleUpdateAllowed: info.flexibleUpdateAllowed,
      availableVersionCode: info.availableVersionCode,
      installStatus: _mapInstallStatus(info.installStatus),
      packageName: info.packageName,
      clientVersionStalenessDays: info.clientVersionStalenessDays,
      updatePriority: info.updatePriority,
    );
  }

  /// Maps third-party UpdateAvailability to our enum.
  UpdateAvailability _mapUpdateAvailability(
    iap.UpdateAvailability availability,
  ) {
    switch (availability) {
      case iap.UpdateAvailability.updateAvailable:
        return UpdateAvailability.updateAvailable;
      case iap.UpdateAvailability.updateNotAvailable:
        return UpdateAvailability.updateNotAvailable;
      case iap.UpdateAvailability.developerTriggeredUpdateInProgress:
        return UpdateAvailability.developerTriggeredUpdateInProgress;
      default:
        return UpdateAvailability.unknown;
    }
  }

  /// Maps third-party InstallStatus to our enum.
  InstallStatus _mapInstallStatus(iap.InstallStatus status) {
    switch (status) {
      case iap.InstallStatus.pending:
        return InstallStatus.pending;
      case iap.InstallStatus.downloading:
        return InstallStatus.downloading;
      case iap.InstallStatus.downloaded:
        return InstallStatus.downloaded;
      case iap.InstallStatus.installing:
        return InstallStatus.installing;
      case iap.InstallStatus.installed:
        return InstallStatus.installed;
      case iap.InstallStatus.failed:
        return InstallStatus.failed;
      case iap.InstallStatus.canceled:
        return InstallStatus.canceled;
      default:
        return InstallStatus.unknown;
    }
  }

  /// Maps platform exception to our failure.
  InAppUpdateFailure _mapPlatformException(PlatformException exception) {
    final code = exception.code;
    final message = exception.message;

    // Map known error codes from Android In-App Update API
    switch (code) {
      case 'ERROR_API_NOT_AVAILABLE':
      case 'ACTIVITY_RESULT_ERROR':
        return InAppUpdateFailure.apiNotAvailable();
      case 'ERROR_UPDATE_NOT_AVAILABLE':
        return InAppUpdateFailure.updateNotAvailable();
      case 'ERROR_UPDATE_UNAVAILABLE':
        return InAppUpdateFailure.updateUnavailable();
      case 'ERROR_DOWNLOAD_NOT_PRESENT':
        return InAppUpdateFailure.downloadNotPresent();
      case 'ERROR_INSTALL_NOT_ALLOWED':
        return InAppUpdateFailure.installNotAllowed();
      case 'ERROR_INSTALL_UNAVAILABLE':
        return InAppUpdateFailure.installUnavailable();
      default:
        return InAppUpdateFailure(
          message: message ?? 'Unknown error: $code',
          code: code,
        );
    }
  }
}

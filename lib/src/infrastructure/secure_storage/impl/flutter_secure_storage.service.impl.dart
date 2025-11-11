import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    as flutter_secure;

import 'package:app_core/src/errors/errors.dart';
import 'package:app_core/src/infrastructure/secure_storage/contract/contracts.dart';
import 'package:app_core/src/infrastructure/secure_storage/models/models.dart';

/// Implementation of [SecureStorageService] using flutter_secure_storage package.
///
/// **Platform Support:**
/// - iOS: Keychain
/// - Android: KeyStore (or EncryptedSharedPreferences with API 23+)
/// - Linux: libsecret
/// - macOS: Keychain
/// - Windows: Credential Manager
/// - Web: WebCrypto (experimental)
///
/// **Important Notes:**
/// - On Android, mixing EncryptedSharedPreferences and KeyStore will cause errors
/// - Pass options to constructor, not to individual methods (see flutter_secure_storage docs)
/// - On iOS/macOS, requires keychain entitlements
/// - On Linux, requires libsecret-1-dev
///
/// Example usage:
/// ```dart
/// // Register in DI
/// getIt.registerLazySingleton<SecureStorageService>(
///   () => FlutterSecureStorageServiceImpl(
///     options: SecureStorageOptions.balanced(),
///   ),
/// );
///
/// // Use in app
/// final secureStorage = getIt<SecureStorageService>();
/// await secureStorage.write(key: 'token', value: 'abc123');
/// final result = await secureStorage.read(key: 'token');
/// ```
class FlutterSecureStorageServiceImpl implements SecureStorageService {
  final flutter_secure.FlutterSecureStorage _storage;

  /// Create instance with optional default options.
  ///
  /// **Important**: On Android, the options should be passed here to avoid
  /// mixing EncryptedSharedPreferences and KeyStore. See:
  /// https://github.com/mogol/flutter_secure_storage/issues/354
  ///
  /// Example:
  /// ```dart
  /// // With custom options
  /// final storage = FlutterSecureStorageServiceImpl(
  ///   options: SecureStorageOptions(
  ///     useEncryptedSharedPreferences: true,
  ///     accessibility: KeychainAccessibility.firstUnlock,
  ///   ),
  /// );
  ///
  /// // With defaults
  /// final storage = FlutterSecureStorageServiceImpl();
  /// ```
  FlutterSecureStorageServiceImpl({
    SecureStorageOptions? options,
  }) : _storage = flutter_secure.FlutterSecureStorage(
          aOptions: _mapToAndroidOptions(options),
          iOptions: _mapToIOSOptions(options),
          lOptions: _mapToLinuxOptions(options),
          wOptions: _mapToWindowsOptions(options),
          mOptions: _mapToMacOSOptions(options),
          webOptions: _mapToWebOptions(options),
        );

  @override
  Future<Either<SecureStorageFailure, void>> write({
    required String key,
    required String value,
    SecureStorageOptions? options,
  }) async {
    try {
      // Validate key
      if (key.isEmpty) {
        return const Left(
          SecureStorageInvalidKeyFailure(
            key: '',
            message: 'Key cannot be empty',
          ),
        );
      }

      // Write to secure storage
      await _storage.write(
        key: key,
        value: value,
        iOptions: options != null ? _mapToIOSOptions(options) : null,
        aOptions: options != null ? _mapToAndroidOptions(options) : null,
        lOptions: options != null ? _mapToLinuxOptions(options) : null,
        wOptions: options != null ? _mapToWindowsOptions(options) : null,
        mOptions: options != null ? _mapToMacOSOptions(options) : null,
        webOptions: options != null ? _mapToWebOptions(options) : null,
      );

      return const Right(null);
    } on Exception catch (e) {
      if (e.toString().contains('PlatformException')) {
        return Left(_mapPlatformError(e.toString(), 'write'));
      }
      return Left(
        SecureStorageWriteFailure(
          message: 'Failed to write: ${e.toString()}',
          details: {'key': key, 'error': e.toString()},
        ),
      );
    } catch (e) {
      return Left(
        UnknownSecureStorageFailure(
          message: 'Failed to write to secure storage: $e',
          details: {'key': key, 'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Either<SecureStorageFailure, String?>> read({
    required String key,
    SecureStorageOptions? options,
  }) async {
    try {
      // Validate key
      if (key.isEmpty) {
        return const Left(
          SecureStorageInvalidKeyFailure(
            key: '',
            message: 'Key cannot be empty',
          ),
        );
      }

      // Read from secure storage
      final value = await _storage.read(
        key: key,
        iOptions: options != null ? _mapToIOSOptions(options) : null,
        aOptions: options != null ? _mapToAndroidOptions(options) : null,
        lOptions: options != null ? _mapToLinuxOptions(options) : null,
        wOptions: options != null ? _mapToWindowsOptions(options) : null,
        mOptions: options != null ? _mapToMacOSOptions(options) : null,
        webOptions: options != null ? _mapToWebOptions(options) : null,
      );

      return Right(value);
    } on Exception catch (e) {
      if (e.toString().contains('PlatformException')) {
        return Left(_mapPlatformError(e.toString(), 'read'));
      }
      return Left(
        SecureStorageReadFailure(
          message: 'Failed to read: ${e.toString()}',
          details: {'key': key, 'error': e.toString()},
        ),
      );
    } catch (e) {
      return Left(
        UnknownSecureStorageFailure(
          message: 'Failed to read from secure storage: $e',
          details: {'key': key, 'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Either<SecureStorageFailure, Map<String, String>>> readAll({
    SecureStorageOptions? options,
  }) async {
    try {
      final allData = await _storage.readAll(
        iOptions: options != null ? _mapToIOSOptions(options) : null,
        aOptions: options != null ? _mapToAndroidOptions(options) : null,
        lOptions: options != null ? _mapToLinuxOptions(options) : null,
        wOptions: options != null ? _mapToWindowsOptions(options) : null,
        mOptions: options != null ? _mapToMacOSOptions(options) : null,
        webOptions: options != null ? _mapToWebOptions(options) : null,
      );

      return Right(allData);
    } on Exception catch (e) {
      if (e.toString().contains('PlatformException')) {
        return Left(_mapPlatformError(e.toString(), 'readAll'));
      }
      return Left(
        SecureStorageReadFailure(
          message: 'Failed to read all: ${e.toString()}',
          details: {'error': e.toString()},
        ),
      );
    } catch (e) {
      return Left(
        UnknownSecureStorageFailure(
          message: 'Failed to read all from secure storage: $e',
          details: {'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Either<SecureStorageFailure, void>> delete({
    required String key,
    SecureStorageOptions? options,
  }) async {
    try {
      // Validate key
      if (key.isEmpty) {
        return const Left(
          SecureStorageInvalidKeyFailure(
            key: '',
            message: 'Key cannot be empty',
          ),
        );
      }

      await _storage.delete(
        key: key,
        iOptions: options != null ? _mapToIOSOptions(options) : null,
        aOptions: options != null ? _mapToAndroidOptions(options) : null,
        lOptions: options != null ? _mapToLinuxOptions(options) : null,
        wOptions: options != null ? _mapToWindowsOptions(options) : null,
        mOptions: options != null ? _mapToMacOSOptions(options) : null,
        webOptions: options != null ? _mapToWebOptions(options) : null,
      );

      return const Right(null);
    } on Exception catch (e) {
      if (e.toString().contains('PlatformException')) {
        return Left(_mapPlatformError(e.toString(), 'delete'));
      }
      return Left(
        SecureStorageDeleteFailure(
          message: 'Failed to delete: ${e.toString()}',
          details: {'key': key, 'error': e.toString()},
        ),
      );
    } catch (e) {
      return Left(
        UnknownSecureStorageFailure(
          message: 'Failed to delete from secure storage: $e',
          details: {'key': key, 'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Either<SecureStorageFailure, void>> deleteAll({
    SecureStorageOptions? options,
  }) async {
    try {
      await _storage.deleteAll(
        iOptions: options != null ? _mapToIOSOptions(options) : null,
        aOptions: options != null ? _mapToAndroidOptions(options) : null,
        lOptions: options != null ? _mapToLinuxOptions(options) : null,
        wOptions: options != null ? _mapToWindowsOptions(options) : null,
        mOptions: options != null ? _mapToMacOSOptions(options) : null,
        webOptions: options != null ? _mapToWebOptions(options) : null,
      );

      return const Right(null);
    } on Exception catch (e) {
      if (e.toString().contains('PlatformException')) {
        return Left(_mapPlatformError(e.toString(), 'deleteAll'));
      }
      return Left(
        SecureStorageDeleteFailure(
          message: 'Failed to delete all: ${e.toString()}',
          details: {'error': e.toString()},
        ),
      );
    } catch (e) {
      return Left(
        UnknownSecureStorageFailure(
          message: 'Failed to delete all from secure storage: $e',
          details: {'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Either<SecureStorageFailure, bool>> containsKey({
    required String key,
    SecureStorageOptions? options,
  }) async {
    try {
      // Validate key
      if (key.isEmpty) {
        return const Left(
          SecureStorageInvalidKeyFailure(
            key: '',
            message: 'Key cannot be empty',
          ),
        );
      }

      final contains = await _storage.containsKey(
        key: key,
        iOptions: options != null ? _mapToIOSOptions(options) : null,
        aOptions: options != null ? _mapToAndroidOptions(options) : null,
        lOptions: options != null ? _mapToLinuxOptions(options) : null,
        wOptions: options != null ? _mapToWindowsOptions(options) : null,
        mOptions: options != null ? _mapToMacOSOptions(options) : null,
        webOptions: options != null ? _mapToWebOptions(options) : null,
      );

      return Right(contains);
    } on Exception catch (e) {
      if (e.toString().contains('PlatformException')) {
        return Left(_mapPlatformError(e.toString(), 'containsKey'));
      }
      return Left(
        SecureStorageReadFailure(
          message: 'Failed to check key: ${e.toString()}',
          details: {'key': key, 'error': e.toString()},
        ),
      );
    } catch (e) {
      return Left(
        UnknownSecureStorageFailure(
          message: 'Failed to check key in secure storage: $e',
          details: {'key': key, 'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Either<SecureStorageFailure, List<String>>> getAllKeys({
    SecureStorageOptions? options,
  }) async {
    try {
      final allData = await readAll(options: options);

      return allData.fold(
        (failure) => Left(failure),
        (data) => Right(data.keys.toList()),
      );
    } catch (e) {
      return Left(
        UnknownSecureStorageFailure(
          message: 'Failed to get all keys from secure storage: $e',
          details: {'error': e.toString()},
        ),
      );
    }
  }

  // ==================== Private Helper Methods ====================

  /// Map our [SecureStorageOptions] to flutter_secure_storage AndroidOptions.
  static flutter_secure.AndroidOptions _mapToAndroidOptions(
    SecureStorageOptions? options,
  ) {
    if (options == null) {
      return const flutter_secure.AndroidOptions();
    }

    return flutter_secure.AndroidOptions(
      encryptedSharedPreferences:
          options.useEncryptedSharedPreferences ?? false,
    );
  }

  /// Map our [SecureStorageOptions] to flutter_secure_storage IOSOptions.
  static flutter_secure.IOSOptions _mapToIOSOptions(
    SecureStorageOptions? options,
  ) {
    if (options == null) {
      return const flutter_secure.IOSOptions();
    }

    return flutter_secure.IOSOptions(
      accessibility: _mapToIOSKeychain(options.accessibility),
      accountName: options.accountName,
      groupId: options.accessGroup,
      synchronizable: options.iCloudSync ?? false,
    );
  }

  /// Map our [SecureStorageOptions] to flutter_secure_storage LinuxOptions.
  static flutter_secure.LinuxOptions _mapToLinuxOptions(
    SecureStorageOptions? options,
  ) {
    return const flutter_secure.LinuxOptions();
  }

  /// Map our [SecureStorageOptions] to flutter_secure_storage WindowsOptions.
  static flutter_secure.WindowsOptions _mapToWindowsOptions(
    SecureStorageOptions? options,
  ) {
    return const flutter_secure.WindowsOptions();
  }

  /// Map our [SecureStorageOptions] to flutter_secure_storage MacOsOptions.
  static flutter_secure.MacOsOptions _mapToMacOSOptions(
    SecureStorageOptions? options,
  ) {
    if (options == null) {
      return const flutter_secure.MacOsOptions();
    }

    return flutter_secure.MacOsOptions(
      accessibility: _mapToIOSKeychain(options.accessibility),
      accountName: options.accountName,
      groupId: options.accessGroup,
      synchronizable: options.iCloudSync ?? false,
    );
  }

  /// Map our [SecureStorageOptions] to flutter_secure_storage WebOptions.
  static flutter_secure.WebOptions _mapToWebOptions(
    SecureStorageOptions? options,
  ) {
    return const flutter_secure.WebOptions();
  }

  /// Map our [KeychainAccessibility] enum to flutter_secure_storage KeychainAccessibility.
  static flutter_secure.KeychainAccessibility? _mapToIOSKeychain(
    KeychainAccessibility? accessibility,
  ) {
    if (accessibility == null) return null;

    switch (accessibility) {
      case KeychainAccessibility.unlocked:
        return flutter_secure.KeychainAccessibility.unlocked;
      case KeychainAccessibility.unlockedThisDeviceOnly:
        return flutter_secure.KeychainAccessibility.unlocked_this_device;
      case KeychainAccessibility.firstUnlock:
        return flutter_secure.KeychainAccessibility.first_unlock;
      case KeychainAccessibility.firstUnlockThisDeviceOnly:
        return flutter_secure.KeychainAccessibility.first_unlock_this_device;
      case KeychainAccessibility.always:
        // Note: 'always' is deprecated in newer versions
        // Fallback to firstUnlock for compatibility
        return flutter_secure.KeychainAccessibility.first_unlock;
      case KeychainAccessibility.alwaysThisDeviceOnly:
        // Note: 'alwaysThisDeviceOnly' is deprecated in newer versions
        // Fallback to firstUnlockThisDevice for compatibility
        return flutter_secure.KeychainAccessibility.first_unlock_this_device;
      case KeychainAccessibility.passcodeSetThisDeviceOnly:
        return flutter_secure.KeychainAccessibility.unlocked_this_device;
    }
  }

  /// Map platform error string to our failure types.
  static SecureStorageFailure _mapPlatformError(
    String errorString,
    String operation,
  ) {
    final message = errorString;

    // Check for common error patterns
    if (message.contains('SecurityError') || message.contains('security')) {
      return SecureStorageAccessDeniedFailure(
        message: 'Security error: $message',
        details: {'operation': operation, 'error': message},
      );
    }

    if (message.contains('locked')) {
      return SecureStorageDeviceLockRequiredFailure(
        message: 'Device must be unlocked: $message',
        details: {'operation': operation, 'error': message},
      );
    }

    if (message.contains('passcode')) {
      return SecureStoragePasscodeNotSetFailure(
        message: 'Device passcode required: $message',
        details: {'operation': operation, 'error': message},
      );
    }

    if (message.contains('encrypt') || message.contains('decrypt')) {
      return SecureStorageEncryptionFailure(
        message: 'Encryption error: $message',
        details: {'operation': operation, 'error': message},
      );
    }

    if (message.contains('encryptedSharedPreferences') ||
        message.contains('KeyStore') ||
        message.contains('mixed')) {
      return SecureStorageMixedEncryptionModeFailure(
        message: message,
        details: {'operation': operation, 'error': message},
      );
    }

    if (message.contains('not supported')) {
      return SecureStoragePlatformNotSupportedFailure(
        platform: 'unknown',
        message: message,
        details: {'operation': operation, 'error': message},
      );
    }

    // Generic platform error
    if (operation == 'write') {
      return SecureStorageWriteFailure(
        message: message,
        details: {'error': message},
      );
    } else if (operation == 'read' || operation == 'readAll') {
      return SecureStorageReadFailure(
        message: message,
        details: {'error': message},
      );
    } else if (operation == 'delete' || operation == 'deleteAll') {
      return SecureStorageDeleteFailure(
        message: message,
        details: {'error': message},
      );
    }

    return UnknownSecureStorageFailure(
      message: message,
      details: {'operation': operation, 'error': message},
    );
  }
}

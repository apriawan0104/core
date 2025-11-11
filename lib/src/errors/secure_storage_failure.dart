import 'failures.dart';

/// Base class for secure storage-related failures.
///
/// All secure storage errors inherit from this class.
class SecureStorageFailure extends Failure {
  const SecureStorageFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Write failure - failed to write data to secure storage.
class SecureStorageWriteFailure extends SecureStorageFailure {
  const SecureStorageWriteFailure({
    super.message = 'Failed to write data to secure storage.',
    super.code,
    super.details,
  });
}

/// Read failure - failed to read data from secure storage.
class SecureStorageReadFailure extends SecureStorageFailure {
  const SecureStorageReadFailure({
    super.message = 'Failed to read data from secure storage.',
    super.code,
    super.details,
  });
}

/// Delete failure - failed to delete data from secure storage.
class SecureStorageDeleteFailure extends SecureStorageFailure {
  const SecureStorageDeleteFailure({
    super.message = 'Failed to delete data from secure storage.',
    super.code,
    super.details,
  });
}

/// Key not found failure - requested key doesn't exist in secure storage.
class SecureStorageKeyNotFoundFailure extends SecureStorageFailure {
  final String key;

  const SecureStorageKeyNotFoundFailure({
    required this.key,
    super.message = 'Key not found in secure storage.',
    super.code,
    super.details,
  });

  @override
  String toString() {
    return 'SecureStorageKeyNotFoundFailure(key: $key, message: $message)';
  }
}

/// Platform not supported failure - current platform doesn't support secure storage.
class SecureStoragePlatformNotSupportedFailure extends SecureStorageFailure {
  final String platform;

  const SecureStoragePlatformNotSupportedFailure({
    required this.platform,
    super.message = 'Secure storage not supported on this platform.',
    super.code,
    super.details,
  });

  @override
  String toString() {
    return 'SecureStoragePlatformNotSupportedFailure(platform: $platform, message: $message)';
  }
}

/// Invalid key failure - key is invalid (empty, null, or contains invalid characters).
class SecureStorageInvalidKeyFailure extends SecureStorageFailure {
  final String key;

  const SecureStorageInvalidKeyFailure({
    required this.key,
    super.message = 'Invalid storage key.',
    super.code,
    super.details,
  });

  @override
  String toString() {
    return 'SecureStorageInvalidKeyFailure(key: $key, message: $message)';
  }
}

/// Encryption failure - failed to encrypt or decrypt data.
///
/// This could happen due to:
/// - Corrupted encryption keys
/// - KeyStore/Keychain unavailable
/// - Platform security restrictions
class SecureStorageEncryptionFailure extends SecureStorageFailure {
  const SecureStorageEncryptionFailure({
    super.message = 'Failed to encrypt/decrypt secure data.',
    super.code,
    super.details,
  });
}

/// Keychain/KeyStore access denied failure.
///
/// Platform denied access to secure storage:
/// - iOS: User denied Keychain access
/// - Android: KeyStore locked or unavailable
/// - Biometric authentication failed
class SecureStorageAccessDeniedFailure extends SecureStorageFailure {
  const SecureStorageAccessDeniedFailure({
    super.message = 'Access to secure storage denied.',
    super.code,
    super.details,
  });
}

/// Device lock required failure.
///
/// Some secure storage operations require device to be unlocked:
/// - Reading data with `unlocked` accessibility
/// - Writing to KeyStore when device is locked
class SecureStorageDeviceLockRequiredFailure extends SecureStorageFailure {
  const SecureStorageDeviceLockRequiredFailure({
    super.message =
        'Device must be unlocked to access secure storage with current settings.',
    super.code,
    super.details,
  });
}

/// Passcode not set failure.
///
/// Operation requires device passcode but none is set:
/// - Using `passcodeSetThisDeviceOnly` accessibility without passcode
class SecureStoragePasscodeNotSetFailure extends SecureStorageFailure {
  const SecureStoragePasscodeNotSetFailure({
    super.message = 'Device passcode must be set for this operation.',
    super.code,
    super.details,
  });
}

/// Mixed encryption mode failure.
///
/// Attempting to mix EncryptedSharedPreferences and KeyStore on Android.
///
/// **Fix**: Choose one encryption method and use it consistently:
/// - Either use `useEncryptedSharedPreferences: true` for all operations
/// - Or use `useEncryptedSharedPreferences: false` (or omit) for all operations
class SecureStorageMixedEncryptionModeFailure extends SecureStorageFailure {
  const SecureStorageMixedEncryptionModeFailure({
    super.message =
        'Cannot mix EncryptedSharedPreferences and KeyStore. Choose one encryption method.',
    super.code,
    super.details,
  });
}

/// Unknown secure storage failure - unexpected error occurred.
class UnknownSecureStorageFailure extends SecureStorageFailure {
  const UnknownSecureStorageFailure({
    super.message = 'An unexpected secure storage error occurred.',
    super.code,
    super.details,
  });
}


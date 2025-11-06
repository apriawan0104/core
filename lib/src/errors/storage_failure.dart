import 'failures.dart';

/// Base class for storage-related failures
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Initialization failure - failed to initialize storage
class StorageInitializationFailure extends StorageFailure {
  const StorageInitializationFailure({
    super.message = 'Failed to initialize storage.',
    super.code,
    super.details,
  });
}

/// Not initialized failure - storage accessed before initialization
class StorageNotInitializedFailure extends StorageFailure {
  const StorageNotInitializedFailure({
    super.message = 'Storage not initialized. Call initialize() first.',
    super.code,
    super.details,
  });
}

/// Save failure - failed to save data
class StorageSaveFailure extends StorageFailure {
  const StorageSaveFailure({
    super.message = 'Failed to save data to storage.',
    super.code,
    super.details,
  });
}

/// Read failure - failed to read data
class StorageReadFailure extends StorageFailure {
  const StorageReadFailure({
    super.message = 'Failed to read data from storage.',
    super.code,
    super.details,
  });
}

/// Delete failure - failed to delete data
class StorageDeleteFailure extends StorageFailure {
  const StorageDeleteFailure({
    super.message = 'Failed to delete data from storage.',
    super.code,
    super.details,
  });
}

/// Clear failure - failed to clear storage
class StorageClearFailure extends StorageFailure {
  const StorageClearFailure({
    super.message = 'Failed to clear storage.',
    super.code,
    super.details,
  });
}

/// Key not found failure - requested key doesn't exist
class StorageKeyNotFoundFailure extends StorageFailure {
  final String key;

  const StorageKeyNotFoundFailure({
    required this.key,
    super.message = 'Key not found in storage.',
    super.code,
    super.details,
  });
}

/// Serialization failure - failed to serialize/deserialize data
class StorageSerializationFailure extends StorageFailure {
  const StorageSerializationFailure({
    super.message = 'Failed to serialize/deserialize data.',
    super.code,
    super.details,
  });
}

/// Type mismatch failure - stored value type doesn't match requested type
class StorageTypeMismatchFailure extends StorageFailure {
  final Type expectedType;
  final Type actualType;

  const StorageTypeMismatchFailure({
    required this.expectedType,
    required this.actualType,
    super.message = 'Storage type mismatch.',
    super.code,
    super.details,
  });
}

/// Encryption failure - failed to encrypt/decrypt data
class StorageEncryptionFailure extends StorageFailure {
  const StorageEncryptionFailure({
    super.message = 'Failed to encrypt/decrypt data.',
    super.code,
    super.details,
  });
}

/// Storage full failure - no space left
class StorageFullFailure extends StorageFailure {
  const StorageFullFailure({
    super.message = 'Storage is full. No space left.',
    super.code,
    super.details,
  });
}

/// Unknown storage failure
class UnknownStorageFailure extends StorageFailure {
  const UnknownStorageFailure({
    super.message = 'An unexpected storage error occurred.',
    super.code,
    super.details,
  });
}


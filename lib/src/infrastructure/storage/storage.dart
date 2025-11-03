/// Storage service for local data persistence.
///
/// This module provides a dependency-independent storage interface
/// with Hive as the default implementation.
///
/// ## Features
/// - Type-safe key-value storage
/// - Encryption support
/// - Reactive watch streams
/// - Batch operations
/// - TTL/expiration support
/// - Lazy loading for large datasets
///
/// ## Quick Start
///
/// ```dart
/// // Register in DI
/// getIt.registerLazySingleton<StorageService>(
///   () => HiveStorageServiceImpl(),
/// );
///
/// // Initialize
/// final storage = getIt<StorageService>();
/// await storage.initialize();
///
/// // Use
/// await storage.save('key', 'value');
/// final value = await storage.get<String>('key');
/// ```
///
/// See [StorageService] for complete API documentation.
library;

// Export constants
export 'constants/constants.dart';

// Export contracts
export 'contract/contracts.dart';

// Export implementations
export 'impl/impl.dart';


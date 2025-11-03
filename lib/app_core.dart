library app_core;

// Errors - Failure classes
export 'src/errors/errors.dart';

// Foundation - Domain Entities
export 'src/foundation/domain/entities/background_service/entities.dart';
export 'src/foundation/domain/entities/network/entities.dart';
export 'src/foundation/domain/entities/notification/entities.dart';

// Infrastructure - Background Service
export 'src/infrastructure/background_service/background_service.dart';

// Infrastructure - Logging
export 'src/infrastructure/logging/logging.dart';

// Infrastructure - Network
export 'src/infrastructure/network/network.dart';

// Infrastructure - Notification
export 'src/infrastructure/notification/notification.dart';

// Infrastructure - Responsive
export 'src/infrastructure/responsive/responsive.dart';

// Infrastructure - Storage
export 'src/infrastructure/storage/storage.dart';

// Configuration - DI
export 'src/configuration/di/locator.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

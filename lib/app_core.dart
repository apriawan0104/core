library app_core;

// Errors - Failure classes
export 'src/errors/errors.dart';

// Foundation - Domain Entities
export 'src/foundation/domain/entities/background_service/entities.dart';
export 'src/foundation/domain/entities/chart/entities.dart';
export 'src/foundation/domain/entities/connectivity/entities.dart';
export 'src/foundation/domain/entities/network/entities.dart';
export 'src/foundation/domain/entities/notification/entities.dart';

// Infrastructure - Analytics
export 'src/infrastructure/analytics/analytics.dart';

// Infrastructure - Authentication
export 'src/infrastructure/authentication/authentication.dart';

// Infrastructure - Background Service
export 'src/infrastructure/background_service/background_service.dart';

// Infrastructure - Chart
export 'src/infrastructure/chart/chart.dart';

// Infrastructure - Connectivity
export 'src/infrastructure/connectivity/connectivity.dart';

// Infrastructure - File Opener
export 'src/infrastructure/file_opener/file_opener.dart';

// Infrastructure - HTTP Inspector
export 'src/infrastructure/http_inspector/http_inspector.dart';

// Infrastructure - In-App Update
export 'src/infrastructure/in_app_update/in_app_update.dart';

// Infrastructure - Logging
export 'src/infrastructure/logging/logging.dart';

// Infrastructure - Network
export 'src/infrastructure/network/network.dart';

// Infrastructure - Notification
export 'src/infrastructure/notification/notification.dart';

// Infrastructure - Path Provider
export 'src/infrastructure/path_provider/path_provider.dart';

// Infrastructure - Responsive
export 'src/infrastructure/responsive/responsive.dart';

// Infrastructure - Secure Storage
export 'src/infrastructure/secure_storage/secure_storage.dart';

// Infrastructure - Storage
export 'src/infrastructure/storage/storage.dart';

// Infrastructure - URL Launcher
export 'src/infrastructure/url_launcher/url_launcher.dart';

// Infrastructure - WebView
export 'src/infrastructure/webview/webview.dart';

// Configuration - DI
export 'src/configuration/di/locator.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

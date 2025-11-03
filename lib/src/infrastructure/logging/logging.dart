/// Logging infrastructure module.
///
/// This module provides a dependency-independent logging service that can be
/// implemented with different logging providers (logger package, console,
/// Sentry, Firebase Crashlytics, etc.).
///
/// ## Features
///
/// - 🎯 Multiple log levels (trace, debug, info, warning, error, fatal)
/// - 📦 Dependency independent design
/// - 🔄 Easy to switch between logging providers
/// - 🧪 Testable with mock implementations
/// - 🎨 Structured logging with metadata support
/// - 📝 Stack trace support for errors
///
/// ## Quick Start
///
/// ### 1. Register in DI Container
///
/// Using logger package (recommended):
/// ```dart
/// import 'package:app_core/app_core.dart';
/// import 'package:logger/logger.dart' as logger_pkg;
///
/// // Register with default config
/// getIt.registerLazySingleton<LogService>(
///   () => LoggerPackageServiceImpl.defaultConfig(),
/// );
///
/// // Or with custom config
/// getIt.registerLazySingleton<LogService>(
///   () => LoggerPackageServiceImpl(
///     logger: logger_pkg.Logger(
///       printer: logger_pkg.PrettyPrinter(
///         methodCount: 2,
///         errorMethodCount: 8,
///         lineLength: 120,
///         colors: true,
///         printEmojis: true,
///       ),
///     ),
///   ),
/// );
/// ```
///
/// Using simple console logging:
/// ```dart
/// getIt.registerLazySingleton<LogService>(
///   () => ConsoleLogServiceImpl(),
/// );
/// ```
///
/// ### 2. Use in Your Code
///
/// ```dart
/// class MyRepository {
///   final LogService _logService;
///
///   MyRepository(this._logService);
///
///   Future<void> fetchData() async {
///     _logService.info('Fetching data from API');
///
///     try {
///       final data = await api.getData();
///       _logService.debug('Data fetched successfully', metadata: {
///         'itemCount': data.length,
///       });
///     } catch (e, st) {
///       _logService.error(
///         'Failed to fetch data',
///         error: e,
///         stackTrace: st,
///         metadata: {'endpoint': '/api/data'},
///       );
///       rethrow;
///     }
///   }
/// }
/// ```
///
/// ## Available Implementations
///
/// ### 1. LoggerPackageServiceImpl (Recommended)
///
/// Beautiful, colorful console logs using the logger package.
///
/// **Pros:**
/// - Pretty formatted output
/// - Colored logs
/// - Emojis for log levels
/// - Configurable formatting
///
/// **Cons:**
/// - Requires logger package dependency
///
/// ### 2. ConsoleLogServiceImpl
///
/// Simple console logging using Flutter's debugPrint.
///
/// **Pros:**
/// - Zero dependencies
/// - Lightweight
/// - Simple and fast
///
/// **Cons:**
/// - No colored output
/// - Limited formatting
/// - Only logs in debug mode by default
///
/// ## Switching Implementations
///
/// To switch from one logging provider to another, simply change the
/// DI registration. No changes needed in business logic!
///
/// ```dart
/// // Before: Using logger package
/// getIt.registerLazySingleton<LogService>(
///   () => LoggerPackageServiceImpl.defaultConfig(),
/// );
///
/// // After: Using console
/// getIt.registerLazySingleton<LogService>(
///   () => ConsoleLogServiceImpl(),
/// );
/// ```
///
/// ## Testing
///
/// Create a mock implementation for testing:
///
/// ```dart
/// class MockLogService implements LogService {
///   final List<String> logs = [];
///
///   @override
///   void error(String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? metadata}) {
///     logs.add('ERROR: $message');
///   }
///
///   // ... implement other methods
/// }
///
/// // In your test
/// test('should log errors', () {
///   final mockLog = MockLogService();
///   final repository = MyRepository(mockLog);
///
///   await repository.fetchData();
///
///   expect(mockLog.logs, contains('ERROR: Failed to fetch data'));
/// });
/// ```
///
/// ## Best Practices
///
/// 1. **Use appropriate log levels**
///    - `trace`: Very detailed debugging
///    - `debug`: General debugging
///    - `info`: Important application events
///    - `warning`: Potentially harmful situations
///    - `error`: Error events (recoverable)
///    - `fatal`: Critical errors (unrecoverable)
///
/// 2. **Include metadata for context**
///    ```dart
///    logService.info('User action', metadata: {
///      'userId': user.id,
///      'action': 'button_click',
///      'screen': 'home',
///    });
///    ```
///
/// 3. **Always include stack traces for errors**
///    ```dart
///    try {
///      // ...
///    } catch (e, st) {
///      logService.error('Operation failed', error: e, stackTrace: st);
///    }
///    ```
///
/// 4. **Don't log sensitive information**
///    - Never log passwords, tokens, or personal data
///    - Sanitize user input before logging
///
/// 5. **Use structured logging**
///    - Prefer metadata over string interpolation
///    - Makes logs easier to search and analyze
///
/// ## See Also
///
/// - [LogService] - The main logging interface
/// - [LoggerPackageServiceImpl] - Logger package implementation
/// - [ConsoleLogServiceImpl] - Console logging implementation
/// - [LogConstants] - Logging constants and configuration
library;

export 'constants/constants.dart';
export 'contract/contracts.dart';
export 'impl/impl.dart';

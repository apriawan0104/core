// ignore_for_file: unused_local_variable

import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

/// Example of using the logging infrastructure with DIP.
///
/// This example demonstrates:
/// 1. Setting up different logging implementations
/// 2. Using logging in business logic
/// 3. Switching between implementations
/// 4. Testing with mock loggers
void main() {
  // Example 1: Setup with logger package (recommended)
  example1SetupWithLoggerPackage();

  // Example 2: Setup with console logging (zero dependencies)
  example2SetupWithConsole();

  // Example 3: Environment-based setup
  example3EnvironmentBasedSetup();

  // Example 4: Using logging in business logic
  example4UsingInBusinessLogic();

  // Example 5: Structured logging with metadata
  example5StructuredLogging();

  // Example 6: Error handling with logging
  example6ErrorHandling();

  // Example 7: Testing with mock logger
  example7TestingWithMock();
}

/// Example 1: Setup with logger package (recommended for development).
void example1SetupWithLoggerPackage() {
  final getIt = GetIt.instance;

  // Option A: Use default configuration
  getIt.registerLazySingleton<LogService>(
    () => LoggerPackageServiceImpl.defaultConfig(),
  );

  // Option B: Use simple configuration (no colors, good for CI/CD)
  // getIt.registerLazySingleton<LogService>(
  //   () => LoggerPackageServiceImpl.simpleConfig(),
  // );

  // Option C: Custom configuration
  // getIt.registerLazySingleton<LogService>(
  //   () => LoggerPackageServiceImpl(
  //     logger: logger_pkg.Logger(
  //       level: logger_pkg.Level.debug,
  //       printer: logger_pkg.PrettyPrinter(
  //         methodCount: 2,
  //         errorMethodCount: 8,
  //         lineLength: 120,
  //         colors: true,
  //         printEmojis: true,
  //         dateTimeFormat: logger_pkg.DateTimeFormat.onlyTimeAndSinceStart,
  //       ),
  //     ),
  //   ),
  // );

  // Option D: With custom log level filter
  // getIt.registerLazySingleton<LogService>(
  //   () => LoggerPackageServiceImpl.withFilter(
  //     level: logger_pkg.Level.warning, // Only show warnings and above
  //   ),
  // );

  // Use the logger
  final logService = getIt<LogService>();
  logService.info('Logger package setup complete');
}

/// Example 2: Setup with simple console logging (zero dependencies).
void example2SetupWithConsole() {
  final getIt = GetIt.instance;

  // Option A: Default (only logs in debug mode)
  getIt.registerLazySingleton<LogService>(
    () => const ConsoleLogServiceImpl(),
  );

  // Option B: Log in production too
  // getIt.registerLazySingleton<LogService>(
  //   () => const ConsoleLogServiceImpl(logInProduction: true),
  // );

  // Option C: Without timestamps
  // getIt.registerLazySingleton<LogService>(
  //   () => const ConsoleLogServiceImpl(includeTimestamp: false),
  // );

  // Use the logger
  final logService = getIt<LogService>();
  logService.info('Console logger setup complete');
}

/// Example 3: Environment-based setup (different loggers for dev/prod).
void example3EnvironmentBasedSetup() {
  final getIt = GetIt.instance;

  const bool isProduction = bool.fromEnvironment('dart.vm.product');

  if (isProduction) {
    // Production: Simple console logging
    getIt.registerLazySingleton<LogService>(
      () => const ConsoleLogServiceImpl(
        logInProduction: true,
        includeTimestamp: true,
      ),
    );
  } else {
    // Development: Pretty logging with logger package
    getIt.registerLazySingleton<LogService>(
      () => LoggerPackageServiceImpl.defaultConfig(),
    );
  }

  final logService = getIt<LogService>();
  logService.info('Environment-based logger setup complete');
}

/// Example 4: Using logging in business logic.
void example4UsingInBusinessLogic() {
  final getIt = GetIt.instance;
  final logService = getIt<LogService>();

  // Different log levels
  logService.trace('This is a trace message - very detailed');
  logService.debug('This is a debug message - for debugging');
  logService.info('This is an info message - important events');
  logService.warning('This is a warning - potentially harmful');

  // Error logging
  try {
    throw Exception('Something went wrong');
  } catch (e, st) {
    logService.error(
      'An error occurred',
      error: e,
      stackTrace: st,
    );
  }

  // Fatal error
  try {
    throw Exception('Critical failure');
  } catch (e, st) {
    logService.fatal(
      'A fatal error occurred',
      error: e,
      stackTrace: st,
    );
  }
}

/// Example 5: Structured logging with metadata.
void example5StructuredLogging() {
  final getIt = GetIt.instance;
  final logService = getIt<LogService>();

  // User action tracking
  logService.info('User logged in', metadata: {
    LogConstants.keyUserId: '12345',
    LogConstants.keyUserEmail: 'user@example.com',
    LogConstants.keyTimestamp: DateTime.now().toIso8601String(),
    'loginMethod': 'email_password',
  });

  // API call logging
  logService.debug('API request started', metadata: {
    LogConstants.keyEndpoint: '/api/users/12345',
    LogConstants.keyMethod: 'GET',
    'requestId': 'req-123',
  });

  // Screen tracking
  logService.info('Screen viewed', metadata: {
    LogConstants.keyScreenName: 'home',
    LogConstants.keyUserId: '12345',
    'previousScreen': 'login',
  });

  // Performance tracking
  logService.info('Operation completed', metadata: {
    LogConstants.keyAction: 'data_sync',
    LogConstants.keyDuration: '1500ms',
    'itemsProcessed': 100,
  });
}

/// Example 6: Error handling with logging.
void example6ErrorHandling() {
  final getIt = GetIt.instance;
  final logService = getIt<LogService>();

  // Simulate API call with error handling
  Future<void> fetchUserData(String userId) async {
    logService.info('Fetching user data', metadata: {
      LogConstants.keyUserId: userId,
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Simulate error
      throw Exception('Network error');
    } catch (e, st) {
      logService.error(
        'Failed to fetch user data',
        error: e,
        stackTrace: st,
        metadata: {
          LogConstants.keyUserId: userId,
          LogConstants.keyEndpoint: '/api/users/$userId',
          LogConstants.keyErrorType: 'NetworkError',
        },
      );
      rethrow;
    }
  }

  // Use the function
  fetchUserData('12345').catchError((e) {
    // Error already logged
  });
}

/// Example 7: Testing with mock logger.
void example7TestingWithMock() {
  // Create mock logger for testing
  final mockLogger = MockLogService();

  // Use in your code
  final repository = UserRepository(mockLogger);

  // Simulate operation
  repository.doSomething();

  // Verify logs
  print('Info logs: ${mockLogger.infoLogs}');
  print('Error logs: ${mockLogger.errorLogs}');

  // Reset for next test
  mockLogger.reset();
}

/// Mock implementation for testing.
class MockLogService implements LogService {
  final List<String> traceLogs = [];
  final List<String> debugLogs = [];
  final List<String> infoLogs = [];
  final List<String> warningLogs = [];
  final List<String> errorLogs = [];
  final List<String> fatalLogs = [];

  @override
  void trace(String message, {Map<String, dynamic>? metadata}) {
    traceLogs.add(message);
    print('TRACE: $message');
  }

  @override
  void debug(String message, {Map<String, dynamic>? metadata}) {
    debugLogs.add(message);
    print('DEBUG: $message');
  }

  @override
  void info(String message, {Map<String, dynamic>? metadata}) {
    infoLogs.add(message);
    print('INFO: $message');
  }

  @override
  void warning(String message, {Map<String, dynamic>? metadata}) {
    warningLogs.add(message);
    print('WARNING: $message');
  }

  @override
  void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    errorLogs.add(message);
    print('ERROR: $message');
    if (error != null) print('  Error: $error');
  }

  @override
  void fatal(
    String message, {
    required dynamic error,
    required StackTrace stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    fatalLogs.add(message);
    print('FATAL: $message');
    print('  Error: $error');
    print('  StackTrace: $stackTrace');
  }

  @override
  void close() {
    print('Mock logger closed');
  }

  void reset() {
    traceLogs.clear();
    debugLogs.clear();
    infoLogs.clear();
    warningLogs.clear();
    errorLogs.clear();
    fatalLogs.clear();
  }
}

/// Example repository that uses logging.
class UserRepository {
  final LogService _logService;

  UserRepository(this._logService);

  void doSomething() {
    _logService.info('Repository operation started');

    try {
      // Do something
      _logService.debug('Processing data');

      // Success
      _logService.info('Operation completed successfully');
    } catch (e, st) {
      _logService.error(
        'Operation failed',
        error: e,
        stackTrace: st,
      );
    }
  }
}


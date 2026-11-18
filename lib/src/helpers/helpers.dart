/// Helper utilities for common operations
///
/// This module provides utility classes and functions that simplify
/// common operations throughout the application.
///
/// ## Available Helpers
///
/// ### Error Handler
///
/// [ErrorHandler] - Unified error handling with automatic crash reporting
///
/// ```dart
/// import 'package:get_it/get_it.dart';
/// 
/// final getIt = GetIt.instance;
///
/// // Setup in DI
/// getIt.registerLazySingleton<ErrorHandler>(
///   () => ErrorHandler(
///     crashReporter: getIt<CrashReporterService>(),
///     logger: getIt<LoggingService>(),
///   ),
/// );
///
/// // Use in your code
/// final user = await errorHandler.handleResult(
///   await authService.getCurrentUser(),
///   reportToCrashlytics: true,
///   context: 'Getting current user',
/// );
/// ```
///
/// ### Repository Error Handler
///
/// [RepositoryErrorHandler] - Centralized error handling for repository layer
///
/// ```dart
/// import 'package:get_it/get_it.dart';
/// 
/// final getIt = GetIt.instance;
///
/// getIt.registerLazySingleton<RepositoryErrorHandler>(
///   () => RepositoryErrorHandler(getIt<CrashReporterService>()),
/// );
///
/// class AuthRepositoryImpl implements AuthRepository {
///   final RepositoryErrorHandler errorHandler;
///
///   @override
///   Future<ValueGuard<void>> signOut() async {
///     return errorHandler.execute(
///       operation: () => dataSource.signOut(),
///       feature: 'authentication',
///       operationName: 'signOut',
///     );
///   }
/// }
/// ```
///
/// ## Design Philosophy
///
/// All helpers follow these principles:
/// - ✅ Pure functions when possible
/// - ✅ No side effects unless explicitly documented
/// - ✅ Null-safe and type-safe
/// - ✅ Well-documented with examples
/// - ✅ Testable and mockable
library;

export 'error_handler.helper.dart';
export 'repository_error_handler.dart';


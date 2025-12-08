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


import 'package:dartz/dartz.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart' as crashlytics;
import 'package:flutter/foundation.dart';

import '../../../errors/analytics_failure.dart';
import '../../../errors/failures.dart';
import '../contract/crash_reporter.service.dart';
import '../models/crash_report.model.dart';

/// Firebase Crashlytics implementation of [CrashReporterService].
///
/// This implementation wraps the Firebase Crashlytics SDK and provides a
/// dependency-independent interface for crash and error reporting.
///
/// ## Setup
///
/// 1. Add Firebase Crashlytics to your pubspec.yaml:
/// ```yaml
/// dependencies:
///   firebase_core: ^3.0.0
///   firebase_crashlytics: ^5.0.4
/// ```
///
/// 2. Initialize Firebase in your app:
/// ```dart
/// await Firebase.initializeApp();
///
/// // Create crash reporter instance
/// final crashReporter = FirebaseCrashlyticsServiceImpl();
///
/// // Initialize crash reporting
/// await crashReporter.initialize();
/// ```
///
/// 3. (Optional) Catch Flutter errors:
/// ```dart
/// FlutterError.onError = (FlutterErrorDetails details) {
///   crashReporter.recordFlutterError(details);
/// };
/// ```
///
/// 4. (Optional) Catch async errors:
/// ```dart
/// PlatformDispatcher.instance.onError = (error, stack) {
///   crashReporter.recordError(
///     exception: error,
///     stackTrace: stack,
///     fatal: true,
///   );
///   return true;
/// };
/// ```
///
/// 5. Register in dependency injection:
/// ```dart
/// getIt.registerLazySingleton<CrashReporterService>(
///   () => FirebaseCrashlyticsServiceImpl(),
/// );
/// ```
///
/// ## Features
///
/// - Automatic crash reporting
/// - Manual error reporting
/// - Custom logging
/// - Custom keys for debugging
/// - User identification
/// - Flutter error integration
/// - Fatal/non-fatal error distinction
///
/// ## Provider-Specific Notes
///
/// - Firebase Crashlytics automatically collects uncaught errors after init
/// - Crash reports are uploaded automatically when app restarts
/// - Reports are deduplicated on Firebase backend
/// - Supports breadcrumb logging (custom keys and logs)
/// - Integrates with Firebase Console for viewing crashes
///
/// ## Switching Providers
///
/// To switch from Firebase Crashlytics to another provider (e.g., Sentry):
/// 1. Create new implementation (e.g., SentryCrashReporterServiceImpl)
/// 2. Update DI registration
/// 3. No changes needed in business logic!
class FirebaseCrashlyticsServiceImpl implements CrashReporterService {
  /// The Firebase Crashlytics instance.
  final crashlytics.FirebaseCrashlytics _crashlytics;

  /// Whether to enable crash collection in debug mode.
  ///
  /// By default, Firebase Crashlytics is disabled in debug mode to avoid
  /// cluttering your crash reports during development.
  final bool enableInDebugMode;

  bool _isInitialized = false;

  FirebaseCrashlyticsServiceImpl({
    crashlytics.FirebaseCrashlytics? firebaseCrashlytics,
    this.enableInDebugMode = false,
  }) : _crashlytics =
            firebaseCrashlytics ?? crashlytics.FirebaseCrashlytics.instance;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) {
        return const Right(null);
      }

      // Enable or disable crash collection based on mode
      if (kDebugMode && !enableInDebugMode) {
        await _crashlytics.setCrashlyticsCollectionEnabled(false);
      } else {
        await _crashlytics.setCrashlyticsCollectionEnabled(true);
      }

      _isInitialized = true;
      return const Right(null);
    } catch (e) {
      return Left(CrashReporterFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> recordError({
    required dynamic exception,
    StackTrace? stackTrace,
    String? reason,
    List<String>? information,
    bool fatal = false,
  }) async {
    try {
      if (!_isInitialized) {
        return Left(CrashReporterFailure.notInitialized());
      }

      final isEnabled = _crashlytics.isCrashlyticsCollectionEnabled;
      if (!isEnabled) {
        return Left(CrashReporterFailure.disabled());
      }

      // Log additional information if provided
      if (information != null && information.isNotEmpty) {
        for (final info in information) {
          await _crashlytics.log(info);
        }
      }

      // Record the error
      await _crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
        information: information ?? [],
      );

      return const Right(null);
    } catch (e) {
      return Left(CrashReporterFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) async {
    try {
      if (!_isInitialized) {
        return Left(CrashReporterFailure.notInitialized());
      }

      final isEnabled = _crashlytics.isCrashlyticsCollectionEnabled;
      if (!isEnabled) {
        return Left(CrashReporterFailure.disabled());
      }

      await _crashlytics.recordFlutterError(
        details,
        fatal: fatal,
      );

      return const Right(null);
    } catch (e) {
      return Left(CrashReporterFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> recordCrash(CrashReport report) async {
    try {
      if (!_isInitialized) {
        return Left(CrashReporterFailure.notInitialized());
      }

      final isEnabled = _crashlytics.isCrashlyticsCollectionEnabled;
      if (!isEnabled) {
        return Left(CrashReporterFailure.disabled());
      }

      // Set custom keys from report
      if (report.customData != null) {
        for (final entry in report.customData!.entries) {
          await setCustomKey(entry.key, entry.value);
        }
      }

      // Log any provided logs
      if (report.logs != null && report.logs!.isNotEmpty) {
        for (final logMessage in report.logs!) {
          await log(logMessage);
        }
      }

      // Record the error
      await _crashlytics.recordError(
        report.exception,
        report.stackTrace,
        reason: report.message,
        fatal: report.fatal,
      );

      return const Right(null);
    } catch (e) {
      return Left(CrashReporterFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> log(String message) async {
    try {
      if (!_isInitialized) {
        return Left(CrashReporterFailure.notInitialized());
      }

      await _crashlytics.log(message);

      return const Right(null);
    } catch (e) {
      return Left(CrashReporterFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> setCustomKey(String key, dynamic value) async {
    try {
      if (!_isInitialized) {
        return Left(CrashReporterFailure.notInitialized());
      }

      if (key.isEmpty) {
        return Left(CrashReporterFailure.invalidReport('Key cannot be empty'));
      }

      // Firebase Crashlytics supports different types
      if (value is String) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is int) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is double) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is bool) {
        await _crashlytics.setCustomKey(key, value);
      } else {
        // Convert other types to string
        await _crashlytics.setCustomKey(key, value.toString());
      }

      return const Right(null);
    } catch (e) {
      return Left(CrashReporterFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> setCustomKeys(
      Map<String, dynamic> customKeys) async {
    try {
      if (!_isInitialized) {
        return Left(CrashReporterFailure.notInitialized());
      }

      for (final entry in customKeys.entries) {
        final result = await setCustomKey(entry.key, entry.value);
        if (result.isLeft()) {
          return result;
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(CrashReporterFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> setUserIdentifier(String identifier) async {
    try {
      if (!_isInitialized) {
        return Left(CrashReporterFailure.notInitialized());
      }

      await _crashlytics.setUserIdentifier(identifier);

      return const Right(null);
    } catch (e) {
      return Left(CrashReporterFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> setUserEmail(String email) async {
    try {
      if (!_isInitialized) {
        return Left(CrashReporterFailure.notInitialized());
      }

      // Firebase Crashlytics doesn't have a specific setUserEmail method
      // We use a custom key instead
      await _crashlytics.setCustomKey('user_email', email);

      return const Right(null);
    } catch (e) {
      return Left(CrashReporterFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> setUserName(String name) async {
    try {
      if (!_isInitialized) {
        return Left(CrashReporterFailure.notInitialized());
      }

      // Firebase Crashlytics doesn't have a specific setUserName method
      // We use a custom key instead
      await _crashlytics.setCustomKey('user_name', name);

      return const Right(null);
    } catch (e) {
      return Left(CrashReporterFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> setCrashCollectionEnabled(bool enabled) async {
    try {
      if (!_isInitialized) {
        return Left(CrashReporterFailure.notInitialized());
      }

      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);

      return const Right(null);
    } catch (e) {
      return Left(CrashReporterFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isCrashCollectionEnabled() async {
    try {
      if (!_isInitialized) {
        return Left(CrashReporterFailure.notInitialized());
      }

      final enabled = _crashlytics.isCrashlyticsCollectionEnabled;
      return Right(enabled);
    } catch (e) {
      return Left(CrashReporterFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> sendUnsentReports() async {
    try {
      if (!_isInitialized) {
        return Left(CrashReporterFailure.notInitialized());
      }

      await _crashlytics.sendUnsentReports();

      return const Right(null);
    } catch (e) {
      return Left(CrashReporterFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUnsentReports() async {
    try {
      if (!_isInitialized) {
        return Left(CrashReporterFailure.notInitialized());
      }

      await _crashlytics.deleteUnsentReports();

      return const Right(null);
    } catch (e) {
      return Left(CrashReporterFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> hasUnsentReports() async {
    try {
      if (!_isInitialized) {
        return Left(CrashReporterFailure.notInitialized());
      }

      final hasUnsent = await _crashlytics.checkForUnsentReports();
      return Right(hasUnsent);
    } catch (e) {
      return Left(CrashReporterFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      if (!_isInitialized) {
        return const Right(null);
      }

      // Firebase Crashlytics doesn't have a dispose method
      // Just mark as not initialized
      _isInitialized = false;

      return const Right(null);
    } catch (e) {
      return Left(CrashReporterFailure.fromException(e));
    }
  }
}

import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../errors/errors.dart';
import '../contract/contracts.dart';
import '../models/models.dart';

/// Chucker implementation of HTTP Inspector Service
///
/// This implementation uses the chucker_flutter package to provide
/// HTTP request/response inspection capabilities.
///
/// ## Features:
/// - Works with Dio, http, and Chopper
/// - Shows in-app notifications
/// - Stores data locally
/// - Provides UI for inspecting and sharing
/// - Supports all platforms (Android, iOS, Web, Windows, macOS, Linux)
///
/// ## Note:
/// For Android, minSdkVersion must be at least 22
///
/// Example:
/// ```dart
/// final inspector = ChuckerHttpInspectorServiceImpl();
/// await inspector.initialize(HttpInspectorConfig());
///
/// // For Dio
/// dio.interceptors.add(inspector.getDioInterceptor().getOrElse(() => null));
///
/// // For http
/// final client = inspector.getHttpClient(http.Client()).getOrElse(() => null);
///
/// // For MaterialApp
/// MaterialApp(
///   navigatorObservers: [inspector.getNavigatorObserver()],
/// );
/// ```
class ChuckerHttpInspectorServiceImpl implements HttpInspectorService {
  HttpInspectorConfig? _config;
  bool _isInitialized = false;
  bool _isEnabled = true;

  @override
  Future<Either<Failure, void>> initialize(HttpInspectorConfig config) async {
    try {
      if (_isInitialized) {
        return left(
          const HttpInspectorFailure(
            'HTTP Inspector is already initialized',
          ),
        );
      }

      _config = config;

      // Set Chucker to show on release if configured
      ChuckerFlutter.showOnRelease = config.showOnRelease;

      _isInitialized = true;
      _isEnabled = true;

      return right(null);
    } catch (e, stackTrace) {
      return left(
        HttpInspectorFailure(
          'Failed to initialize HTTP Inspector: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Either<Failure, dynamic> getDioInterceptor() {
    try {
      if (!_isInitialized) {
        return left(
          const HttpInspectorFailure(
            'HTTP Inspector not initialized. Call initialize() first.',
          ),
        );
      }

      if (!_isEnabled) {
        return left(
          const HttpInspectorFailure(
            'HTTP Inspector is disabled',
          ),
        );
      }

      // Return Chucker Dio interceptor
      return right(ChuckerDioInterceptor());
    } catch (e, stackTrace) {
      return left(
        HttpInspectorFailure(
          'Failed to get Dio interceptor: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Either<Failure, dynamic> getHttpClient(dynamic baseClient) {
    try {
      if (!_isInitialized) {
        return left(
          const HttpInspectorFailure(
            'HTTP Inspector not initialized. Call initialize() first.',
          ),
        );
      }

      if (!_isEnabled) {
        return left(
          const HttpInspectorFailure(
            'HTTP Inspector is disabled',
          ),
        );
      }

      if (baseClient == null) {
        return left(
          const HttpInspectorFailure(
            'Base HTTP client cannot be null',
          ),
        );
      }

      // Return Chucker HTTP client wrapper
      return right(ChuckerHttpClient(baseClient));
    } catch (e, stackTrace) {
      return left(
        HttpInspectorFailure(
          'Failed to get HTTP client: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Either<Failure, dynamic> getChopperInterceptor() {
    try {
      if (!_isInitialized) {
        return left(
          const HttpInspectorFailure(
            'HTTP Inspector not initialized. Call initialize() first.',
          ),
        );
      }

      if (!_isEnabled) {
        return left(
          const HttpInspectorFailure(
            'HTTP Inspector is disabled',
          ),
        );
      }

      // Return Chucker Chopper interceptor
      return right(ChuckerChopperInterceptor());
    } catch (e, stackTrace) {
      return left(
        HttpInspectorFailure(
          'Failed to get Chopper interceptor: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  NavigatorObserver getNavigatorObserver() {
    // Chucker navigator observer works even if not initialized
    return ChuckerFlutter.navigatorObserver;
  }

  @override
  Future<Either<Failure, void>> updateConfig(
    HttpInspectorConfig config,
  ) async {
    try {
      if (!_isInitialized) {
        return left(
          const HttpInspectorFailure(
            'HTTP Inspector not initialized. Call initialize() first.',
          ),
        );
      }

      _config = config;

      // Update Chucker settings
      ChuckerFlutter.showOnRelease = config.showOnRelease;

      return right(null);
    } catch (e, stackTrace) {
      return left(
        HttpInspectorFailure(
          'Failed to update config: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Either<Failure, HttpInspectorConfig> getConfig() {
    try {
      if (!_isInitialized || _config == null) {
        return left(
          const HttpInspectorFailure(
            'HTTP Inspector not initialized. Call initialize() first.',
          ),
        );
      }

      return right(_config!);
    } catch (e, stackTrace) {
      return left(
        HttpInspectorFailure(
          'Failed to get config: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearData() async {
    try {
      if (!_isInitialized) {
        return left(
          const HttpInspectorFailure(
            'HTTP Inspector not initialized. Call initialize() first.',
          ),
        );
      }

      // Note: Chucker Flutter doesn't expose a public API to clear data
      // This would need to be implemented by accessing the underlying storage
      // or by the consumer app through Chucker's UI
      if (kDebugMode) {
        print('Clear data: Please use Chucker UI to clear data');
      }

      return right(null);
    } catch (e, stackTrace) {
      return left(
        HttpInspectorFailure(
          'Failed to clear data: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  bool isEnabled() {
    return _isInitialized && _isEnabled;
  }

  @override
  Future<Either<Failure, void>> setEnabled(bool enabled) async {
    try {
      if (!_isInitialized) {
        return left(
          const HttpInspectorFailure(
            'HTTP Inspector not initialized. Call initialize() first.',
          ),
        );
      }

      _isEnabled = enabled;

      return right(null);
    } catch (e, stackTrace) {
      return left(
        HttpInspectorFailure(
          'Failed to set enabled state: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> showInspectorUI(BuildContext context) async {
    try {
      if (!_isInitialized) {
        return left(
          const HttpInspectorFailure(
            'HTTP Inspector not initialized. Call initialize() first.',
          ),
        );
      }

      if (!_isEnabled) {
        return left(
          const HttpInspectorFailure(
            'HTTP Inspector is disabled',
          ),
        );
      }

      // Navigate to Chucker screen
      // Note: Chucker automatically navigates when notification is tapped
      // Manual navigation would require access to Chucker's internal routes
      if (kDebugMode) {
        print(
          'Show Inspector UI: Tap on notification or implement custom navigation',
        );
      }

      return right(null);
    } catch (e, stackTrace) {
      return left(
        HttpInspectorFailure(
          'Failed to show inspector UI: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      _isInitialized = false;
      _isEnabled = false;
      _config = null;

      return right(null);
    } catch (e, stackTrace) {
      return left(
        HttpInspectorFailure(
          'Failed to dispose: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

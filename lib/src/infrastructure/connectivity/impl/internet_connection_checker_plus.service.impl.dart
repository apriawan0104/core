import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../errors/errors.dart';
import '../../../foundation/domain/entities/connectivity/entities.dart';
import '../constants/constants.dart';
import '../contract/contracts.dart';

/// Implementation of ConnectivityService using internet_connection_checker_plus package
///
/// This implementation uses the internet_connection_checker_plus package which provides
/// real internet connectivity checking by pinging actual endpoints, not just checking
/// if Wi-Fi or mobile data is connected.
///
/// **Dependency**: This class depends on internet_connection_checker_plus package.
/// To switch to a different connectivity provider (e.g., custom implementation,
/// connectivity_plus with custom logic), create a new implementation of ConnectivityService.
///
/// Features:
/// - Subsecond response times even on mobile networks
/// - Real internet connectivity checking (not just Wi-Fi connection)
/// - Customizable check endpoints
/// - Configurable check intervals
/// - Lifecycle management (pause/resume)
/// - Cross-platform support
///
/// Example usage:
/// ```dart
/// // In DI setup
/// getIt.registerLazySingleton<ConnectivityService>(
///   () => InternetConnectionCheckerPlusServiceImpl(),
/// );
///
/// // In app
/// final connectivity = getIt<ConnectivityService>();
/// await connectivity.initialize();
///
/// connectivity.onConnectivityChanged.listen((status) {
///   print('Connectivity: ${status.message}');
/// });
/// ```
class InternetConnectionCheckerPlusServiceImpl implements ConnectivityService {
  InternetConnection? _internetConnection;
  StreamSubscription<InternetStatus>? _statusSubscription;
  final StreamController<ConnectivityStatusEntity> _statusController =
      StreamController<ConnectivityStatusEntity>.broadcast();

  ConnectivityStatusEntity? _currentStatus;
  bool _isInitialized = false;
  bool _isPaused = false;
  Duration _checkInterval = ConnectivityConstants.defaultCheckInterval;
  List<ConnectivityCheckOptionEntity>? _checkOptions;

  @override
  Future<Either<ConnectivityFailure, void>> initialize({
    Duration? checkInterval,
    List<ConnectivityCheckOptionEntity>? checkOptions,
  }) async {
    try {
      if (_isInitialized) {
        return const Right(null);
      }

      _checkInterval = checkInterval ?? ConnectivityConstants.defaultCheckInterval;
      _checkOptions = checkOptions;

      // Validate check interval
      if (_checkInterval < ConnectivityConstants.minCheckInterval) {
        return Left(
          ConnectivityFailure(
            message:
                'Check interval must be at least ${ConnectivityConstants.minCheckInterval.inSeconds} seconds',
            code: 'INVALID_CHECK_INTERVAL',
          ),
        );
      }

      // Create InternetConnection instance
      if (checkOptions != null && checkOptions.isNotEmpty) {
        // Custom check options
        final addresses = checkOptions.map((option) {
          return InternetCheckOption(
            uri: option.uri,
            timeout: option.timeout,
            headers: option.headers ?? {},
            responseStatusFn: option.responseStatusFn != null
                ? (response) {
                    return option.responseStatusFn!(
                      response.statusCode,
                      response.headers,
                      response.body,
                    );
                  }
                : null,
          );
        }).toList();

        _internetConnection = InternetConnection.createInstance(
          checkInterval: _checkInterval,
          customCheckOptions: addresses,
        );
      } else {
        // Use default check options
        _internetConnection = InternetConnection.createInstance(
          checkInterval: _checkInterval,
        );
      }

      // Perform initial connectivity check
      final hasConnection = await _internetConnection!.hasInternetAccess;
      _currentStatus = hasConnection
          ? ConnectivityStatusEntity.connected
          : ConnectivityStatusEntity.disconnected;

      // Listen to connectivity changes
      _statusSubscription = _internetConnection!.onStatusChange.listen(
        _handleStatusChange,
        onError: (error) {
          _statusController.addError(
            ConnectivityListenerFailure(
              message: 'Connectivity listener error: $error',
              details: {'error': error.toString()},
            ),
          );
        },
      );

      _isInitialized = true;

      // Emit initial status
      _statusController.add(_currentStatus!);

      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        ConnectivityFailure(
          message: 'Failed to initialize connectivity service: $e',
          code: 'INITIALIZATION_FAILED',
          details: {
            'error': e.toString(),
            'stackTrace': stackTrace.toString(),
          },
        ),
      );
    }
  }

  @override
  Future<Either<ConnectivityFailure, bool>> hasInternetConnection() async {
    try {
      if (!_isInitialized) {
        return const Left(
          ConnectivityFailure(
            message:
                'ConnectivityService not initialized. Call initialize() first.',
            code: 'NOT_INITIALIZED',
          ),
        );
      }

      final hasConnection = await _internetConnection!.hasInternetAccess;
      
      // Update current status
      _currentStatus = hasConnection
          ? ConnectivityStatusEntity.connected
          : ConnectivityStatusEntity.disconnected;

      return Right(hasConnection);
    } catch (e, stackTrace) {
      return Left(
        InternetCheckFailure(
          message: 'Failed to check internet connection: $e',
          code: 'CHECK_FAILED',
          details: {
            'error': e.toString(),
            'stackTrace': stackTrace.toString(),
          },
        ),
      );
    }
  }

  @override
  Stream<ConnectivityStatusEntity> get onConnectivityChanged {
    return _statusController.stream;
  }

  @override
  ConnectivityStatusEntity? get currentStatus => _currentStatus;

  @override
  bool? get isConnected => _currentStatus?.isConnected;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isPaused => _isPaused;

  @override
  void pause() {
    if (!_isInitialized || _isPaused) return;

    _statusSubscription?.pause();
    _isPaused = true;
  }

  @override
  void resume() {
    if (!_isInitialized || !_isPaused) return;

    _statusSubscription?.resume();
    _isPaused = false;

    // Perform immediate check when resumed
    hasInternetConnection();
  }

  @override
  void updateCheckInterval(Duration interval) {
    if (!_isInitialized) return;

    if (interval < ConnectivityConstants.minCheckInterval) {
      throw ArgumentError(
        'Check interval must be at least ${ConnectivityConstants.minCheckInterval.inSeconds} seconds',
      );
    }

    _checkInterval = interval;

    // Recreate InternetConnection with new interval
    _recreateInternetConnection();
  }

  @override
  void updateCheckOptions(List<ConnectivityCheckOptionEntity> options) {
    if (!_isInitialized) return;

    _checkOptions = options;

    // Recreate InternetConnection with new options
    _recreateInternetConnection();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _statusController.close();
    _internetConnection = null;
    _isInitialized = false;
    _isPaused = false;
    _currentStatus = null;
  }

  /// Handle status changes from InternetConnection
  void _handleStatusChange(InternetStatus status) {
    final newStatus = status == InternetStatus.connected
        ? ConnectivityStatusEntity.connected
        : ConnectivityStatusEntity.disconnected;

    // Only emit if status actually changed
    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);
    }
  }

  /// Recreate InternetConnection instance with current settings
  void _recreateInternetConnection() {
    // Cancel existing subscription
    _statusSubscription?.cancel();

    // Create new instance
    if (_checkOptions != null && _checkOptions!.isNotEmpty) {
      final addresses = _checkOptions!.map((option) {
        return InternetCheckOption(
          uri: option.uri,
          timeout: option.timeout,
          headers: option.headers ?? {},
          responseStatusFn: option.responseStatusFn != null
              ? (response) {
                  return option.responseStatusFn!(
                    response.statusCode,
                    response.headers,
                    response.body,
                  );
                }
              : null,
        );
      }).toList();

      _internetConnection = InternetConnection.createInstance(
        checkInterval: _checkInterval,
        customCheckOptions: addresses,
      );
    } else {
      _internetConnection = InternetConnection.createInstance(
        checkInterval: _checkInterval,
      );
    }

    // Re-subscribe to status changes
    _statusSubscription = _internetConnection!.onStatusChange.listen(
      _handleStatusChange,
      onError: (error) {
        _statusController.addError(
          ConnectivityListenerFailure(
            message: 'Connectivity listener error: $error',
            details: {'error': error.toString()},
          ),
        );
      },
    );
  }
}


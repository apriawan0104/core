import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_background_service/flutter_background_service.dart'
    as fbs;

import '../../../errors/errors.dart';
import '../../../foundation/domain/entities/background_service/entities.dart';
import '../constants/constants.dart';
import '../contract/contracts.dart';

/// Implementation of [ServiceInstance] using flutter_background_service
class FlutterBackgroundServiceInstanceImpl implements ServiceInstance {
  final fbs.ServiceInstance _instance;

  FlutterBackgroundServiceInstanceImpl(this._instance);

  @override
  Stream<BackgroundServiceData?> on(String method) {
    return _instance.on(method).map((event) {
      if (event == null) return null;

      return BackgroundServiceData(
        method: method,
        payload: event,
      );
    });
  }

  @override
  Future<void> invoke(
    String method, [
    Map<String, dynamic>? payload,
  ]) async {
    _instance.invoke(method, payload);
  }

  @override
  Future<void> stopSelf() async {
    return _instance.stopSelf();
  }

  @override
  Future<bool> isForegroundService() async {
    final instance = _instance;
    if (instance is fbs.AndroidServiceInstance) {
      return instance.isForegroundService();
    }
    return false;
  }

  @override
  Future<void> setAsForegroundService() async {
    final instance = _instance;
    if (instance is fbs.AndroidServiceInstance) {
      await instance.setAsForegroundService();
    }
  }

  @override
  Future<void> setAsBackgroundService() async {
    final instance = _instance;
    if (instance is fbs.AndroidServiceInstance) {
      await instance.setAsBackgroundService();
    }
  }
}

/// Implementation of [BackgroundService] using flutter_background_service package
///
/// This implementation wraps the flutter_background_service package to provide
/// a clean, dependency-independent interface.
class FlutterBackgroundServiceImpl implements BackgroundService {
  final fbs.FlutterBackgroundService _service;

  FlutterBackgroundServiceImpl(this._service);

  /// Factory constructor with default instance
  factory FlutterBackgroundServiceImpl.instance() {
    return FlutterBackgroundServiceImpl(fbs.FlutterBackgroundService());
  }

  @override
  Future<Either<Failure, void>> configure({
    required BackgroundServiceConfig config,
    required ServiceStartCallback onStart,
    IosBackgroundCallback? iosBackgroundCallback,
  }) async {
    try {
      await _service.configure(
        androidConfiguration: fbs.AndroidConfiguration(
          onStart: (fbs.ServiceInstance instance) async {
            final wrappedInstance = FlutterBackgroundServiceInstanceImpl(
              instance,
            );
            await onStart(wrappedInstance);
          },
          autoStart: config.autoStart,
          autoStartOnBoot: config.autoStartOnBoot,
          isForegroundMode: config.isForegroundMode,
          notificationChannelId: config.notificationChannelId ??
              BackgroundServiceConstants.defaultNotificationChannelId,
          initialNotificationTitle: config.initialNotificationTitle ??
              BackgroundServiceConstants.defaultNotificationTitle,
          initialNotificationContent: config.initialNotificationContent ??
              BackgroundServiceConstants.defaultNotificationContent,
          foregroundServiceNotificationId:
              config.foregroundServiceNotificationId ??
                  BackgroundServiceConstants.defaultNotificationId,
        ),
        iosConfiguration: fbs.IosConfiguration(
          autoStart: config.autoStart,
          onForeground: (fbs.ServiceInstance instance) async {
            final wrappedInstance = FlutterBackgroundServiceInstanceImpl(
              instance,
            );
            await onStart(wrappedInstance);
          },
          onBackground: iosBackgroundCallback != null
              ? (fbs.ServiceInstance instance) async {
                  final wrappedInstance = FlutterBackgroundServiceInstanceImpl(
                    instance,
                  );
                  return await iosBackgroundCallback(wrappedInstance);
                }
              : null,
        ),
      );

      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        BackgroundServiceConfigurationFailure(
          message: 'Failed to configure background service: ${e.toString()}',
          details: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> start() async {
    try {
      final isRunning = await _service.isRunning();
      if (!isRunning) {
        await _service.startService();
      }
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        BackgroundServiceStartFailure(
          message: 'Failed to start background service: ${e.toString()}',
          details: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isRunning() async {
    try {
      final isRunning = await _service.isRunning();
      return Right(isRunning);
    } catch (e, stackTrace) {
      return Left(
        BackgroundServiceStatusFailure(
          message: 'Failed to check service status: ${e.toString()}',
          details: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> invoke(
    String method, [
    Map<String, dynamic>? payload,
  ]) async {
    try {
      _service.invoke(method, payload);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        BackgroundServiceInvokeFailure(
          message: 'Failed to invoke method: ${e.toString()}',
          details: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
        ),
      );
    }
  }

  @override
  Stream<BackgroundServiceData?> on(String method) {
    return _service.on(method).map((event) {
      if (event == null) return null;

      return BackgroundServiceData(
        method: method,
        payload: event,
      );
    });
  }
}

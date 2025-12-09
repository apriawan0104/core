// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:app_core/src/configuration/di/register_module.dart' as _i514;
import 'package:app_core/src/infrastructure/background_service/background_service.dart'
    as _i567;
import 'package:app_core/src/infrastructure/notification/contract/notification.dart'
    as _i386;
import 'package:app_core/src/infrastructure/notification/impl/firebase_messaging.service.impl.dart'
    as _i1038;
import 'package:app_core/src/infrastructure/notification/impl/local_notification.service.impl.dart'
    as _i835;
import 'package:app_core/src/infrastructure/responsive/contract/contracts.dart'
    as _i297;
import 'package:app_core/src/infrastructure/responsive/impl/responsive.service.impl.dart'
    as _i969;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i892.FirebaseMessaging>(
        () => registerModule.firebaseMessaging);
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
        () => registerModule.flutterLocalNotificationsPlugin);
    gh.lazySingleton<_i567.BackgroundService>(
        () => registerModule.backgroundService);
    gh.lazySingleton<_i297.ResponsiveService>(
        () => _i969.ResponsiveServiceImpl());
    gh.lazySingleton<_i386.LocalNotificationService>(() =>
        _i835.LocalNotificationServiceImpl(
            localNotifications: gh<_i163.FlutterLocalNotificationsPlugin>()));
    gh.lazySingleton<_i386.FirebaseMessagingService>(() =>
        _i1038.FirebaseMessagingServiceImpl(
            firebaseMessaging: gh<_i892.FirebaseMessaging>()));
    return this;
  }
}

class _$RegisterModule extends _i514.RegisterModule {}

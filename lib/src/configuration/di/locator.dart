import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'locator.config.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies registered with @injectable annotations
///
/// This will automatically register all services annotated with:
/// - @LazySingleton
/// - @Singleton
/// - @Injectable
/// etc.
///
/// Example:
/// ```dart
/// void main() {
///   configureDependencies();
///   runApp(MyApp());
/// }
/// ```
@InjectableInit(initializerName: 'initBumaCore')
void configureDependencies() => getIt.initBumaCore();

/// Micro package initialization for external DI registration
///
/// Injectable will auto-generate BumaCorePlusPackageModule class.
/// This is the SIMPLE & RECOMMENDED way! ⭐
///
/// Usage in consumer app:
/// ```dart
/// @InjectableInit(
///   externalPackageModulesBefore: [
///     ExternalModule(BumaCorePlusPackageModule),
///   ],
/// )
/// Future<void> configureDependencies() async => getIt.init();
/// ```
@microPackageInit
void initMicroPackage() {}

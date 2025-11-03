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
@InjectableInit()
void configureDependencies() => getIt.init();

# Dependency registration

> Contoh ini memakai `getIt`, yaitu locator milik app. `app_core` tidak mengekspornya. Deklarasikan di app dengan `final getIt = GetIt.instance;` dari `package:get_it`.

`app_core` does not generate a dependency graph. There is no `configureDependencies()`, no `@InjectableInit`, and no `build_runner` step.

The app registers each implementation on `getIt`:

```dart
import 'package:app_core/app_core.dart';

void main() {
  getIt.registerLazySingleton<FirebaseMessagingService>(
    () => FirebaseMessagingServiceImpl(),
  );
  getIt.registerLazySingleton<LocalNotificationService>(
    () => LocalNotificationServiceImpl(),
  );
  runApp(const MyApp());
}
```

Replacing a provider means registering a different implementation. The contract stays the same.

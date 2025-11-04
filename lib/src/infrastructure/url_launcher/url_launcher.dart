/// URL Launcher Service
/// 
/// Generic, dependency-independent service for launching URLs, emails,
/// phone calls, SMS, and more.
/// 
/// This service wraps third-party packages to provide a stable interface
/// that won't change even if you switch implementations.
/// 
/// ## Features
/// - Launch web URLs (http/https)
/// - Compose and send emails
/// - Make phone calls
/// - Send SMS messages
/// - Multiple launch modes (in-app, external, etc.)
/// - Cross-platform support
/// - Proper error handling with Either monad
/// - Easy to test and mock
/// 
/// ## Quick Start
/// 
/// ```dart
/// // 1. Register service
/// getIt.registerLazySingleton<UrlLauncherService>(
///   () => UrlLauncherServiceImpl(),
/// );
/// 
/// // 2. Use service
/// final result = await urlLauncher.launchWebUrl(
///   'https://flutter.dev',
///   config: UrlLaunchConfig.externalBrowser,
/// );
/// 
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (_) => print('Success'),
/// );
/// ```
/// 
/// ## Documentation
/// - [README.md](doc/README.md) - Complete documentation
/// - [QUICK_START.md](doc/QUICK_START.md) - Quick start guide
/// 
/// ## Architecture
/// This service follows the Dependency Independence principle.
/// You can easily switch from url_launcher to custom_tabs or any other
/// implementation by just changing the DI registration.
library url_launcher;

// Contracts (interfaces) - Always stable
export 'contract/contracts.dart';

// Models - Our own types, never expose third-party types
export 'models/models.dart';

// Constants
export 'constants/constants.dart';

// Implementations - Import specific implementation as needed
export 'impl/impl.dart';


/// Path Provider Service
///
/// Platform-independent access to commonly used directories on the filesystem.
///
/// This service provides access to:
/// - Temporary directory
/// - Application documents directory
/// - Application support directory
/// - Application cache directory
/// - Downloads directory
/// - Application library directory (iOS/macOS)
/// - External storage directories (Android)
///
/// ### Quick Start
///
/// 1. Register the service in your DI container:
/// ```dart
/// getIt.registerLazySingleton<PathProviderService>(
///   () => PathProviderServiceImpl(),
/// );
/// ```
///
/// 2. Use the service:
/// ```dart
/// final pathProvider = getIt<PathProviderService>();
///
/// final result = await pathProvider.getApplicationDocumentsDirectory();
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (directory) => print('Docs dir: ${directory.path}'),
/// );
/// ```
///
/// ### Platform Support
///
/// | Directory                 | Android | iOS | Linux | macOS | Windows |
/// |---------------------------|---------|-----|-------|-------|---------|
/// | Temporary                 | ✔️      | ✔️  | ✔️    | ✔️    | ✔️      |
/// | Application Support       | ✔️      | ✔️  | ✔️    | ✔️    | ✔️      |
/// | Application Documents     | ✔️      | ✔️  | ✔️    | ✔️    | ✔️      |
/// | Application Cache         | ✔️      | ✔️  | ✔️    | ✔️    | ✔️      |
/// | Application Library       | ❌️      | ✔️  | ❌️    | ✔️    | ❌️      |
/// | Downloads                 | ✔️      | ✔️  | ✔️    | ✔️    | ✔️      |
/// | External Storage          | ✔️      | ❌   | ❌     | ❌️    | ❌️      |
/// | External Cache            | ✔️      | ❌   | ❌     | ❌️    | ❌️      |
/// | External Storage Dirs     | ✔️      | ❌   | ❌     | ❌️    | ❌️      |
///
/// For more information, see:
/// - [Quick Start Guide](doc/QUICK_START.md)
/// - [Full Documentation](doc/README.md)
library path_provider;

export 'constants/constants.dart';
export 'contract/contracts.dart';
export 'impl/impl.dart';


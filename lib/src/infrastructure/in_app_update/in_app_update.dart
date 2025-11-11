/// In-App Update Service for BUMA Core
///
/// This module provides a dependency-independent abstraction for managing
/// in-app updates on Android via Google Play's In-App Update API.
///
/// ## Features
///
/// - ✅ Immediate updates (full-screen, blocking)
/// - ✅ Flexible updates (background download)
/// - ✅ Priority-based update flows
/// - ✅ Real-time installation status
/// - ✅ Dependency-independent design
/// - ✅ Easy to test with mocks
///
/// ## Platform Support
///
/// - ✅ **Android**: Fully supported via Google Play
/// - ❌ **iOS**: Not supported (use alternative solutions)
///
/// ## Quick Start
///
/// ```dart
/// // 1. Register service
/// getIt.registerLazySingleton<InAppUpdateService>(
///   () => AndroidInAppUpdateServiceImpl(),
/// );
///
/// // 2. Initialize
/// final updateService = getIt<InAppUpdateService>();
/// await updateService.initialize();
///
/// // 3. Check for updates
/// final result = await updateService.checkForUpdate();
/// result.fold(
///   (failure) => print('Error: $failure'),
///   (info) {
///     if (info.isUpdateAvailable) {
///       if (info.shouldBeImmediate) {
///         await updateService.performImmediateUpdate();
///       } else {
///         await updateService.startFlexibleUpdate();
///       }
///     }
///   },
/// );
/// ```
///
/// ## Documentation
///
/// - Full documentation: [README.md](doc/README.md)
/// - Quick reference: [QUICK_START.md](doc/QUICK_START.md)
///
/// ## Important Notes
///
/// **Testing Requirements:**
/// - In-app updates CANNOT be tested locally
/// - App must be uploaded to Play Console (Internal Test track is fine)
/// - App must be installed via Google Play Store
/// - Must have a higher version code available
///
/// See documentation for detailed testing guide.
library in_app_update;

// Contracts
export 'contract/contracts.dart';

// Models
export 'models/models.dart';

// Constants
export 'constants/constants.dart';

// Implementations
export 'impl/impl.dart';


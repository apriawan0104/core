/// Connectivity Infrastructure Module
///
/// This module provides real internet connectivity checking functionality,
/// not just Wi-Fi or mobile data connection status.
///
/// **Why This Matters:**
/// Many apps mistakenly use packages that only check if the device is connected
/// to Wi-Fi or mobile network, but don't verify if there's actual internet access.
/// This can lead to false positives where the app thinks it's online but can't
/// actually reach the internet (e.g., connected to Wi-Fi with no internet).
///
/// This module solves that by performing real connectivity checks by attempting
/// to reach actual endpoints on the internet.
///
/// **Dependency Independence:**
/// This module provides an abstract ConnectivityService interface that is
/// independent of any specific connectivity checking package. The default
/// implementation uses internet_connection_checker_plus, but you can easily
/// create implementations for other packages or custom logic.
///
/// ## Quick Start
///
/// ### 1. Initialize the service
/// ```dart
/// final connectivity = getIt<ConnectivityService>();
/// await connectivity.initialize();
/// ```
///
/// ### 2. One-time connectivity check
/// ```dart
/// final result = await connectivity.hasInternetConnection();
/// result.fold(
///   (failure) => print('Check failed: ${failure.message}'),
///   (isConnected) => print('Connected: $isConnected'),
/// );
/// ```
///
/// ### 3. Listen to connectivity changes
/// ```dart
/// connectivity.onConnectivityChanged.listen((status) {
///   if (status == ConnectivityStatusEntity.connected) {
///     // Internet is available
///     syncData();
///   } else {
///     // No internet
///     showOfflineUI();
///   }
/// });
/// ```
///
/// ### 4. Custom endpoints
/// ```dart
/// await connectivity.initialize(
///   checkOptions: [
///     ConnectivityCheckOptionEntity(
///       uri: Uri.parse('https://api.myapp.com/health'),
///       timeout: Duration(seconds: 5),
///     ),
///   ],
/// );
/// ```
///
/// ### 5. Pause/Resume (for app lifecycle)
/// ```dart
/// @override
/// void didChangeAppLifecycleState(AppLifecycleState state) {
///   if (state == AppLifecycleState.paused) {
///     connectivity.pause();
///   } else if (state == AppLifecycleState.resumed) {
///     connectivity.resume();
///   }
/// }
/// ```
///
/// ## Features
/// - ✅ Real internet connectivity checking (not just Wi-Fi status)
/// - ✅ Subsecond response times
/// - ✅ Customizable check endpoints
/// - ✅ Configurable check intervals
/// - ✅ Lifecycle management (pause/resume)
/// - ✅ Broadcast stream for multiple listeners
/// - ✅ Cross-platform support
/// - ✅ Dependency independent design
///
/// ## Changing Implementation
///
/// To switch from internet_connection_checker_plus to another package:
///
/// 1. Create new implementation:
/// ```dart
/// class CustomConnectivityServiceImpl implements ConnectivityService {
///   // Implement with different package
/// }
/// ```
///
/// 2. Update DI registration:
/// ```dart
/// getIt.registerLazySingleton<ConnectivityService>(
///   () => CustomConnectivityServiceImpl(),
/// );
/// ```
///
/// That's it! No changes needed in business logic or UI code.
///
/// ## Documentation
/// - See `doc/README.md` for detailed documentation
/// - See `doc/QUICK_START.md` for step-by-step guide
/// - See examples in `example/connectivity_example.dart`
library connectivity;

export 'constants/constants.dart';
export 'contract/contracts.dart';
export 'impl/impl.dart';


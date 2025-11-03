/// Analytics infrastructure services.
///
/// This library provides dependency-independent abstractions for analytics
/// tracking and crash reporting. It supports multiple providers through
/// a common interface.
///
/// ## Available Services
///
/// ### Analytics Services
/// - [AnalyticsService] - Main analytics tracking interface
/// - [PostHogAnalyticsServiceImpl] - PostHog implementation
///
/// ### Crash Reporting Services
/// - [CrashReporterService] - Crash and error reporting interface
/// - [FirebaseCrashlyticsServiceImpl] - Firebase Crashlytics implementation
///
/// ## Quick Start
///
/// ### Setting up Analytics (PostHog)
///
/// ```dart
/// // 1. Add to pubspec.yaml
/// dependencies:
///   posthog_flutter: ^5.8.0
///
/// // 2. Create and initialize
/// final analytics = PostHogAnalyticsServiceImpl(
///   apiKey: 'YOUR_API_KEY',
///   host: 'https://app.posthog.com',
/// );
/// await analytics.initialize();
///
/// // 3. Track events
/// await analytics.trackEvent(
///   AnalyticsEvent(
///     name: 'button_clicked',
///     properties: {'button_id': 'submit'},
///   ),
/// );
///
/// // 4. Identify users
/// await analytics.identifyUser(
///   AnalyticsUser(
///     id: 'user_123',
///     email: 'user@example.com',
///     properties: {'plan': 'premium'},
///   ),
/// );
/// ```
///
/// ### Setting up Crash Reporting (Firebase Crashlytics)
///
/// ```dart
/// // 1. Add to pubspec.yaml
/// dependencies:
///   firebase_core: ^3.0.0
///   firebase_crashlytics: ^5.0.4
///
/// // 2. Initialize Firebase and crash reporter
/// await Firebase.initializeApp();
/// final crashReporter = FirebaseCrashlyticsServiceImpl();
/// await crashReporter.initialize();
///
/// // 3. Catch Flutter errors
/// FlutterError.onError = (details) {
///   crashReporter.recordFlutterError(details);
/// };
///
/// // 4. Catch async errors
/// PlatformDispatcher.instance.onError = (error, stack) {
///   crashReporter.recordError(
///     exception: error,
///     stackTrace: stack,
///     fatal: true,
///   );
///   return true;
/// };
///
/// // 5. Manual error reporting
/// try {
///   await riskyOperation();
/// } catch (e, stack) {
///   await crashReporter.recordError(
///     exception: e,
///     stackTrace: stack,
///     reason: 'Risky operation failed',
///   );
/// }
/// ```
///
/// ## Dependency Independence
///
/// This module follows strict dependency independence principles:
///
/// ✅ **Easy to Switch Providers**
/// ```dart
/// // Switch from PostHog to Mixpanel? Just change one line!
///
/// // Before (PostHog)
/// getIt.registerLazySingleton<AnalyticsService>(
///   () => PostHogAnalyticsServiceImpl(...),
/// );
///
/// // After (Mixpanel - when implemented)
/// getIt.registerLazySingleton<AnalyticsService>(
///   () => MixpanelAnalyticsServiceImpl(...),
/// );
///
/// // No changes needed in business logic!
/// ```
///
/// ✅ **No Third-Party Types Exposed**
/// ```dart
/// // All methods return Either<Failure, T>
/// // Never expose PostHog or Firebase types
/// Future<Either<Failure, void>> trackEvent(AnalyticsEvent event);
/// ```
///
/// ✅ **Multiple Implementations**
/// ```dart
/// // Can use both PostHog AND Mixpanel simultaneously
/// class CompositeAnalyticsService implements AnalyticsService {
///   final PostHogAnalyticsServiceImpl posthog;
///   final MixpanelAnalyticsServiceImpl mixpanel;
///
///   @override
///   Future<Either<Failure, void>> trackEvent(event) async {
///     await posthog.trackEvent(event);
///     await mixpanel.trackEvent(event);
///     return const Right(null);
///   }
/// }
/// ```
///
/// ## Models
///
/// - [AnalyticsEvent] - Represents an analytics event
/// - [AnalyticsUser] - Represents a user for analytics
/// - [CrashReport] - Represents a crash or error report
///
/// ## Error Handling
///
/// - [AnalyticsFailure] - Analytics-specific failures
/// - [CrashReporterFailure] - Crash reporter-specific failures
///
/// ## See Also
///
/// - [PostHog Documentation](https://posthog.com/docs)
/// - [Firebase Crashlytics Documentation](https://firebase.google.com/docs/crashlytics)
library;

// Contracts
export 'contract/contracts.dart';

// Models
export 'models/models.dart';

// Constants
export 'constants/constants.dart';

// Implementations
export 'impl/impl.dart';


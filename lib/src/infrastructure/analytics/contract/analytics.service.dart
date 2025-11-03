import 'package:dartz/dartz.dart';

import '../../../errors/failures.dart';
import '../models/analytics_event.model.dart';
import '../models/analytics_user.model.dart';

/// Abstract interface for analytics services.
///
/// This interface provides a dependency-independent abstraction for analytics
/// tracking. It can be implemented by any analytics provider (PostHog, Mixpanel,
/// Amplitude, etc.) without exposing their specific APIs.
///
/// ## Design Philosophy
///
/// This service follows the Dependency Independence principle:
/// - No third-party types exposed in public API
/// - Easy to switch between analytics providers
/// - Multiple implementations can coexist
/// - Testable with mock implementations
///
/// ## Usage Example
///
/// ```dart
/// // Track a simple event
/// final result = await analytics.trackEvent(
///   AnalyticsEvent(
///     name: 'button_clicked',
///     properties: {'button_id': 'submit'},
///   ),
/// );
///
/// // Identify user
/// await analytics.identifyUser(
///   AnalyticsUser(
///     id: 'user_123',
///     email: 'user@example.com',
///     properties: {'plan': 'premium'},
///   ),
/// );
///
/// // Track screen view
/// await analytics.trackScreenView('Home Screen');
/// ```
///
/// ## Implementation Examples
///
/// - [PostHogAnalyticsServiceImpl] - PostHog implementation
/// - [MixpanelAnalyticsServiceImpl] - Mixpanel implementation (future)
/// - [AmplitudeAnalyticsServiceImpl] - Amplitude implementation (future)
///
/// ## Error Handling
///
/// All methods return `Either<Failure, T>` for consistent error handling:
/// - Left(AnalyticsFailure) - When analytics operation fails
/// - Right(value) - When operation succeeds
abstract class AnalyticsService {
  /// Initializes the analytics service.
  ///
  /// Must be called before any other methods. Configure the service with
  /// API keys, endpoints, and other settings via constructor injection
  /// in the implementation.
  ///
  /// Returns:
  /// - Right(void) - Initialization successful
  /// - Left(AnalyticsFailure) - Initialization failed
  ///
  /// Example:
  /// ```dart
  /// final result = await analytics.initialize();
  /// result.fold(
  ///   (failure) => print('Failed to initialize: $failure'),
  ///   (_) => print('Analytics initialized'),
  /// );
  /// ```
  Future<Either<Failure, void>> initialize();

  /// Tracks an analytics event.
  ///
  /// Events represent user actions or system occurrences that you want to track.
  ///
  /// [event] - The event to track with name and optional properties
  ///
  /// Returns:
  /// - Right(void) - Event tracked successfully
  /// - Left(AnalyticsFailure) - Failed to track event
  ///
  /// Example:
  /// ```dart
  /// await analytics.trackEvent(
  ///   AnalyticsEvent(
  ///     name: 'purchase_completed',
  ///     properties: {
  ///       'product_id': '123',
  ///       'amount': 99.99,
  ///       'currency': 'USD',
  ///     },
  ///   ),
  /// );
  /// ```
  Future<Either<Failure, void>> trackEvent(AnalyticsEvent event);

  /// Tracks a screen view.
  ///
  /// Use this to track when users navigate to different screens in your app.
  ///
  /// [screenName] - Name of the screen
  /// [properties] - Optional additional properties about the screen
  ///
  /// Returns:
  /// - Right(void) - Screen view tracked successfully
  /// - Left(AnalyticsFailure) - Failed to track screen view
  ///
  /// Example:
  /// ```dart
  /// await analytics.trackScreenView(
  ///   'Product Detail',
  ///   properties: {'product_id': '123'},
  /// );
  /// ```
  Future<Either<Failure, void>> trackScreenView(
    String screenName, {
    Map<String, dynamic>? properties,
  });

  /// Identifies the current user.
  ///
  /// Associates all future events with this user. Call this after user login
  /// or when user information becomes available.
  ///
  /// [user] - User information to identify
  ///
  /// Returns:
  /// - Right(void) - User identified successfully
  /// - Left(AnalyticsFailure) - Failed to identify user
  ///
  /// Example:
  /// ```dart
  /// await analytics.identifyUser(
  ///   AnalyticsUser(
  ///     id: 'user_123',
  ///     email: 'john@example.com',
  ///     name: 'John Doe',
  ///     properties: {
  ///       'plan': 'premium',
  ///       'signup_date': '2025-01-01',
  ///     },
  ///   ),
  /// );
  /// ```
  Future<Either<Failure, void>> identifyUser(AnalyticsUser user);

  /// Resets the current user identity.
  ///
  /// Call this when user logs out to ensure events are not associated
  /// with the previous user.
  ///
  /// Returns:
  /// - Right(void) - User reset successfully
  /// - Left(AnalyticsFailure) - Failed to reset user
  ///
  /// Example:
  /// ```dart
  /// await analytics.resetUser();
  /// ```
  Future<Either<Failure, void>> resetUser();

  /// Sets a super property that will be sent with all future events.
  ///
  /// Super properties are useful for tracking persistent user or session
  /// attributes without having to include them in every event.
  ///
  /// [key] - Property key
  /// [value] - Property value
  ///
  /// Returns:
  /// - Right(void) - Property set successfully
  /// - Left(AnalyticsFailure) - Failed to set property
  ///
  /// Example:
  /// ```dart
  /// await analytics.setSuperProperty('app_version', '1.2.3');
  /// await analytics.setSuperProperty('theme', 'dark');
  /// ```
  Future<Either<Failure, void>> setSuperProperty(String key, dynamic value);

  /// Removes a super property.
  ///
  /// [key] - Property key to remove
  ///
  /// Returns:
  /// - Right(void) - Property removed successfully
  /// - Left(AnalyticsFailure) - Failed to remove property
  Future<Either<Failure, void>> removeSuperProperty(String key);

  /// Sets multiple super properties at once.
  ///
  /// [properties] - Map of properties to set
  ///
  /// Returns:
  /// - Right(void) - Properties set successfully
  /// - Left(AnalyticsFailure) - Failed to set properties
  ///
  /// Example:
  /// ```dart
  /// await analytics.setSuperProperties({
  ///   'app_version': '1.2.3',
  ///   'platform': 'mobile',
  ///   'environment': 'production',
  /// });
  /// ```
  Future<Either<Failure, void>> setSuperProperties(
    Map<String, dynamic> properties,
  );

  /// Clears all super properties.
  ///
  /// Returns:
  /// - Right(void) - Properties cleared successfully
  /// - Left(AnalyticsFailure) - Failed to clear properties
  Future<Either<Failure, void>> clearSuperProperties();

  /// Enables or disables analytics tracking.
  ///
  /// When disabled, events will not be sent to the analytics service.
  /// Useful for respecting user privacy preferences.
  ///
  /// [enabled] - Whether analytics should be enabled
  ///
  /// Returns:
  /// - Right(void) - Setting updated successfully
  /// - Left(AnalyticsFailure) - Failed to update setting
  ///
  /// Example:
  /// ```dart
  /// // Disable tracking if user opts out
  /// await analytics.setEnabled(false);
  /// ```
  Future<Either<Failure, void>> setEnabled(bool enabled);

  /// Gets whether analytics tracking is currently enabled.
  ///
  /// Returns:
  /// - Right(bool) - Current enabled state
  /// - Left(AnalyticsFailure) - Failed to get state
  Future<Either<Failure, bool>> isEnabled();

  /// Flushes any queued events to the server immediately.
  ///
  /// Most analytics SDKs batch events and send them periodically.
  /// Use this method to force immediate sending of all queued events.
  ///
  /// Useful before app termination or before long background periods.
  ///
  /// Returns:
  /// - Right(void) - Flush completed successfully
  /// - Left(AnalyticsFailure) - Failed to flush
  ///
  /// Example:
  /// ```dart
  /// // Flush before app closes
  /// await analytics.flush();
  /// ```
  Future<Either<Failure, void>> flush();

  /// Disposes resources used by the analytics service.
  ///
  /// Call this when the service is no longer needed to clean up resources.
  Future<Either<Failure, void>> dispose();
}

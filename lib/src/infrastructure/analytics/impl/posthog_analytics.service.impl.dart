import 'package:dartz/dartz.dart';
import 'package:posthog_flutter/posthog_flutter.dart' as posthog;

import '../../../errors/analytics_failure.dart';
import '../../../errors/failures.dart';
import '../contract/analytics.service.dart';
import '../models/analytics_event.model.dart';
import '../models/analytics_user.model.dart';

/// PostHog implementation of [AnalyticsService].
///
/// This implementation wraps the PostHog Flutter SDK and provides a
/// dependency-independent interface for analytics tracking.
///
/// ## Setup
///
/// 1. Add PostHog to your pubspec.yaml:
/// ```yaml
/// dependencies:
///   posthog_flutter: ^5.8.0
/// ```
///
/// 2. Initialize PostHog in your app:
/// ```dart
/// // Create instance with API key
/// final analytics = PostHogAnalyticsServiceImpl(
///   apiKey: 'YOUR_API_KEY',
/// );
///
/// // Initialize
/// await analytics.initialize();
/// ```
///
/// 3. Register in dependency injection:
/// ```dart
/// getIt.registerLazySingleton<AnalyticsService>(
///   () => PostHogAnalyticsServiceImpl(
///     apiKey: 'YOUR_API_KEY',
///   ),
/// );
/// ```
///
/// **Note**: The PostHog Flutter SDK v5.8.0 uses a simplified initialization
/// that only requires the API key. Other configuration parameters (host,
/// captureScreenViews, etc.) are kept in the constructor for backward
/// compatibility but are not currently used by the SDK.
///
/// ## Features
///
/// - Event tracking
/// - User identification
/// - Screen view tracking
/// - Super properties (global properties)
/// - Enable/disable tracking
/// - Event batching and flushing
///
/// ## Provider-Specific Notes
///
/// - PostHog automatically batches events for efficient network usage
/// - Events are stored locally and sent in background
/// - Supports feature flags (not exposed in this interface, can be extended)
/// - Supports session recording (not exposed in this interface, can be extended)
///
/// ## Switching Providers
///
/// To switch from PostHog to another provider (e.g., Mixpanel):
/// 1. Create new implementation (e.g., MixpanelAnalyticsServiceImpl)
/// 2. Update DI registration
/// 3. No changes needed in business logic!
class PostHogAnalyticsServiceImpl implements AnalyticsService {
  /// PostHog API key.
  final String apiKey;

  /// PostHog host URL.
  ///
  /// Use 'https://app.posthog.com' for PostHog Cloud
  /// or your self-hosted URL.
  final String host;

  /// Whether to capture screen views automatically.
  final bool captureScreenViews;

  /// Whether to capture application lifecycle events.
  final bool captureApplicationLifecycleEvents;

  /// Whether to enable debug logging.
  final bool debug;

  /// Maximum batch size for events.
  final int maxBatchSize;

  /// Maximum queue size for events.
  final int maxQueueSize;

  bool _isInitialized = false;
  bool _isEnabled = true;

  /// Creates a PostHog analytics service.
  ///
  /// [apiKey] - Your PostHog API key (required)
  ///
  /// Note: Other parameters (host, captureScreenViews, etc.) are kept for
  /// backward compatibility but are not currently used by PostHog SDK v5.8.0.
  /// The SDK uses a simplified configuration that only requires the API key.
  PostHogAnalyticsServiceImpl({
    required this.apiKey,
    this.host = 'https://app.posthog.com',
    this.captureScreenViews = false,
    this.captureApplicationLifecycleEvents = true,
    this.debug = false,
    this.maxBatchSize = 30,
    this.maxQueueSize = 1000,
  });

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) {
        return const Right(null);
      }

      await posthog.Posthog().setup(
        posthog.PostHogConfig(apiKey),
      );

      _isInitialized = true;
      return const Right(null);
    } catch (e) {
      return Left(AnalyticsFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> trackEvent(AnalyticsEvent event) async {
    try {
      if (!_isInitialized) {
        return Left(AnalyticsFailure.notInitialized());
      }

      if (!_isEnabled) {
        return Left(AnalyticsFailure.disabled());
      }

      if (event.name.isEmpty) {
        return Left(
            AnalyticsFailure.invalidEvent('Event name cannot be empty'));
      }

      await posthog.Posthog().capture(
        eventName: event.name,
        properties: event.properties?.map(
          (key, value) => MapEntry(key, value as Object),
        ),
      );

      return const Right(null);
    } catch (e) {
      return Left(AnalyticsFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> trackScreenView(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    try {
      if (!_isInitialized) {
        return Left(AnalyticsFailure.notInitialized());
      }

      if (!_isEnabled) {
        return Left(AnalyticsFailure.disabled());
      }

      if (screenName.isEmpty) {
        return Left(
            AnalyticsFailure.invalidEvent('Screen name cannot be empty'));
      }

      await posthog.Posthog().screen(
        screenName: screenName,
        properties: properties?.map(
          (key, value) => MapEntry(key, value as Object),
        ),
      );

      return const Right(null);
    } catch (e) {
      return Left(AnalyticsFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> identifyUser(AnalyticsUser user) async {
    try {
      if (!_isInitialized) {
        return Left(AnalyticsFailure.notInitialized());
      }

      if (!_isEnabled) {
        return Left(AnalyticsFailure.disabled());
      }

      if (user.id.isEmpty) {
        return Left(AnalyticsFailure.invalidUser('User ID cannot be empty'));
      }

      // Prepare user properties
      final userProperties = <String, dynamic>{};

      if (user.email != null) {
        userProperties['email'] = user.email;
      }
      if (user.name != null) {
        userProperties['name'] = user.name;
      }
      if (user.phone != null) {
        userProperties['phone'] = user.phone;
      }
      if (user.properties != null) {
        userProperties.addAll(user.properties!);
      }

      await posthog.Posthog().identify(
        userId: user.id,
        userProperties: userProperties.isNotEmpty
            ? userProperties.map(
                (key, value) => MapEntry(key, value as Object),
              )
            : null,
      );

      return const Right(null);
    } catch (e) {
      return Left(AnalyticsFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetUser() async {
    try {
      if (!_isInitialized) {
        return Left(AnalyticsFailure.notInitialized());
      }

      await posthog.Posthog().reset();

      return const Right(null);
    } catch (e) {
      return Left(AnalyticsFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> setSuperProperty(
      String key, dynamic value) async {
    try {
      if (!_isInitialized) {
        return Left(AnalyticsFailure.notInitialized());
      }

      if (key.isEmpty) {
        return Left(
            AnalyticsFailure.invalidEvent('Property key cannot be empty'));
      }

      await posthog.Posthog().register(key, value as Object);

      return const Right(null);
    } catch (e) {
      return Left(AnalyticsFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeSuperProperty(String key) async {
    try {
      if (!_isInitialized) {
        return Left(AnalyticsFailure.notInitialized());
      }

      await posthog.Posthog().unregister(key);

      return const Right(null);
    } catch (e) {
      return Left(AnalyticsFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> setSuperProperties(
      Map<String, dynamic> properties) async {
    try {
      if (!_isInitialized) {
        return Left(AnalyticsFailure.notInitialized());
      }

      // PostHog doesn't have a bulk register method, so we register individually
      for (final entry in properties.entries) {
        await posthog.Posthog().register(entry.key, entry.value as Object);
      }

      return const Right(null);
    } catch (e) {
      return Left(AnalyticsFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> clearSuperProperties() async {
    try {
      if (!_isInitialized) {
        return Left(AnalyticsFailure.notInitialized());
      }

      // PostHog doesn't have a clear all method
      // This is a limitation - we can't clear all properties
      // App should track registered keys if they need to clear all
      return const Left(
        AnalyticsFailure(
          message:
              'PostHog does not support clearing all super properties. Use removeSuperProperty() for specific keys.',
          code: 'not_supported',
        ),
      );
    } catch (e) {
      return Left(AnalyticsFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> setEnabled(bool enabled) async {
    try {
      if (!_isInitialized) {
        return Left(AnalyticsFailure.notInitialized());
      }

      _isEnabled = enabled;

      if (enabled) {
        await posthog.Posthog().enable();
      } else {
        await posthog.Posthog().disable();
      }

      return const Right(null);
    } catch (e) {
      return Left(AnalyticsFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isEnabled() async {
    try {
      if (!_isInitialized) {
        return Left(AnalyticsFailure.notInitialized());
      }

      final enabled = await posthog.Posthog().isOptOut();
      // PostHog isOptOut returns true if opted out (disabled)
      // So we need to invert it
      return Right(!enabled);
    } catch (e) {
      return Left(AnalyticsFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> flush() async {
    try {
      if (!_isInitialized) {
        return Left(AnalyticsFailure.notInitialized());
      }

      await posthog.Posthog().flush();

      return const Right(null);
    } catch (e) {
      return Left(AnalyticsFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      if (!_isInitialized) {
        return const Right(null);
      }

      await posthog.Posthog().close();
      _isInitialized = false;

      return const Right(null);
    } catch (e) {
      return Left(AnalyticsFailure.fromException(e));
    }
  }
}

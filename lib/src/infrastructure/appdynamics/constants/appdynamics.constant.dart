/// Constants for AppDynamics infrastructure.
///
/// This file contains constants used across the AppDynamics infrastructure
/// module. These constants are dependency-independent and can be used
/// by any AppDynamics implementation.
class AppDynamicsConstants {
  AppDynamicsConstants._();

  /// Default collector URL for AppDynamics cloud deployments.
  ///
  /// This is typically used for cloud-based AppDynamics installations.
  /// For on-premises deployments, use a custom collector URL.
  static const String defaultCollectorURL = 'https://mobile-collector.eum-appdynamics.com';

  /// Default screenshot URL for AppDynamics cloud deployments.
  ///
  /// This is typically used for cloud-based AppDynamics installations.
  /// For on-premises deployments, use a custom screenshot URL.
  static const String defaultScreenshotURL = 'https://mobile-image-collector.eum-appdynamics.com';

  /// Maximum length for breadcrumb messages.
  static const int maxBreadcrumbMessageLength = 250;

  /// Maximum length for session frame names.
  static const int maxSessionFrameNameLength = 100;

  /// Maximum length for timer names.
  static const int maxTimerNameLength = 100;

  /// Maximum length for metric names.
  static const int maxMetricNameLength = 100;

  /// Maximum length for info point names.
  static const int maxInfoPointNameLength = 100;

  /// Maximum number of properties per event.
  static const int maxPropertiesPerEvent = 50;

  /// Maximum length for property keys.
  static const int maxPropertyKeyLength = 100;

  /// Maximum length for property values (as string).
  static const int maxPropertyValueLength = 1000;
}


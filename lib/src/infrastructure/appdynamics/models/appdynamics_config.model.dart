/// Configuration model for AppDynamics Agent initialization.
///
/// This model provides dependency-independent configuration options for
/// AppDynamics. Different implementations can map these to their specific
/// SDK configuration.
///
/// ## Usage Example
///
/// ```dart
/// final config = AppDynamicsConfig(
///   appKey: 'YOUR_EUM_APP_KEY',
///   loggingLevel: AppDynamicsLoggingLevel.verbose,
///   collectorURL: 'https://your-collector-url.com',
/// );
///
/// final result = await appDynamics.initialize(config);
/// ```
class AppDynamicsConfig {
  /// AppDynamics EUM (End User Monitoring) app key.
  ///
  /// This is required for AppDynamics to identify your application.
  /// Get this from your AppDynamics dashboard.
  final String appKey;

  /// Logging level for AppDynamics SDK.
  ///
  /// Controls how much debug information is logged.
  /// Default: [AppDynamicsLoggingLevel.info]
  final AppDynamicsLoggingLevel? loggingLevel;

  /// Collector URL for on-premises deployments.
  ///
  /// Optional. Only needed for on-premises AppDynamics installations.
  /// For cloud deployments, this can be null.
  final String? collectorURL;

  /// Screenshot URL for on-premises deployments.
  ///
  /// Optional. Only needed for on-premises AppDynamics installations.
  /// For cloud deployments, this can be null.
  final String? screenshotURL;

  /// Whether to enable automatic network request tracking.
  ///
  /// When enabled, AppDynamics will automatically track HTTP requests.
  /// Default: true
  final bool? enableNetworkRequestTracking;

  /// Whether to enable automatic crash reporting.
  ///
  /// When enabled, AppDynamics will automatically capture and report crashes.
  /// Default: true
  final bool? enableCrashReporting;

  /// Whether to enable automatic screen tracking.
  ///
  /// When enabled, AppDynamics will automatically track screen views.
  /// Default: true
  final bool? enableScreenTracking;

  /// Whether to enable ANR (App Not Responding) detection.
  ///
  /// Android only. Detects when the app becomes unresponsive.
  /// Default: true
  final bool? enableAnrDetection;

  /// Whether to enable automatic screenshot capture (iOS only).
  ///
  /// iOS only. Automatically captures screenshots for session replay.
  /// Default: false
  final bool? enableScreenshotCapture;

  /// Whether to enable automatic touch point capture (iOS only).
  ///
  /// iOS only. Automatically captures user touch interactions.
  /// Default: false
  final bool? enableTouchPointCapture;

  /// Whether to enable automatic device metrics reporting.
  ///
  /// When enabled, AppDynamics will automatically report device metrics
  /// (memory, storage, battery, etc.).
  /// Default: true
  final bool? enableDeviceMetrics;

  /// Additional custom configuration parameters.
  ///
  /// For future extensibility and provider-specific options.
  final Map<String, dynamic>? customParameters;

  const AppDynamicsConfig({
    required this.appKey,
    this.loggingLevel,
    this.collectorURL,
    this.screenshotURL,
    this.enableNetworkRequestTracking,
    this.enableCrashReporting,
    this.enableScreenTracking,
    this.enableAnrDetection,
    this.enableScreenshotCapture,
    this.enableTouchPointCapture,
    this.enableDeviceMetrics,
    this.customParameters,
  });

  /// Creates a configuration with default settings for production.
  ///
  /// - Logging level: info
  /// - All automatic tracking enabled
  /// - Screenshot/touch capture disabled (privacy)
  factory AppDynamicsConfig.production({
    required String appKey,
    String? collectorURL,
    String? screenshotURL,
  }) {
    return AppDynamicsConfig(
      appKey: appKey,
      loggingLevel: AppDynamicsLoggingLevel.info,
      collectorURL: collectorURL,
      screenshotURL: screenshotURL,
      enableNetworkRequestTracking: true,
      enableCrashReporting: true,
      enableScreenTracking: true,
      enableAnrDetection: true,
      enableScreenshotCapture: false,
      enableTouchPointCapture: false,
      enableDeviceMetrics: true,
    );
  }

  /// Creates a configuration with verbose logging for development.
  ///
  /// - Logging level: verbose
  /// - All automatic tracking enabled
  /// - Screenshot/touch capture enabled for debugging
  factory AppDynamicsConfig.development({
    required String appKey,
    String? collectorURL,
    String? screenshotURL,
  }) {
    return AppDynamicsConfig(
      appKey: appKey,
      loggingLevel: AppDynamicsLoggingLevel.verbose,
      collectorURL: collectorURL,
      screenshotURL: screenshotURL,
      enableNetworkRequestTracking: true,
      enableCrashReporting: true,
      enableScreenTracking: true,
      enableAnrDetection: true,
      enableScreenshotCapture: true,
      enableTouchPointCapture: true,
      enableDeviceMetrics: true,
    );
  }

  /// Creates a minimal configuration with only essential features.
  ///
  /// - Only crash reporting enabled
  /// - Network tracking enabled
  /// - Screen tracking disabled
  /// - ANR detection disabled
  factory AppDynamicsConfig.minimal({
    required String appKey,
    String? collectorURL,
  }) {
    return AppDynamicsConfig(
      appKey: appKey,
      loggingLevel: AppDynamicsLoggingLevel.warning,
      collectorURL: collectorURL,
      enableNetworkRequestTracking: true,
      enableCrashReporting: true,
      enableScreenTracking: false,
      enableAnrDetection: false,
      enableScreenshotCapture: false,
      enableTouchPointCapture: false,
      enableDeviceMetrics: false,
    );
  }

  /// Copy with new values.
  AppDynamicsConfig copyWith({
    String? appKey,
    AppDynamicsLoggingLevel? loggingLevel,
    String? collectorURL,
    String? screenshotURL,
    bool? enableNetworkRequestTracking,
    bool? enableCrashReporting,
    bool? enableScreenTracking,
    bool? enableAnrDetection,
    bool? enableScreenshotCapture,
    bool? enableTouchPointCapture,
    bool? enableDeviceMetrics,
    Map<String, dynamic>? customParameters,
  }) {
    return AppDynamicsConfig(
      appKey: appKey ?? this.appKey,
      loggingLevel: loggingLevel ?? this.loggingLevel,
      collectorURL: collectorURL ?? this.collectorURL,
      screenshotURL: screenshotURL ?? this.screenshotURL,
      enableNetworkRequestTracking:
          enableNetworkRequestTracking ?? this.enableNetworkRequestTracking,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      enableScreenTracking:
          enableScreenTracking ?? this.enableScreenTracking,
      enableAnrDetection: enableAnrDetection ?? this.enableAnrDetection,
      enableScreenshotCapture:
          enableScreenshotCapture ?? this.enableScreenshotCapture,
      enableTouchPointCapture:
          enableTouchPointCapture ?? this.enableTouchPointCapture,
      enableDeviceMetrics:
          enableDeviceMetrics ?? this.enableDeviceMetrics,
      customParameters: customParameters ?? this.customParameters,
    );
  }

  @override
  String toString() {
    return 'AppDynamicsConfig('
        'appKey: ${appKey.substring(0, appKey.length > 8 ? 8 : appKey.length)}..., '
        'loggingLevel: $loggingLevel, '
        'collectorURL: $collectorURL, '
        'screenshotURL: $screenshotURL'
        ')';
  }
}

/// Logging levels for AppDynamics SDK.
///
/// Controls the verbosity of debug logs from the AppDynamics SDK.
enum AppDynamicsLoggingLevel {
  /// No logging (quiet mode).
  none,

  /// Only error messages.
  error,

  /// Warning and error messages.
  warning,

  /// Info, warning, and error messages.
  info,

  /// Verbose logging (all messages, including debug).
  verbose,
}


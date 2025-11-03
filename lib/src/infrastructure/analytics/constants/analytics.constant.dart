/// Analytics-related constants.
///
/// This file contains constants used throughout the analytics infrastructure.
library;

/// Common analytics event names.
///
/// Use these constants to ensure consistency across your application.
class AnalyticsEvents {
  AnalyticsEvents._();

  // Authentication events
  static const String signUp = 'sign_up';
  static const String login = 'login';
  static const String logout = 'logout';

  // E-commerce events
  static const String purchase = 'purchase';
  static const String addToCart = 'add_to_cart';
  static const String removeFromCart = 'remove_from_cart';
  static const String viewProduct = 'view_product';
  static const String beginCheckout = 'begin_checkout';

  // User interaction events
  static const String search = 'search';
  static const String share = 'share';
  static const String rate = 'rate';
  static const String buttonClicked = 'button_clicked';
  static const String linkClicked = 'link_clicked';

  // App lifecycle events
  static const String appOpen = 'app_open';
  static const String appClose = 'app_close';
  static const String appBackground = 'app_background';
  static const String appForeground = 'app_foreground';

  // Tutorial/Onboarding events
  static const String tutorialBegin = 'tutorial_begin';
  static const String tutorialComplete = 'tutorial_complete';
  static const String onboardingStart = 'onboarding_start';
  static const String onboardingComplete = 'onboarding_complete';

  // Engagement events
  static const String levelComplete = 'level_complete';
  static const String achievementUnlocked = 'achievement_unlocked';
  static const String goalCompleted = 'goal_completed';

  // Content events
  static const String contentView = 'content_view';
  static const String videoStart = 'video_start';
  static const String videoComplete = 'video_complete';

  // Error events
  static const String errorOccurred = 'error_occurred';
  static const String apiError = 'api_error';
  static const String validationError = 'validation_error';
}

/// Common analytics property keys.
///
/// Use these constants for consistent property naming.
class AnalyticsProperties {
  AnalyticsProperties._();

  // User properties
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String userPlan = 'user_plan';
  static const String userType = 'user_type';

  // Product properties
  static const String productId = 'product_id';
  static const String productName = 'product_name';
  static const String productCategory = 'product_category';
  static const String productPrice = 'product_price';
  static const String productQuantity = 'product_quantity';

  // Transaction properties
  static const String transactionId = 'transaction_id';
  static const String currency = 'currency';
  static const String amount = 'amount';
  static const String paymentMethod = 'payment_method';

  // App properties
  static const String appVersion = 'app_version';
  static const String platform = 'platform';
  static const String environment = 'environment';
  static const String deviceId = 'device_id';
  static const String deviceModel = 'device_model';
  static const String osVersion = 'os_version';

  // Screen properties
  static const String screenName = 'screen_name';
  static const String screenClass = 'screen_class';
  static const String previousScreen = 'previous_screen';

  // Action properties
  static const String actionType = 'action_type';
  static const String actionTarget = 'action_target';
  static const String actionValue = 'action_value';
  static const String source = 'source';
  static const String method = 'method';

  // Search properties
  static const String searchQuery = 'search_query';
  static const String searchResults = 'search_results';
  static const String searchCategory = 'search_category';

  // Error properties
  static const String errorType = 'error_type';
  static const String errorMessage = 'error_message';
  static const String errorCode = 'error_code';
  static const String errorStack = 'error_stack';

  // Engagement properties
  static const String duration = 'duration';
  static const String level = 'level';
  static const String achievement = 'achievement';
  static const String score = 'score';
  static const String progress = 'progress';
}

/// Crash reporter custom key names.
///
/// Use these constants for consistent crash reporting context.
class CrashReporterKeys {
  CrashReporterKeys._();

  // User context
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String isPremium = 'is_premium';
  static const String accountAge = 'account_age';

  // App context
  static const String appVersion = 'app_version';
  static const String buildNumber = 'build_number';
  static const String environment = 'environment';
  static const String flavor = 'flavor';

  // Device context
  static const String deviceId = 'device_id';
  static const String deviceModel = 'device_model';
  static const String osVersion = 'os_version';
  static const String platform = 'platform';

  // Session context
  static const String sessionId = 'session_id';
  static const String sessionDuration = 'session_duration';
  static const String lastScreen = 'last_screen';
  static const String lastAction = 'last_action';

  // Network context
  static const String networkType = 'network_type';
  static const String isOnline = 'is_online';
  static const String lastApiCall = 'last_api_call';
  static const String apiEndpoint = 'api_endpoint';

  // Feature flags
  static const String featureFlags = 'feature_flags';
  static const String abTestVariant = 'ab_test_variant';

  // App state
  static const String memoryUsage = 'memory_usage';
  static const String batteryLevel = 'battery_level';
  static const String storageAvailable = 'storage_available';
  static const String cacheSize = 'cache_size';

  // Business context
  static const String cartItems = 'cart_items';
  static const String cartValue = 'cart_value';
  static const String transactionId = 'transaction_id';
  static const String paymentMethod = 'payment_method';
}


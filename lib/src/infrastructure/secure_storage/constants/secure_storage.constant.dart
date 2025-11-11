/// Constants for Secure Storage Service
///
/// Provides common key names and configuration values for secure storage.
class SecureStorageConstants {
  SecureStorageConstants._(); // Private constructor to prevent instantiation

  // ==================== Common Storage Keys ====================

  /// Authentication token key
  static const String authToken = 'auth_token';

  /// Refresh token key
  static const String refreshToken = 'refresh_token';

  /// Access token key
  static const String accessToken = 'access_token';

  /// User ID key
  static const String userId = 'user_id';

  /// User email key
  static const String userEmail = 'user_email';

  /// API key
  static const String apiKey = 'api_key';

  /// API secret
  static const String apiSecret = 'api_secret';

  /// Encryption key
  static const String encryptionKey = 'encryption_key';

  /// Device ID key
  static const String deviceId = 'device_id';

  /// FCM token key (for push notifications)
  static const String fcmToken = 'fcm_token';

  /// Biometric authentication key
  static const String biometricKey = 'biometric_key';

  /// PIN code key
  static const String pinCode = 'pin_code';

  /// Session ID key
  static const String sessionId = 'session_id';

  /// OAuth state key
  static const String oauthState = 'oauth_state';

  /// OAuth code verifier (PKCE)
  static const String oauthCodeVerifier = 'oauth_code_verifier';

  // ==================== Prefixes for Grouping ====================

  /// Prefix for authentication-related keys
  static const String authPrefix = 'auth_';

  /// Prefix for user-related keys
  static const String userPrefix = 'user_';

  /// Prefix for API-related keys
  static const String apiPrefix = 'api_';

  /// Prefix for encryption-related keys
  static const String encryptionPrefix = 'encryption_';

  /// Prefix for device-related keys
  static const String devicePrefix = 'device_';

  /// Prefix for temporary/session keys
  static const String tempPrefix = 'temp_';

  // ==================== Key Builders ====================

  /// Build authentication key with custom suffix
  ///
  /// Example: `buildAuthKey('token')` returns `'auth_token'`
  static String buildAuthKey(String suffix) => '$authPrefix$suffix';

  /// Build user key with custom suffix
  ///
  /// Example: `buildUserKey('profile')` returns `'user_profile'`
  static String buildUserKey(String suffix) => '$userPrefix$suffix';

  /// Build API key with custom suffix
  ///
  /// Example: `buildApiKey('key')` returns `'api_key'`
  static String buildApiKey(String suffix) => '$apiPrefix$suffix';

  /// Build encryption key with custom suffix
  ///
  /// Example: `buildEncryptionKey('master')` returns `'encryption_master'`
  static String buildEncryptionKey(String suffix) =>
      '$encryptionPrefix$suffix';

  /// Build device key with custom suffix
  ///
  /// Example: `buildDeviceKey('id')` returns `'device_id'`
  static String buildDeviceKey(String suffix) => '$devicePrefix$suffix';

  /// Build temporary key with custom suffix
  ///
  /// Example: `buildTempKey('session')` returns `'temp_session'`
  static String buildTempKey(String suffix) => '$tempPrefix$suffix';

  // ==================== Key Validation ====================

  /// Validate if a key is valid for secure storage
  ///
  /// Returns true if key is:
  /// - Not empty
  /// - Not too long (< 256 characters)
  /// - Contains only safe characters (alphanumeric, underscore, dash, dot)
  static bool isValidKey(String key) {
    if (key.isEmpty) return false;
    if (key.length > 255) return false;

    // Allow alphanumeric, underscore, dash, dot
    final regex = RegExp(r'^[a-zA-Z0-9_\-.]+$');
    return regex.hasMatch(key);
  }

  /// Sanitize a key to make it safe for secure storage
  ///
  /// - Replaces invalid characters with underscore
  /// - Truncates to 255 characters
  /// - Converts to lowercase
  static String sanitizeKey(String key) {
    // Replace invalid characters with underscore
    var sanitized = key.replaceAll(RegExp(r'[^a-zA-Z0-9_\-.]'), '_');

    // Convert to lowercase
    sanitized = sanitized.toLowerCase();

    // Truncate if too long
    if (sanitized.length > 255) {
      sanitized = sanitized.substring(0, 255);
    }

    return sanitized;
  }

  // ==================== Common Key Groups ====================

  /// List of all authentication-related keys
  static List<String> get authKeys => [
        authToken,
        refreshToken,
        accessToken,
        sessionId,
        oauthState,
        oauthCodeVerifier,
      ];

  /// List of all user-related keys
  static List<String> get userKeys => [
        userId,
        userEmail,
        pinCode,
        biometricKey,
      ];

  /// List of all API-related keys
  static List<String> get apiKeys => [
        apiKey,
        apiSecret,
      ];

  /// List of all device-related keys
  static List<String> get deviceKeys => [
        deviceId,
        fcmToken,
      ];

  /// List of all sensitive keys (should be deleted on logout)
  static List<String> get sensitiveKeys => [
        ...authKeys,
        ...userKeys,
        ...apiKeys,
      ];
}


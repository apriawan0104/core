/// Platform-specific options for secure storage operations.
///
/// This class provides configuration options for different platforms:
/// - iOS/macOS: Keychain accessibility options
/// - Android: EncryptedSharedPreferences vs KeyStore
/// - All platforms: Group IDs, custom parameters
///
/// **Dependency Independence**: These are our own types, not third-party types.
/// Different implementations can map these to their specific platform options.
///
/// Example usage:
/// ```dart
/// // iOS Keychain with first unlock accessibility
/// final iosOptions = SecureStorageOptions(
///   accessibility: KeychainAccessibility.firstUnlock,
///   accountName: 'user@example.com',
/// );
///
/// // Android with EncryptedSharedPreferences
/// final androidOptions = SecureStorageOptions(
///   useEncryptedSharedPreferences: true,
/// );
///
/// // macOS with keychain access group
/// final macOsOptions = SecureStorageOptions(
///   accessGroup: 'group.com.example.app',
///   accessibility: KeychainAccessibility.unlocked,
/// );
/// ```
class SecureStorageOptions {
  /// iOS/macOS Keychain accessibility level.
  ///
  /// Determines when the stored data can be accessed:
  /// - `unlocked`: Only when device is unlocked (most secure)
  /// - `firstUnlock`: After first unlock, then always (recommended)
  /// - `firstUnlockThisDeviceOnly`: Like firstUnlock, but doesn't backup to iCloud
  ///
  /// Default: [KeychainAccessibility.unlocked]
  final KeychainAccessibility? accessibility;

  /// Android: Use EncryptedSharedPreferences instead of KeyStore.
  ///
  /// EncryptedSharedPreferences (requires Android API 23+):
  /// - Simpler encryption model
  /// - Automatic key management
  /// - Better compatibility
  ///
  /// KeyStore (traditional, API 18+):
  /// - More complex but more control
  /// - RSA + AES encryption
  ///
  /// Default: false (use KeyStore)
  ///
  /// **Note**: Once you choose one, stick with it! Mixing both will cause errors.
  final bool? useEncryptedSharedPreferences;

  /// iOS/macOS: Keychain access group for sharing data between apps.
  ///
  /// Allows multiple apps from the same developer to share keychain items.
  /// Requires proper app entitlements configuration.
  ///
  /// Example: 'group.com.example.myapp'
  final String? accessGroup;

  /// iOS: Whether to synchronize this item with iCloud Keychain.
  ///
  /// When true, the item will be synced across user's devices via iCloud.
  /// Use false for device-specific secrets.
  ///
  /// Default: false
  final bool? iCloudSync;

  /// Account name associated with the stored item.
  ///
  /// Useful for organizing items by user or account.
  /// Example: user email, user ID, etc.
  final String? accountName;

  /// Web: Custom web-specific options.
  ///
  /// WebCrypto is experimental and has limitations.
  final Map<String, dynamic>? webOptions;

  /// Additional platform-specific parameters.
  ///
  /// For future extensibility and custom implementations.
  final Map<String, dynamic>? customParameters;

  const SecureStorageOptions({
    this.accessibility,
    this.useEncryptedSharedPreferences,
    this.accessGroup,
    this.iCloudSync,
    this.accountName,
    this.webOptions,
    this.customParameters,
  });

  /// Create options with default values for maximum security.
  ///
  /// - iOS/macOS: `unlocked` accessibility (most secure)
  /// - Android: KeyStore with RSA+AES encryption
  /// - No iCloud sync (device-only)
  factory SecureStorageOptions.maximumSecurity() {
    return const SecureStorageOptions(
      accessibility: KeychainAccessibility.unlocked,
      useEncryptedSharedPreferences: false,
      iCloudSync: false,
    );
  }

  /// Create options with balanced security and usability.
  ///
  /// - iOS/macOS: `firstUnlock` accessibility (recommended)
  /// - Android: EncryptedSharedPreferences (simpler)
  /// - No iCloud sync
  factory SecureStorageOptions.balanced() {
    return const SecureStorageOptions(
      accessibility: KeychainAccessibility.firstUnlock,
      useEncryptedSharedPreferences: true,
      iCloudSync: false,
    );
  }

  /// Create options for development/testing.
  ///
  /// - More permissive settings for easier debugging
  /// - Not recommended for production!
  factory SecureStorageOptions.development() {
    return const SecureStorageOptions(
      accessibility: KeychainAccessibility.always,
      useEncryptedSharedPreferences: true,
      iCloudSync: false,
    );
  }

  /// Copy with new values.
  SecureStorageOptions copyWith({
    KeychainAccessibility? accessibility,
    bool? useEncryptedSharedPreferences,
    String? accessGroup,
    bool? iCloudSync,
    String? accountName,
    Map<String, dynamic>? webOptions,
    Map<String, dynamic>? customParameters,
  }) {
    return SecureStorageOptions(
      accessibility: accessibility ?? this.accessibility,
      useEncryptedSharedPreferences:
          useEncryptedSharedPreferences ?? this.useEncryptedSharedPreferences,
      accessGroup: accessGroup ?? this.accessGroup,
      iCloudSync: iCloudSync ?? this.iCloudSync,
      accountName: accountName ?? this.accountName,
      webOptions: webOptions ?? this.webOptions,
      customParameters: customParameters ?? this.customParameters,
    );
  }

  @override
  String toString() {
    return 'SecureStorageOptions('
        'accessibility: $accessibility, '
        'useEncryptedSharedPreferences: $useEncryptedSharedPreferences, '
        'accessGroup: $accessGroup, '
        'iCloudSync: $iCloudSync, '
        'accountName: $accountName'
        ')';
  }
}

/// iOS/macOS Keychain accessibility levels.
///
/// Determines when stored data can be accessed from the keychain.
///
/// **Security vs Usability Trade-off:**
/// - More secure = less convenient (requires unlock more often)
/// - Less secure = more convenient (accessible more often)
///
/// **Recommendation**: Use `firstUnlock` for most use cases.
///
/// References:
/// - iOS: kSecAttrAccessible constants
/// - https://developer.apple.com/documentation/security/ksecattraccessible
enum KeychainAccessibility {
  /// Data can only be accessed when device is unlocked.
  ///
  /// **Most Secure**: Data becomes inaccessible when device locks.
  ///
  /// **Use for:**
  /// - Highly sensitive data
  /// - Data only needed when app is in foreground
  ///
  /// **Limitations:**
  /// - Background tasks cannot access data when device is locked
  /// - Push notification handlers may fail if device is locked
  ///
  /// Maps to: `kSecAttrAccessibleWhenUnlocked`
  unlocked,

  /// Data can only be accessed when device is unlocked.
  /// This data will NOT be backed up to iCloud/iTunes.
  ///
  /// **Most Secure + No Backup**: Like [unlocked] but device-only.
  ///
  /// **Use for:**
  /// - Highly sensitive device-specific data
  /// - Data that should not leave the device
  ///
  /// Maps to: `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
  unlockedThisDeviceOnly,

  /// Data can be accessed after first unlock since device boot.
  /// Remains accessible even when device is subsequently locked.
  ///
  /// **Recommended for most apps**: Good balance of security and usability.
  ///
  /// **Use for:**
  /// - Authentication tokens
  /// - API keys
  /// - Most app secrets
  ///
  /// **Benefits:**
  /// - Background tasks can access data
  /// - Push notification handlers work
  /// - Sync operations can run in background
  ///
  /// **Security:**
  /// - Protected when device is powered off or restarted
  /// - Accessible after user unlocks device once
  ///
  /// Maps to: `kSecAttrAccessibleAfterFirstUnlock`
  firstUnlock,

  /// Like [firstUnlock] but this data will NOT be backed up to iCloud/iTunes.
  ///
  /// **Recommended + No Backup**: Like [firstUnlock] but device-only.
  ///
  /// **Use for:**
  /// - Device-specific tokens
  /// - Data that should not sync across devices
  ///
  /// Maps to: `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`
  firstUnlockThisDeviceOnly,

  /// Data is always accessible, even when device is locked.
  ///
  /// **Least Secure**: Use only when absolutely necessary!
  ///
  /// **⚠️ Warning**: This defeats the purpose of secure storage!
  ///
  /// **Use ONLY for:**
  /// - Non-sensitive data that must always be accessible
  /// - Development/testing (never in production!)
  ///
  /// **Do NOT use for:**
  /// - Passwords
  /// - Tokens
  /// - API keys
  /// - Any sensitive data
  ///
  /// Maps to: `kSecAttrAccessibleAlways`
  @Deprecated('This is not secure. Use firstUnlock instead.')
  always,

  /// Like [always] but this data will NOT be backed up to iCloud/iTunes.
  ///
  /// **Least Secure + No Backup**: Like [always] but device-only.
  ///
  /// ⚠️ Still not recommended for sensitive data!
  ///
  /// Maps to: `kSecAttrAccessibleAlwaysThisDeviceOnly`
  @Deprecated('This is not secure. Use firstUnlockThisDeviceOnly instead.')
  alwaysThisDeviceOnly,

  /// Data becomes accessible only when passcode is set and device is unlocked.
  ///
  /// **Extra Security**: Requires device passcode to be set.
  ///
  /// **Use for:**
  /// - Highly sensitive data requiring device passcode
  /// - Enterprise/security-focused apps
  ///
  /// **Limitations:**
  /// - Only works if user has set a device passcode
  /// - Will fail if no passcode is set
  ///
  /// Maps to: `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`
  passcodeSetThisDeviceOnly,
}


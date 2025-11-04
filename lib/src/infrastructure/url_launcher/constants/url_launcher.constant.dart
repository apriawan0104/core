/// Constants for URL launcher service
class UrlLauncherConstants {
  // Private constructor to prevent instantiation
  UrlLauncherConstants._();

  // ========================================
  // URL Schemes
  // ========================================

  /// HTTP URL scheme
  static const String schemeHttp = 'http';

  /// HTTPS URL scheme
  static const String schemeHttps = 'https';

  /// Email (mailto) URL scheme
  static const String schemeMailto = 'mailto';

  /// Phone (tel) URL scheme
  static const String schemeTel = 'tel';

  /// SMS URL scheme
  static const String schemeSms = 'sms';

  /// File URL scheme (for desktop platforms)
  static const String schemeFile = 'file';

  // ========================================
  // Common URLs
  // ========================================

  /// Privacy Policy template
  static const String urlPrivacyPolicy = 'https://example.com/privacy';

  /// Terms of Service template
  static const String urlTermsOfService = 'https://example.com/terms';

  /// Support email template
  static const String emailSupport = 'support@example.com';

  // ========================================
  // Error Messages
  // ========================================

  /// Error message when URL cannot be launched
  static const String errorCannotLaunch = 'Cannot launch URL';

  /// Error message when URL is invalid
  static const String errorInvalidUrl = 'Invalid URL format';

  /// Error message when launch mode is not supported
  static const String errorLaunchModeNotSupported =
      'Launch mode not supported on this platform';

  /// Error message when URL scheme is not supported
  static const String errorSchemeNotSupported =
      'URL scheme not supported on this platform';

  // ========================================
  // Configuration Keys
  // ========================================

  /// Key for storing default launch mode preference
  static const String keyDefaultLaunchMode = 'url_launcher_default_mode';

  /// Key for storing whether to use external browser by default
  static const String keyUseExternalBrowser = 'url_launcher_use_external';

  // ========================================
  // Platform Configuration Notes
  // ========================================

  /// iOS: Required Info.plist configuration
  static const String iosConfigNote = '''
Add URL schemes to Info.plist:
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>https</string>
  <string>http</string>
  <string>mailto</string>
  <string>tel</string>
  <string>sms</string>
</array>
''';

  /// Android: Required AndroidManifest.xml configuration
  static const String androidConfigNote = '''
Add queries to AndroidManifest.xml (for API 30+):
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
  </intent>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="http" />
  </intent>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="mailto" />
  </intent>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="tel" />
  </intent>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="sms" />
  </intent>
  <intent>
    <action android:name="android.support.customtabs.action.CustomTabsService" />
  </intent>
</queries>
''';
}


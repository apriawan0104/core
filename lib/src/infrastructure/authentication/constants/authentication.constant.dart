/// Authentication service constants
class AuthenticationConstants {
  /// Private constructor to prevent instantiation
  const AuthenticationConstants._();

  /// Default timeout for authentication operations (in seconds)
  static const int defaultTimeout = 60;

  /// Common OAuth scopes
  static const String scopeEmail = 'email';
  static const String scopeProfile = 'profile';
  static const String scopeOpenId = 'openid';

  /// Google OAuth scopes
  static const String googleScopeUserInfo =
      'https://www.googleapis.com/auth/userinfo.email';
  static const String googleScopeUserProfile =
      'https://www.googleapis.com/auth/userinfo.profile';
  static const String googleScopeDrive =
      'https://www.googleapis.com/auth/drive.readonly';
  static const String googleScopeCalendar =
      'https://www.googleapis.com/auth/calendar.readonly';

  /// Apple Sign In scopes
  static const String appleScopeEmail = 'email';
  static const String appleScopeFullName = 'fullName';

  /// Azure AD OAuth scopes
  static const String azureScopeUserRead = 'User.Read';
  static const String azureScopeUserReadAll = 'User.ReadBasic.All';
  static const String azureScopeMailRead = 'Mail.Read';
  static const String azureScopeMailSend = 'Mail.Send';
  static const String azureScopeCalendarRead = 'Calendars.Read';
  static const String azureScopeCalendarReadWrite = 'Calendars.ReadWrite';
  static const String azureScopeFilesRead = 'Files.Read';
  static const String azureScopeFilesReadAll = 'Files.Read.All';

  /// Azure AD tenant types
  static const String azureTenantCommon = 'common';
  static const String azureTenantOrganizations = 'organizations';
  static const String azureTenantConsumers = 'consumers';

  /// Token expiration buffer (in seconds)
  /// Refresh token this many seconds before actual expiration
  static const int tokenExpirationBuffer = 300; // 5 minutes

  /// Max retry attempts for failed authentication
  static const int maxRetryAttempts = 3;

  /// Delay between retry attempts (in milliseconds)
  static const int retryDelayMs = 1000;

  /// Error messages
  static const String errorUserCancelled = 'User cancelled the authentication flow';
  static const String errorInvalidCredentials = 'Invalid credentials provided';
  static const String errorAccountExists = 'An account with this email already exists';
  static const String errorAccountNotFound = 'No account found with the provided credentials';
  static const String errorNetworkError = 'Network error occurred during authentication';
  static const String errorTokenExpired = 'Authentication token has expired';
  static const String errorConfigurationError = 'Authentication provider is not properly configured';
  static const String errorProviderNotAvailable =
      'This authentication provider is not available on the current platform';
}

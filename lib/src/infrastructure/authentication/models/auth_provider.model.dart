/// Authentication provider types
///
/// Represents the different authentication providers supported by the app.
enum AuthProvider {
  /// Google Sign In
  google,

  /// Apple Sign In
  apple,

  /// Azure Active Directory OAuth
  azure,

  /// Email and password
  email,

  /// Anonymous
  anonymous,

  /// Custom provider
  custom,
}

/// Extension for [AuthProvider] to provide utility methods
extension AuthProviderExtension on AuthProvider {
  /// Returns the string representation of the provider
  String get displayName {
    switch (this) {
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
      case AuthProvider.azure:
        return 'Azure';
      case AuthProvider.email:
        return 'Email';
      case AuthProvider.anonymous:
        return 'Anonymous';
      case AuthProvider.custom:
        return 'Custom';
    }
  }

  /// Returns the provider ID as string
  String get id {
    switch (this) {
      case AuthProvider.google:
        return 'google.com';
      case AuthProvider.apple:
        return 'apple.com';
      case AuthProvider.azure:
        return 'microsoft.com';
      case AuthProvider.email:
        return 'password';
      case AuthProvider.anonymous:
        return 'anonymous';
      case AuthProvider.custom:
        return 'custom';
    }
  }
}


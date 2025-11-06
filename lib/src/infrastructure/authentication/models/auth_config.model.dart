import 'package:equatable/equatable.dart';

/// Configuration for authentication providers
class AuthConfig extends Equatable {
  /// Client ID for the authentication provider
  final String? clientId;

  /// Client secret (if needed)
  final String? clientSecret;

  /// Redirect URI for OAuth flows
  final String? redirectUri;

  /// Scopes to request
  final List<String>? scopes;

  /// Server client ID (for server-side authentication)
  final String? serverClientId;

  /// Whether to request server auth code
  final bool requestServerAuthCode;

  /// Whether to request offline access (refresh token)
  final bool requestOfflineAccess;

  /// Additional provider-specific configuration
  final Map<String, dynamic>? additionalConfig;

  const AuthConfig({
    this.clientId,
    this.clientSecret,
    this.redirectUri,
    this.scopes,
    this.serverClientId,
    this.requestServerAuthCode = false,
    this.requestOfflineAccess = false,
    this.additionalConfig,
  });

  /// Copy with method
  AuthConfig copyWith({
    String? clientId,
    String? clientSecret,
    String? redirectUri,
    List<String>? scopes,
    String? serverClientId,
    bool? requestServerAuthCode,
    bool? requestOfflineAccess,
    Map<String, dynamic>? additionalConfig,
  }) {
    return AuthConfig(
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
      redirectUri: redirectUri ?? this.redirectUri,
      scopes: scopes ?? this.scopes,
      serverClientId: serverClientId ?? this.serverClientId,
      requestServerAuthCode:
          requestServerAuthCode ?? this.requestServerAuthCode,
      requestOfflineAccess: requestOfflineAccess ?? this.requestOfflineAccess,
      additionalConfig: additionalConfig ?? this.additionalConfig,
    );
  }

  @override
  List<Object?> get props => [
        clientId,
        clientSecret,
        redirectUri,
        scopes,
        serverClientId,
        requestServerAuthCode,
        requestOfflineAccess,
        additionalConfig,
      ];
}


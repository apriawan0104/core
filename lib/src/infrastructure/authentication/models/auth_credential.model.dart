import 'package:equatable/equatable.dart';

import 'auth_user.model.dart';

/// Represents authentication credentials returned by a provider
///
/// This contains tokens and additional data needed for authentication
class AuthCredential extends Equatable {
  /// The authenticated user
  final AuthUser user;

  /// Access token for API calls
  final String? accessToken;

  /// ID token (JWT) for verifying identity
  final String? idToken;

  /// Refresh token for getting new access tokens
  final String? refreshToken;

  /// Authorization code (for server-side validation)
  final String? authorizationCode;

  /// Server auth code (for backend authentication)
  final String? serverAuthCode;

  /// Token expiration time
  final DateTime? expiresAt;

  /// Additional scopes granted
  final List<String>? grantedScopes;

  /// Additional provider-specific data
  final Map<String, dynamic>? additionalData;

  const AuthCredential({
    required this.user,
    this.accessToken,
    this.idToken,
    this.refreshToken,
    this.authorizationCode,
    this.serverAuthCode,
    this.expiresAt,
    this.grantedScopes,
    this.additionalData,
  });

  /// Whether the token is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Copy with method
  AuthCredential copyWith({
    AuthUser? user,
    String? accessToken,
    String? idToken,
    String? refreshToken,
    String? authorizationCode,
    String? serverAuthCode,
    DateTime? expiresAt,
    List<String>? grantedScopes,
    Map<String, dynamic>? additionalData,
  }) {
    return AuthCredential(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      idToken: idToken ?? this.idToken,
      refreshToken: refreshToken ?? this.refreshToken,
      authorizationCode: authorizationCode ?? this.authorizationCode,
      serverAuthCode: serverAuthCode ?? this.serverAuthCode,
      expiresAt: expiresAt ?? this.expiresAt,
      grantedScopes: grantedScopes ?? this.grantedScopes,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  List<Object?> get props => [
        user,
        accessToken,
        idToken,
        refreshToken,
        authorizationCode,
        serverAuthCode,
        expiresAt,
        grantedScopes,
        additionalData,
      ];

  @override
  String toString() {
    return 'AuthCredential(user: ${user.id}, hasAccessToken: ${accessToken != null}, '
        'hasIdToken: ${idToken != null}, isExpired: $isExpired)';
  }
}


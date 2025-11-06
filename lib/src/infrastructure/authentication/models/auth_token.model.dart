/// Authentication token model
///
/// Contains authentication tokens and related information.
/// This model is provider-independent.
class AuthToken {
  /// Access token for API requests
  final String accessToken;

  /// Refresh token to get new access tokens
  final String? refreshToken;

  /// ID token (JWT) containing user information
  final String? idToken;

  /// Token type (usually "Bearer")
  final String? tokenType;

  /// Expiration timestamp of the access token
  final DateTime? expiresAt;

  /// Scopes granted for this token
  final List<String>? scopes;

  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    this.tokenType,
    this.expiresAt,
    this.scopes,
  });

  /// Whether the token has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Whether the token is still valid (not expired)
  bool get isValid => !isExpired;

  /// Time remaining until token expires
  Duration? get timeUntilExpiry {
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now());
  }

  /// Creates a copy of this token with updated fields
  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    String? idToken,
    String? tokenType,
    DateTime? expiresAt,
    List<String>? scopes,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      idToken: idToken ?? this.idToken,
      tokenType: tokenType ?? this.tokenType,
      expiresAt: expiresAt ?? this.expiresAt,
      scopes: scopes ?? this.scopes,
    );
  }

  /// Converts this token to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'idToken': idToken,
      'tokenType': tokenType,
      'expiresAt': expiresAt?.toIso8601String(),
      'scopes': scopes,
    };
  }

  /// Creates a token from a JSON map
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      idToken: json['idToken'] as String?,
      tokenType: json['tokenType'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      scopes: (json['scopes'] as List<dynamic>?)?.cast<String>(),
    );
  }

  @override
  String toString() {
    return 'AuthToken(tokenType: $tokenType, isExpired: $isExpired, '
        'scopes: $scopes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthToken && other.accessToken == accessToken;
  }

  @override
  int get hashCode => accessToken.hashCode;
}


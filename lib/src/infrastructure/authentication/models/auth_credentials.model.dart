import 'auth_provider.model.dart';
import 'auth_token.model.dart';
import 'auth_user.model.dart';

/// Authentication credentials result
///
/// Contains the complete authentication result including user, token, and provider info.
/// This is returned after a successful authentication.
class AuthCredentials {
  /// Authenticated user information
  final AuthUser user;

  /// Authentication token
  final AuthToken? token;

  /// Provider used for authentication
  final AuthProvider provider;

  /// Server authentication code (for backend verification)
  final String? serverAuthCode;

  /// Whether this is a new user (first time sign in)
  final bool isNewUser;

  /// Additional data from the provider
  final Map<String, dynamic>? additionalData;

  const AuthCredentials({
    required this.user,
    this.token,
    required this.provider,
    this.serverAuthCode,
    this.isNewUser = false,
    this.additionalData,
  });

  /// Creates a copy of these credentials with updated fields
  AuthCredentials copyWith({
    AuthUser? user,
    AuthToken? token,
    AuthProvider? provider,
    String? serverAuthCode,
    bool? isNewUser,
    Map<String, dynamic>? additionalData,
  }) {
    return AuthCredentials(
      user: user ?? this.user,
      token: token ?? this.token,
      provider: provider ?? this.provider,
      serverAuthCode: serverAuthCode ?? this.serverAuthCode,
      isNewUser: isNewUser ?? this.isNewUser,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  /// Converts these credentials to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token?.toJson(),
      'provider': provider.id,
      'serverAuthCode': serverAuthCode,
      'isNewUser': isNewUser,
      'additionalData': additionalData,
    };
  }

  /// Creates credentials from a JSON map
  factory AuthCredentials.fromJson(Map<String, dynamic> json) {
    return AuthCredentials(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] != null
          ? AuthToken.fromJson(json['token'] as Map<String, dynamic>)
          : null,
      provider: _parseProvider(json['provider'] as String?),
      serverAuthCode: json['serverAuthCode'] as String?,
      isNewUser: json['isNewUser'] as bool? ?? false,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  static AuthProvider _parseProvider(String? providerId) {
    switch (providerId) {
      case 'google.com':
        return AuthProvider.google;
      case 'apple.com':
        return AuthProvider.apple;
      case 'microsoft.com':
        return AuthProvider.azure;
      case 'password':
        return AuthProvider.email;
      case 'anonymous':
        return AuthProvider.anonymous;
      default:
        return AuthProvider.custom;
    }
  }

  @override
  String toString() {
    return 'AuthCredentials(user: $user, provider: ${provider.displayName}, '
        'isNewUser: $isNewUser)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthCredentials &&
        other.user == user &&
        other.provider == provider;
  }

  @override
  int get hashCode => user.hashCode ^ provider.hashCode;
}


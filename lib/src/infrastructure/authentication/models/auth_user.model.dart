import 'auth_provider.model.dart';

/// Authenticated user model
///
/// Represents a user that has been authenticated through any provider.
/// This model is provider-independent and contains common user information.
class AuthUser {
  /// User's unique identifier
  final String id;

  /// User's email address (may be null for some providers)
  final String? email;

  /// User's display name
  final String? displayName;

  /// URL to user's profile photo
  final String? photoUrl;

  /// User's phone number
  final String? phoneNumber;

  /// Whether the email has been verified
  final bool emailVerified;

  /// Whether the user is anonymous
  final bool isAnonymous;

  /// Authentication provider used
  final AuthProvider provider;

  /// Provider-specific user ID
  final String? providerUserId;

  /// Additional metadata from provider
  final Map<String, dynamic>? metadata;

  /// Timestamp when user was created
  final DateTime? createdAt;

  /// Timestamp of last sign in
  final DateTime? lastSignInAt;

  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.emailVerified = false,
    this.isAnonymous = false,
    required this.provider,
    this.providerUserId,
    this.metadata,
    this.createdAt,
    this.lastSignInAt,
  });

  /// Creates a copy of this user with updated fields
  AuthUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? emailVerified,
    bool? isAnonymous,
    AuthProvider? provider,
    String? providerUserId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      provider: provider ?? this.provider,
      providerUserId: providerUserId ?? this.providerUserId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }

  /// Converts this user to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
      'isAnonymous': isAnonymous,
      'provider': provider.id,
      'providerUserId': providerUserId,
      'metadata': metadata,
      'createdAt': createdAt?.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
    };
  }

  /// Creates a user from a JSON map
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      provider: _parseProvider(json['provider'] as String?),
      providerUserId: json['providerUserId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastSignInAt: json['lastSignInAt'] != null
          ? DateTime.parse(json['lastSignInAt'] as String)
          : null,
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
    return 'AuthUser(id: $id, email: $email, displayName: $displayName, '
        'provider: ${provider.displayName}, emailVerified: $emailVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthUser &&
        other.id == id &&
        other.email == email &&
        other.provider == provider;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ provider.hashCode;
}

import 'dart:async';

import 'package:app_core/app_core.dart';
import 'package:dartz/dartz.dart';

/// Auth service whose refresh waits on [release] and counts calls.
class GateAuthenticationService implements AuthenticationService {
  int refreshCalls = 0;
  final release = Completer<void>();

  @override
  Future<ValueGuard<AuthToken>> refreshToken() async {
    refreshCalls++;
    await release.future;
    return Right(AuthToken(accessToken: 'token-$refreshCalls'));
  }

  @override
  Future<ValueGuard<bool>> isSignedIn() async => const Right(true);

  @override
  Future<ValueGuard<void>> initialize() => throw UnimplementedError();

  @override
  Future<ValueGuard<AuthCredentials>> signInWithGoogle({
    List<String>? scopes,
    String? hostedDomain,
  }) =>
      throw UnimplementedError();

  @override
  Future<ValueGuard<AuthCredentials>> signInWithApple({
    List<String>? scopes,
  }) =>
      throw UnimplementedError();

  @override
  Future<ValueGuard<AuthCredentials>> signInWithAzure({
    List<String>? scopes,
    String? tenantId,
  }) =>
      throw UnimplementedError();

  @override
  Future<ValueGuard<AuthCredentials>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<ValueGuard<AuthCredentials>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) =>
      throw UnimplementedError();

  @override
  Future<ValueGuard<void>> signOut() => throw UnimplementedError();

  @override
  Future<ValueGuard<AuthUser?>> getCurrentUser() => throw UnimplementedError();

  @override
  Stream<AuthUser?> get authStateChanges => const Stream.empty();

  @override
  Future<ValueGuard<AuthToken>> getAuthToken() => throw UnimplementedError();

  @override
  Future<ValueGuard<void>> deleteAccount() => throw UnimplementedError();

  @override
  Future<ValueGuard<void>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) =>
      throw UnimplementedError();

  @override
  Future<ValueGuard<void>> sendPasswordResetEmail({required String email}) =>
      throw UnimplementedError();

  @override
  Future<ValueGuard<void>> sendEmailVerification() =>
      throw UnimplementedError();

  @override
  Future<ValueGuard<AuthUser>> reloadUser() => throw UnimplementedError();

  @override
  Future<ValueGuard<AuthUser>> linkWithProvider({
    required AuthProvider provider,
    required AuthCredentials credentials,
  }) =>
      throw UnimplementedError();

  @override
  Future<ValueGuard<AuthUser>> unlinkProvider(AuthProvider provider) =>
      throw UnimplementedError();

  @override
  Future<ValueGuard<void>> dispose() => throw UnimplementedError();
}

/// In-memory secure storage. Only the keys the token provider uses are real.
class MemoryStorage implements SecureStorageService {
  MemoryStorage([Map<String, String>? values]) : values = values ?? {};

  final Map<String, String> values;

  @override
  Future<Either<SecureStorageFailure, bool>> containsKey({
    required String key,
    SecureStorageOptions? options,
  }) async =>
      Right(values.containsKey(key));

  @override
  Future<Either<SecureStorageFailure, void>> write({
    required String key,
    required String value,
    SecureStorageOptions? options,
  }) async {
    values[key] = value;
    return const Right(null);
  }

  @override
  Future<Either<SecureStorageFailure, String?>> read({
    required String key,
    SecureStorageOptions? options,
  }) async =>
      Right(values[key]);

  @override
  Future<Either<SecureStorageFailure, Map<String, String>>> readAll({
    SecureStorageOptions? options,
  }) async =>
      Right(values);

  @override
  Future<Either<SecureStorageFailure, void>> delete({
    required String key,
    SecureStorageOptions? options,
  }) async {
    values.remove(key);
    return const Right(null);
  }

  @override
  Future<Either<SecureStorageFailure, void>> deleteAll({
    SecureStorageOptions? options,
  }) async {
    values.clear();
    return const Right(null);
  }

  @override
  Future<Either<SecureStorageFailure, List<String>>> getAllKeys({
    SecureStorageOptions? options,
  }) async =>
      Right(values.keys.toList());
}

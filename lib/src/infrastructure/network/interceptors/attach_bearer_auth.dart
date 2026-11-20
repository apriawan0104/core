import '../../authentication/contract/contracts.dart';
import '../contract/contracts.dart';
import 'auth.interceptor.dart';

/// Attaches bearer-token injection to [client].
///
/// [client] stays independent of the login provider. Pass
/// [TokenProviderServiceImpl] for Google or Apple, or the provider from
/// `bspace_auth` for Microsoft. That provider refreshes the access token
/// before the request is sent, and the refresh does not go through [client].
/// A 401 from an authenticated endpoint refreshes that provider once and
/// sends the same request again. A second 401 is returned to the caller.
///
/// Apple Sign In in this package cannot renew a token on the device. A cached
/// token is still attached while it is valid. After it expires, refresh fails
/// and the 401 is returned without a second call.
void attachBearerAuth(
  HttpClient client,
  TokenProviderService tokenProvider, {
  List<String>? excludedPaths,
}) {
  final skipped = excludedPaths ?? const <String>[];
  client.addRequestInterceptor(
    AuthInterceptor(
      tokenProvider: tokenProvider,
      excludedPaths: skipped,
    ).onRequest,
  );
  client.setUnauthorizedRecovery((url, rejectedAccessToken) async {
    if (skipped.any(url.contains)) return null;
    // Another request may have refreshed while this 401 was in flight.
    final current = (await tokenProvider.getAccessToken()).fold<String?>(
      (_) => null,
      (token) => token,
    );
    if (current != null && current != rejectedAccessToken) return current;

    final refreshed = await tokenProvider.refreshToken();
    return refreshed.fold<String?>(
      (_) => null,
      (token) => token.accessToken.isEmpty ? null : token.accessToken,
    );
  });
}

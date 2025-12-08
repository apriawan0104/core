// ignore_for_file: avoid_print

import 'package:app_core/app_core.dart';
import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';

/// Bearer Token Authentication Example
///
/// This example demonstrates how to:
/// 1. Setup authentication services with bearer token support
/// 2. Configure HTTP client with automatic token injection
/// 3. Make authenticated API requests
/// 4. Handle token refresh automatically
/// 5. Clear tokens on logout
///
/// For more details, see:
/// - BEARER_TOKEN_SETUP.md
/// - lib/src/infrastructure/authentication/doc/
/// - lib/src/infrastructure/network/doc/

final getIt = GetIt.instance;

void main() async {
  print('🔐 Bearer Token Authentication Example\n');

  // Step 1: Setup Dependencies
  setupDependencies();

  // Step 2: Login (Get Initial Token)
  await loginExample();

  // Step 3: Make Authenticated Requests
  await authenticatedRequestExample();

  // Step 4: Check Token Status
  await tokenStatusExample();

  // Step 5: Manual Token Refresh
  await tokenRefreshExample();

  // Step 6: Logout (Clear Tokens)
  await logoutExample();
}

/// Setup dependency injection
void setupDependencies() {
  print('📦 Setting up dependencies...\n');

  // 1. Register SecureStorage
  getIt.registerLazySingleton<SecureStorageService>(
    () => FlutterSecureStorageServiceImpl(),
  );

  // 2. Register AuthenticationService
  // Using Google Auth as example (can be Azure, Apple, Firebase, etc.)
  getIt.registerLazySingleton<AuthenticationService>(
    () => GoogleAuthenticationServiceImpl(
      scopes: ['email', 'profile'],
    ),
  );

  // 3. Register TokenProvider
  getIt.registerLazySingleton<TokenProviderService>(
    () => TokenProviderServiceImpl(
      authService: getIt<AuthenticationService>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );

  // 4. Create AuthInterceptor
  final authInterceptor = AuthInterceptor(
    tokenProvider: getIt<TokenProviderService>(),
    excludedPaths: [
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
      '/auth/refresh',
      '/public',
      '/health',
    ],
  );

  // 5. Register HttpClient with AuthInterceptor
  getIt.registerLazySingleton<HttpClient>(
    () {
      final client = DioHttpClient(
        baseUrl: 'https://api.example.com',
        connectTimeout: 30000,
        receiveTimeout: 30000,
        enableLogging: true,
      );

      // Add auth interceptor to automatically inject bearer tokens
      client.addRequestInterceptor(authInterceptor.onRequest);

      return client;
    },
  );

  print('✅ Dependencies setup complete!\n');
}

/// Example: Login and get bearer token
Future<void> loginExample() async {
  print('👤 Login Example\n');

  final authService = getIt<AuthenticationService>();

  // Sign in with email and password
  final loginResult = await authService.signInWithEmailAndPassword(
    email: 'user@example.com',
    password: 'password123',
  );

  loginResult.fold(
    (failure) {
      print('❌ Login failed: $failure');
    },
    (credentials) {
      print('✅ Login successful!');
      print('   User: ${credentials.user.email}');
      print(
          '   Access Token: ${credentials.user.email != null ? "Saved securely" : "N/A"}');
      print('   Token is automatically saved to secure storage\n');
    },
  );
}

/// Example: Make authenticated API request
Future<void> authenticatedRequestExample() async {
  print('🌐 Authenticated Request Example\n');

  final httpClient = getIt<HttpClient>();

  // Make GET request to protected endpoint
  // Bearer token is AUTOMATICALLY injected by AuthInterceptor!
  final result = await httpClient.get<Map<String, dynamic>>(
    '/user/profile',
  );

  result.fold(
    (failure) {
      print('❌ Request failed: $failure');
    },
    (response) {
      print('✅ Request successful!');
      print('   Status: ${response.statusCode}');
      print('   Data: ${response.data}');
      print('   Bearer token was automatically added to headers\n');
    },
  );

  // Make POST request with data
  final postResult = await httpClient.post<Map<String, dynamic>>(
    '/user/settings',
    data: {
      'theme': 'dark',
      'notifications': true,
    },
  );

  postResult.fold(
    (failure) {
      print('❌ POST request failed: $failure');
    },
    (response) {
      print('✅ POST request successful!');
      print('   Updated settings with authenticated request\n');
    },
  );
}

/// Example: Check token status
Future<void> tokenStatusExample() async {
  print('🔍 Token Status Example\n');

  final tokenProvider = getIt<TokenProviderService>();

  // Check if user has valid token
  final hasTokenResult = await tokenProvider.hasValidToken();

  hasTokenResult.fold(
    (failure) {
      print('❌ Error checking token: $failure');
    },
    (hasToken) {
      print('Token Status: ${hasToken ? "✅ Valid" : "❌ Invalid/Expired"}');
    },
  );

  // Get full token information
  final tokenResult = await tokenProvider.getAuthToken();

  tokenResult.fold(
    (failure) {
      print('❌ Error getting token: $failure');
    },
    (token) {
      print('Token Details:');
      print('   Type: ${token.tokenType ?? "Bearer"}');
      print('   Expires At: ${token.expiresAt}');
      print('   Is Valid: ${token.isValid ? "Yes" : "No"}');
      print('   Time Until Expiry: ${token.timeUntilExpiry}');
      print(
          '   Has Refresh Token: ${token.refreshToken != null ? "Yes" : "No"}\n');
    },
  );
}

/// Example: Manual token refresh
Future<void> tokenRefreshExample() async {
  print('🔄 Token Refresh Example\n');

  final tokenProvider = getIt<TokenProviderService>();

  print('Refreshing token...');
  final refreshResult = await tokenProvider.refreshToken();

  refreshResult.fold(
    (failure) {
      print('❌ Token refresh failed: $failure');
      print('   User may need to re-login\n');
    },
    (newToken) {
      print('✅ Token refreshed successfully!');
      print('   New Expires At: ${newToken.expiresAt}');
      print('   Note: Refresh happens automatically when needed\n');
    },
  );
}

/// Example: Logout and clear tokens
Future<void> logoutExample() async {
  print('🚪 Logout Example\n');

  final authService = getIt<AuthenticationService>();
  final tokenProvider = getIt<TokenProviderService>();

  // Sign out from authentication service
  print('Signing out...');
  final signOutResult = await authService.signOut();

  signOutResult.fold(
    (failure) {
      print('❌ Sign out failed: $failure');
    },
    (_) {
      print('✅ Signed out from auth service');
    },
  );

  // Clear cached tokens
  print('Clearing tokens...');
  final clearResult = await tokenProvider.clearTokens();

  clearResult.fold(
    (failure) {
      print('❌ Failed to clear tokens: $failure');
    },
    (_) {
      print('✅ Tokens cleared from secure storage');
      print('   All authentication data removed\n');
    },
  );

  // Verify tokens are cleared
  final hasTokenResult = await tokenProvider.hasValidToken();
  hasTokenResult.fold(
    (failure) => print('Error: $failure'),
    (hasToken) {
      print(
          'Token Status After Logout: ${hasToken ? "❌ Still has token" : "✅ No token"}\n');
    },
  );
}

/// Advanced Example: Custom HTTP Client Configuration
void advancedHttpClientExample() {
  print('⚙️ Advanced HTTP Client Configuration\n');

  final tokenProvider = getIt<TokenProviderService>();

  // Create auth interceptor with custom excluded paths
  final authInterceptor = AuthInterceptor(
    tokenProvider: tokenProvider,
    excludedPaths: [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/public',
      '/health',
      '/api/v1/guest', // Custom excluded path
    ],
  );

  // Create HTTP client with custom configuration
  final httpClient = DioHttpClient(
    baseUrl: 'https://api.example.com',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    connectTimeout: 30000,
    receiveTimeout: 30000,
    sendTimeout: 30000,
    enableLogging: true,
  );

  // Add auth interceptor
  httpClient.addRequestInterceptor(authInterceptor.onRequest);

  // Add custom response interceptor
  httpClient.addResponseInterceptor((response) async {
    print('Response received: ${response.statusCode}');
    return response;
  });

  // Add custom error interceptor
  httpClient.addErrorInterceptor((failure) async {
    print('Error occurred: $failure');

    // Handle 401 Unauthorized
    if (failure is UnauthorizedFailure) {
      print('Token expired or invalid, redirect to login');
      // Navigate to login screen
    }

    // Return error to continue error chain
    return Left(failure);
  });

  print('✅ Advanced HTTP client configured!\n');
}

/// Example: Multiple Authentication Providers
void multipleAuthProvidersExample() {
  print('🔀 Multiple Authentication Providers Example\n');

  // Register based on platform or user preference
  getIt.registerLazySingleton<AuthenticationService>(
    () {
      // Example 1: Google Auth
      // return GoogleAuthenticationServiceImpl(
      //   scopes: ['email', 'profile'],
      // );

      // Example 2: Azure Auth
      // return AzureAuthenticationServiceImpl(
      //   tenantId: 'your-tenant-id',
      //   clientId: 'your-client-id',
      //   redirectUri: 'your-redirect-uri',
      //   scopes: ['User.Read'],
      // );

      // Example 3: Apple Auth
      // return AppleAuthenticationServiceImpl();

      // Default: Google Auth
      return GoogleAuthenticationServiceImpl(
        scopes: ['email', 'profile'],
      );
    },
  );

  // TokenProvider works with any AuthenticationService!
  getIt.registerLazySingleton<TokenProviderService>(
    () => TokenProviderServiceImpl(
      authService: getIt<AuthenticationService>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );

  print('✅ Can easily switch between auth providers!\n');
}

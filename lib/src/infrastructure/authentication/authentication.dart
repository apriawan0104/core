/// Authentication service library
///
/// This library provides authentication services for various providers including:
/// - Google Sign In
/// - Apple Sign In
/// - Azure AD OAuth
///
/// ## Features
///
/// - **Dependency Independent**: Not tied to any specific authentication provider
/// - **Multiple Providers**: Support for Google, Apple, and Azure AD
/// - **Type Safe**: All operations return Either<Failure, Success>
/// - **Stream Support**: Real-time authentication state changes
/// - **Token Management**: Automatic token refresh and validation
/// - **Easy Integration**: Simple DI setup
///
/// ## Quick Start
///
/// ```dart
/// // 1. Register in DI container
/// getIt.registerLazySingleton<AuthenticationService>(
///   () => GoogleAuthenticationServiceImpl(
///     scopes: ['email', 'profile'],
///   ),
/// );
///
/// // 2. Initialize
/// final authService = getIt<AuthenticationService>();
/// await authService.initialize();
///
/// // 3. Sign in
/// final result = await authService.signInWithGoogle();
/// result.fold(
///   (failure) => print('Error: $failure'),
///   (credentials) => print('Signed in: ${credentials.user.email}'),
/// );
///
/// // 4. Listen to auth state
/// authService.authStateChanges.listen((user) {
///   if (user != null) {
///     print('User signed in: ${user.email}');
///   } else {
///     print('User signed out');
///   }
/// });
/// ```
///
/// ## Switching Providers
///
/// To switch authentication providers, just change the DI registration:
///
/// ```dart
/// // From Google
/// getIt.registerLazySingleton<AuthenticationService>(
///   () => GoogleAuthenticationServiceImpl(...),
/// );
///
/// // To Apple (NO CODE CHANGES in business logic!)
/// getIt.registerLazySingleton<AuthenticationService>(
///   () => AppleAuthenticationServiceImpl(...),
/// );
///
/// // To Azure (NO CODE CHANGES in business logic!)
/// getIt.registerLazySingleton<AuthenticationService>(
///   () => AzureAuthenticationServiceImpl(...),
/// );
/// ```
///
/// For detailed documentation, see:
/// - [README.md](doc/README.md)
/// - [QUICK_START.md](doc/QUICK_START.md)
library;

export 'constants/constants.dart';
export 'contract/contracts.dart';
export 'impl/impl.dart';
export 'models/models.dart';

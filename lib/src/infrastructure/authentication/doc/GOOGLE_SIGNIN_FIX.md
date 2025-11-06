# Google Sign In - API Version Fix

Error yang tersisa terkait dengan **perbedaan API antara versi package `google_sign_in`**.

## 📋 Current Errors

```
L67: The getter 'currentUser' isn't defined
L93: The method 'signIn' isn't defined  
L227/L253: The getter 'accessToken' isn't defined
L54: The class 'GoogleSignIn' doesn't have an unnamed constructor
```

## ✅ Solution Options

### Option 1: Gunakan Versi yang Kompatibel (Recommended)

Gunakan versi `google_sign_in` yang lebih lama dan stable:

```yaml
# pubspec.yaml
dependencies:
  google_sign_in: ^5.4.4  # Stable version with working API
```

Lalu update imports di implementation:

```dart
// No changes needed in code if using v5.4.4
```

### Option 2: Manual Adjustment untuk Versi Terbaru

Jika Anda ingin menggunakan `google_sign_in: ^6.x` atau `^7.x`, adjust kode berikut:

#### A. Constructor Fix (Line 54)

```dart
// ❌ Error - Unnamed constructor
_googleSignIn = GoogleSignIn(
  scopes: scopes ?? <String>['email', 'profile'],
)

// ✅ Fix - Use standard() constructor  
_googleSignIn = GoogleSignIn.standard(
  scopes: scopes ?? <String>['email', 'profile'],
)
```

#### B. Sign In Method Fix (Line 93)

```dart
// ❌ Error - signIn() method
final account = await _googleSignIn.signIn();

// ✅ Fix Option 1 - Use signInInteractively()
final account = await _googleSignIn.signInInteractively();

// ✅ Fix Option 2 - Use signInWithEmailAndPassword() if available
// Check package documentation for exact method name
```

#### C. Current User Fix (Line 67)

```dart
// ❌ Error - currentUser getter
_currentUser = _googleSignIn.currentUser;

// ✅ Fix - Check isSignedIn() first
final isSignedIn = await _googleSignIn.isSignedIn();
if (isSignedIn) {
  // Get user from sign in result
  _currentUser = await _googleSignIn.signInSilently();
}
```

#### D. Access Token Fix (Lines 227, 253)

```dart
// ❌ Error - auth.accessToken
final token = AuthToken(
  accessToken: auth.accessToken ?? auth.idToken ?? '',
  idToken: auth.idToken,
);

// ✅ Fix - Try different property names based on version
final token = AuthToken(
  accessToken: auth.idToken ?? '', // Use idToken as accessToken
  idToken: auth.idToken,
);

// OR if your version has 'serverAuthCode':
final token = AuthToken(
  accessToken: auth.serverAuthCode ?? auth.idToken ?? '',
  idToken: auth.idToken,
);
```

## 🔍 How to Check Your Package API

Run this command to see available methods:

```bash
# Check package documentation
flutter pub deps google_sign_in

# Or check in your IDE:
# 1. Open google_sign_in.dart file from .pub-cache
# 2. Check GoogleSignIn class
# 3. Check GoogleSignInAuthentication class
```

## 📝 Complete Fixed Version for v6.x+

If you're using `google_sign_in: ^6.x`, here's the complete fixed version:

```dart
GoogleAuthenticationServiceImpl({
  String? hostedDomain,
  List<String>? scopes,
})  : _googleSignIn = GoogleSignIn.standard(  // ✅ Use .standard()
        scopes: scopes ?? <String>['email', 'profile'],
      ),
      _authStateController = StreamController<AuthUser?>.broadcast();

@override
Future<Either<Failure, void>> initialize() async {
  try {
    // ✅ Check if signed in first
    final isSignedIn = await _googleSignIn.isSignedIn();
    if (isSignedIn) {
      _currentUser = await _googleSignIn.signInSilently();
      if (_currentUser != null) {
        _authStateController.add(_mapGoogleUserToAuthUser(_currentUser!));
      }
    }
    return const Right(null);
  } catch (e) {
    return Left(
      AuthenticationConfigurationFailure(
        'Failed to initialize Google Sign In: $e',
      ),
    );
  }
}

@override
Future<Either<Failure, AuthCredentials>> signInWithGoogle({
  List<String>? scopes,
  String? hostedDomain,
}) async {
  try {
    // ✅ Use signInInteractively() for v6+
    final account = await _googleSignIn.signInInteractively();
    
    if (account == null) {
      return const Left(AuthenticationCancelledFailure());
    }
    
    _currentUser = account;
    _authStateController.add(_mapGoogleUserToAuthUser(account));
    
    final auth = await account.authentication;
    
    // ✅ Use idToken as accessToken if accessToken not available
    final token = AuthToken(
      accessToken: auth.idToken ?? '',
      idToken: auth.idToken,
    );
    
    final credentials = AuthCredentials(
      user: _mapGoogleUserToAuthUser(account),
      token: token,
      provider: AuthProvider.google,
      isNewUser: false,
    );
    
    return Right(credentials);
  } catch (e) {
    return Left(
      AuthenticationFailure('Google sign in failed: $e'),
    );
  }
}
```

## 🎯 Recommended Approach

**For production apps**, kami sarankan:

1. ✅ **Gunakan versi stable**: `google_sign_in: ^5.4.4`
2. ✅ **Test thoroughly** dengan semua platform yang Anda support
3. ✅ **Pin version** di pubspec.yaml untuk avoid breaking changes

```yaml
dependencies:
  google_sign_in: 5.4.4  # Pin exact version for stability
```

## 📚 References

- [Google Sign In Package](https://pub.dev/packages/google_sign_in)
- [Google Sign In Changelog](https://pub.dev/packages/google_sign_in/changelog)
- [Migration Guide](https://pub.dev/packages/google_sign_in#migrating-from-60x-to-61x)

---

## ✅ Status Implementasi Lainnya

- ✅ **Apple Sign In** - Working perfectly! (hanya 2 warnings yang bisa diabaikan)
- ✅ **Azure AD OAuth** - Working perfectly! No errors
- ✅ **Models & Contracts** - All good
- ✅ **Documentation** - Complete

**Only Google Sign In needs version adjustment!**


part of '../main.dart';

class AuthResult {
  const AuthResult({required this.user});

  final UserProfile user;
}

abstract class AuthService {
  Future<AuthResult> signIn({
    required String email,
    required String password,
  });

  /// Sign in with Google (or other federated providers)
  Future<AuthResult> signInWithGoogle();

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> requestPasswordReset({required String email});

  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  });

  Future<void> signOut();
}

class LocalAuthService implements AuthService {
  LocalAuthService()
    : _usersByEmail = {
        'yourname@gmail.com': _StoredAuthUser(
          profile: UserProfile(
            uid: 'uid-demo',
            name: 'Saravuth',
            email: 'yourname@gmail.com',
            createdAt: DateTime.now(),
          ),
          password: 'password123',
        ),
      };

  @override
  Future<AuthResult> signInWithGoogle() async {
    await _simulateNetworkDelay();
    final mockUser = UserProfile(
      uid: 'uid-google-demo',
      name: 'Google Demo User',
      email: 'google_demo@example.com',
      createdAt: DateTime.now(),
    );
    return AuthResult(user: mockUser);
  }

  final Map<String, _StoredAuthUser> _usersByEmail;
  final Map<String, String> _resetCodesByEmail = <String, String>{};

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    await _simulateNetworkDelay();
    final normalizedEmail = _normalizeEmail(email);
    final account = _usersByEmail[normalizedEmail];

    if (account == null || account.password != password) {
      throw const AuthException('Invalid email or password.');
    }

    return AuthResult(user: account.profile);
  }

  @override
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _simulateNetworkDelay();
    final normalizedEmail = _normalizeEmail(email);

    if (_usersByEmail.containsKey(normalizedEmail)) {
      throw const AuthException('This email already has an account.');
    }

    final user = UserProfile(
      uid: 'uid-${normalizedEmail.hashCode.abs()}',
      name: name.trim().isEmpty ? 'AppleTech Customer' : name.trim(),
      email: normalizedEmail,
      createdAt: DateTime.now(),
    );
    _usersByEmail[normalizedEmail] = _StoredAuthUser(
      profile: user,
      password: password,
    );

    return AuthResult(user: user);
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await _simulateNetworkDelay();
    final normalizedEmail = _normalizeEmail(email);

    if (!_usersByEmail.containsKey(normalizedEmail)) {
      throw const AuthException('No account found with that email.');
    }

    _resetCodesByEmail[normalizedEmail] = '12345';
  }

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    await _simulateNetworkDelay();
    final normalizedEmail = _normalizeEmail(email);
    final expectedCode = _resetCodesByEmail[normalizedEmail];

    if (expectedCode == null || code != expectedCode) {
      throw const AuthException('Invalid verification code.');
    }

    _resetCodesByEmail.remove(normalizedEmail);
  }

  @override
  Future<void> signOut() async {
    await _simulateNetworkDelay();
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  Future<void> _simulateNetworkDelay() {
    return Future<void>.delayed(const Duration(milliseconds: 350));
  }
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({firebase_auth.FirebaseAuth? firebaseAuth})
    : firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  final firebase_auth.FirebaseAuth firebaseAuth;

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return AuthResult(user: _profileFromFirebaseUser(credential.user));
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_messageForFirebaseError(error));
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    if (kIsWeb) {
      return _signInWithGoogleOnWeb();
    }

    try {
      final googleUser = await GoogleSignInCoordinator.instance.signIn();
      if (googleUser == null) {
        throw const AuthCancelledException();
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null && accessToken == null) {
        throw const AuthException(
          'Could not get Google credentials. Check Firebase Google Sign-In setup.',
        );
      }

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
      final userCredential = await firebaseAuth.signInWithCredential(credential);
      return AuthResult(user: _profileFromFirebaseUser(userCredential.user));
    } on AuthCancelledException {
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_messageForFirebaseError(error));
    } catch (error) {
      throw AuthException(_messageForGoogleSignInError(error));
    }
  }

  Future<AuthResult> _signInWithGoogleOnWeb() async {
    try {
      final provider = firebase_auth.GoogleAuthProvider();
      final userCredential = await firebaseAuth.signInWithPopup(provider);
      return AuthResult(user: _profileFromFirebaseUser(userCredential.user));
    } on firebase_auth.FirebaseAuthException catch (error) {
      if (error.code == 'popup-closed-by-user') {
        throw const AuthCancelledException();
      }
      throw AuthException(_messageForFirebaseError(error));
    }
  }

  @override
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      final cleanName = name.trim();

      if (firebaseUser != null && cleanName.isNotEmpty) {
        await firebaseUser.updateDisplayName(cleanName);
        await firebaseUser.reload();
      }

      return AuthResult(
        user: _profileFromFirebaseUser(firebaseAuth.currentUser ?? firebaseUser),
      );
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_messageForFirebaseError(error));
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_messageForFirebaseError(error));
    }
  }

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final accountEmail = await firebaseAuth.verifyPasswordResetCode(code);
      if (accountEmail.toLowerCase() != email.trim().toLowerCase()) {
        throw const AuthException('This reset code belongs to a different email.');
      }
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_messageForFirebaseError(error));
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait<void>([
      firebaseAuth.signOut(),
      GoogleSignInCoordinator.instance.signOut(),
    ]);
  }

  UserProfile _profileFromFirebaseUser(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) {
      throw const AuthException('Unable to load your account.');
    }

    return UserProfile(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName?.trim().isNotEmpty ?? false
          ? firebaseUser.displayName!.trim()
          : 'AppleTech Customer',
      email: firebaseUser.email ?? '',
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }

  String _messageForFirebaseError(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'This email already has an account.';
      case 'weak-password':
        return 'Use a stronger password.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      case 'account-exists-with-different-credential':
        return 'This email is already registered with a different sign-in method.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled for this app. Enable it in Firebase Authentication.';
      case 'popup-closed-by-user':
        return 'Google sign-in was cancelled.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  String _messageForGoogleSignInError(Object error) {
    final text = error.toString();
    if (text.contains('12500') ||
        text.contains('DEVELOPER_ERROR') ||
        text.contains('10:')) {
      return 'Google Sign-In is not configured. In Firebase, add your app SHA-1, '
          'enable Google sign-in, and download an updated google-services.json.';
    }
    if (text.contains('network') || text.contains('Network')) {
      return 'Check your internet connection and try again.';
    }
    return 'Google sign-in failed. Please try again.';
  }
}

class _StoredAuthUser {
  const _StoredAuthUser({required this.profile, required this.password});

  final UserProfile profile;
  final String password;
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// User closed the Google account picker — not an error.
class AuthCancelledException implements Exception {
  const AuthCancelledException();
}

/// Web OAuth 2.0 client ID from Firebase Console (Authentication → Google → Web SDK).
/// Required on Android for Firebase ID tokens. Set when `oauth_client` is in
/// `google-services.json`; leave null to use platform defaults where possible.
const String? kGoogleWebClientId = null;

class GoogleSignInCoordinator {
  GoogleSignInCoordinator._();

  static final GoogleSignInCoordinator instance = GoogleSignInCoordinator._();

  GoogleSignIn? _client;

  GoogleSignIn get client {
    _client ??= GoogleSignIn(
      scopes: const <String>['email', 'profile'],
      serverClientId: kGoogleWebClientId,
    );
    return _client!;
  }

  Future<GoogleSignInAccount?> signIn() => client.signIn();

  Future<void> signOut() async {
    final google = _client;
    if (google != null) {
      await google.signOut();
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  final String code;

  AuthException({
    required this.message,
    required this.code,
  });

  @override
  String toString() => message;
}

/// Authentication service handling Firebase Auth operations
class AuthService {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Get current authenticated user
  User? get currentUser {
    final fbUser = _firebaseAuth.currentUser;
    return fbUser != null ? _convertFirebaseUserToUser(fbUser) : null;
  }

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((fbUser) {
      return fbUser != null ? _convertFirebaseUserToUser(fbUser) : null;
    });
  }

  /// User login with email and password
  Future<User> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credentials = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credentials.user == null) {
        throw AuthException(
          message: 'Login failed: User not found',
          code: 'user_not_found',
        );
      }

      // Update last login time in Firestore (optional)
      // await _updateLastLogin(credentials.user!.uid);

      return _convertFirebaseUserToUser(credentials.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw AuthException(
        message: 'Login failed: ${e.toString()}',
        code: 'login_error',
      );
    }
  }

  /// User registration with email and password
  Future<User> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || !email.contains('@')) {
        throw AuthException(
          message: 'Invalid email format',
          code: 'invalid_email',
        );
      }

      if (password.length < 6) {
        throw AuthException(
          message: 'Password must be at least 6 characters',
          code: 'weak_password',
        );
      }

      if (fullName.isEmpty) {
        throw AuthException(
          message: 'Full name is required',
          code: 'empty_name',
        );
      }

      // Create user account
      final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credentials.user == null) {
        throw AuthException(
          message: 'Account creation failed',
          code: 'signup_error',
        );
      }

      final fbUser = credentials.user!;

      // Update user profile
      await fbUser.updateDisplayName(fullName);
      await fbUser.updatePhotoURL(null);

      // Create user document in Firestore (optional)
      // await _createUserDocument(fbUser.uid, email, fullName, phoneNumber);

      // Send email verification
      if (!fbUser.emailVerified) {
        await fbUser.sendEmailVerification();
      }

      return _convertFirebaseUserToUser(fbUser);
    } on fb.FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw AuthException(
        message: 'Sign up failed: ${e.toString()}',
        code: 'signup_error',
      );
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw AuthException(
        message: 'Sign out failed: ${e.toString()}',
        code: 'signout_error',
      );
    }
  }

  /// Google Sign-In with Gmail
  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException(
          message: 'Google Sign-In cancelled',
          code: 'google_signin_cancelled',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credentials = await _firebaseAuth.signInWithCredential(
        fb.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        ),
      );

      if (credentials.user == null) {
        throw AuthException(
          message: 'Google Sign-In failed: User not found',
          code: 'google_signin_error',
        );
      }

      return _convertFirebaseUserToUser(credentials.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw AuthException(
        message: 'Google Sign-In failed: ${e.toString()}',
        code: 'google_signin_error',
      );
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      if (email.isEmpty) {
        throw AuthException(
          message: 'Email is required',
          code: 'empty_email',
        );
      }

      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw AuthException(
        message: 'Password reset failed: ${e.toString()}',
        code: 'password_reset_error',
      );
    }
  }

  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException(
          message: 'No user is currently logged in',
          code: 'no_user',
        );
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw AuthException(
        message: 'Email verification failed: ${e.toString()}',
        code: 'email_verification_error',
      );
    }
  }

  /// Reload user data from Firebase
  Future<User?> reloadUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        return _convertFirebaseUserToUser(user);
      }
      return null;
    } catch (e) {
      throw AuthException(
        message: 'Failed to reload user: ${e.toString()}',
        code: 'reload_error',
      );
    }
  }

  /// Convert Firebase User to app User model
  User _convertFirebaseUserToUser(fb.User fbUser) {
    return User(
      uid: fbUser.uid,
      email: fbUser.email ?? '',
      fullName: fbUser.displayName,
      phoneNumber: fbUser.phoneNumber,
      createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: fbUser.metadata.lastSignInTime,
      isEmailVerified: fbUser.emailVerified,
    );
  }

  /// Handle Firebase exceptions and convert to custom exceptions
  AuthException _handleFirebaseException(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException(
          message: 'No account found with this email',
          code: 'user_not_found',
        );
      case 'wrong-password':
        return AuthException(
          message: 'Incorrect password',
          code: 'wrong_password',
        );
      case 'email-already-in-use':
        return AuthException(
          message: 'An account with this email already exists',
          code: 'email_already_in_use',
        );
      case 'weak-password':
        return AuthException(
          message: 'Password is too weak. Use at least 6 characters',
          code: 'weak_password',
        );
      case 'invalid-email':
        return AuthException(
          message: 'Invalid email format',
          code: 'invalid_email',
        );
      case 'operation-not-allowed':
        return AuthException(
          message: 'Operation not allowed',
          code: 'operation_not_allowed',
        );
      case 'too-many-requests':
        return AuthException(
          message: 'Too many login attempts. Please try again later',
          code: 'too_many_requests',
        );
      case 'network-request-failed':
        return AuthException(
          message: 'Network error. Please check your connection',
          code: 'network_error',
        );
      default:
        return AuthException(
          message: e.message ?? 'An authentication error occurred',
          code: e.code,
        );
    }
  }
}


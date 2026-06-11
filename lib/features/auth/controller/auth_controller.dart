import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/models/user.dart';
import '../../../data/services/auth_service.dart';

/// Singleton instance of AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Stream of auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Current user provider
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return CurrentUserNotifier(authService);
});

/// Login state notifier
class LoginNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  LoginNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authService.loginWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }
}

/// Login provider
final loginProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return LoginNotifier(authService);
});

/// Sign up state notifier
class SignUpNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  SignUpNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      ),
    );
  }
}

/// Sign up provider
final signUpProvider =
    StateNotifierProvider.autoDispose<SignUpNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return SignUpNotifier(authService);
});

/// Current user notifier
class CurrentUserNotifier extends StateNotifier<User?> {
  final AuthService _authService;

  CurrentUserNotifier(this._authService) : super(null) {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((user) {
      state = user;
    });
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = null;
  }

  Future<void> reloadUser() async {
    final user = await _authService.reloadUser();
    state = user;
  }
}

/// Password reset state notifier
class PasswordResetNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  PasswordResetNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authService.sendPasswordResetEmail(email: email),
    );
  }
}

/// Password reset provider
final passwordResetProvider = StateNotifierProvider.autoDispose<
    PasswordResetNotifier,
    AsyncValue<void>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return PasswordResetNotifier(authService);
});

/// Email verification notifier
class EmailVerificationNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  EmailVerificationNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> sendEmailVerification() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authService.sendEmailVerification(),
    );
  }
}

/// Email verification provider
final emailVerificationProvider = StateNotifierProvider.autoDispose<
    EmailVerificationNotifier,
    AsyncValue<void>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return EmailVerificationNotifier(authService);
});


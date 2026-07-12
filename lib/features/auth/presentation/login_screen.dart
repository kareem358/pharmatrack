import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dar.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/form_validator.dart';
import '../../../core/utils/async_value_extension.dart';
// ...existing code...
import '../controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Trigger login
    await ref.read(loginProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    // Handle response
    if (!mounted) return;

    final loginState = ref.read(loginProvider);
    
    loginState.when(
      data: (user) {
        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Color(0xFF388E3C),
            ),
          );
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      },
      loading: () {
        // Loading state is handled by the UI
      },
      error: (error, stackTrace) {
        debugPrint('Login error: $error');
        // Error is displayed in the UI through uiHasError and uiErrorMessage
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 App Logo + Title
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 100,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'PharmaTrack',
                        style: AppTextStyles.heading1.copyWith(
                          color: AppColors.primary,
                          fontSize: 26,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // 🔹 Welcome Text
                Text('Welcome Back 👋', style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                Text(
                  'Login to your PharmaTrack account',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 40),

                // 🔹 Error Message
                if (loginState.uiHasError)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      border: Border.all(color: AppColors.error),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFFD32F2F), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            loginState.uiErrorMessage ?? 'Login failed',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 🔹 Email Input Field
                TextFormField(
                  controller: _emailController,
                  enabled: !loginState.uiIsLoading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: FormValidator.validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    hintStyle: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.textSecondary.withOpacity(0.25),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.error,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.error,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Password Input Field
                TextFormField(
                  controller: _passwordController,
                  enabled: !loginState.uiIsLoading,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintStyle: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.textSecondary.withOpacity(0.25),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.error,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.error,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                // 🔹 Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: loginState.uiIsLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                          activeColor: AppColors.primary,
                        ),
                        Text(
                          'Remember me',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: loginState.uiIsLoading
                          ? null
                          : () {
                              // TODO: Implement forgot password
                            },
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 🔹 Login Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: loginState.uiIsLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: loginState.uiIsLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.8),
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Login',
                            style: AppTextStyles.button,
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                // 🔹 Divider or Separator
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or continue with',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 20),

                // 🔹 Google Sign-In Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: loginState.uiIsLoading
                        ? null
                        : () async {
                            FocusScope.of(context).unfocus();
                            await ref
                                .read(googleSignInProvider.notifier)
                                .signInWithGoogle();

                            if (!mounted) return;

                            final googleSignInState =
                                ref.read(googleSignInProvider);
                            googleSignInState.when(
                              data: (user) {
                                if (user != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Google login successful!'),
                                      backgroundColor:
                                          Color(0xFF388E3C),
                                    ),
                                  );
                                  Navigator.of(context)
                                      .pushReplacementNamed(
                                          '/dashboard');
                                }
                              },
                              loading: () {},
                              error: (error, stackTrace) {
                                debugPrint(
                                    'Google Sign-In error: $error');
                              },
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      disabledBackgroundColor: Colors.grey[200],
                      side: BorderSide(
                        color: Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.mail_outline),
                    label: Text(
                      'Sign in with Google',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 🔹 Sign Up Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.caption,
                      ),
                      GestureDetector(
                          onTap: loginState.uiIsLoading
                            ? null
                            : () {
                                Navigator.pushNamed(context, '/signup');
                              },
                        child: Text(
                          'Sign Up',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





/*
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dar.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // centered logo
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'PharmaTrack',
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.primary,
                        fontSize: 26,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // 🔹 Welcome Text
              Text('Welcome Back 👋', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text(
                'Login to your PharmaTrack account',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 40),

              // input field as a email and pass
              CustomTextField(
                controller: emailController,
                label: 'Email',
                hintText: 'Enter your email',
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: passwordController,
                label: 'Password',
                hintText: 'Enter your password',
                isPassword: true,
              ),
              const SizedBox(height: 40),

              // login button to the dashboard
              CustomButton(
                label: 'Login',
                onPressed: () {
                  Navigator.pushNamed(context, '/dashboard');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


*/

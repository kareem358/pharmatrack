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

              // 🔹 Input Fields
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

              // 🔹 Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // later: Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: Text(
                    'Forgot Password?',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Login Button
              CustomButton(
                label: 'Login',
                onPressed: () {
                  Navigator.pushNamed(context, '/dashboard');
                },
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
                      onTap: () {
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

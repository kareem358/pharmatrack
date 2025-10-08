import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dar.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

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
              Text('Create Account 👋', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text(
                'Sign up to get started with PharmaTrack',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 40),

              // 🔹 Input Fields
              CustomTextField(
                controller: nameController,
                label: 'Full Name',
                hintText: 'Enter your name',
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              CustomTextField(
                controller: confirmPasswordController,
                label: 'Confirm Password',
                hintText: 'Re-enter your password',
                isPassword: true,
              ),
              const SizedBox(height: 40),

              // 🔹 Sign Up Button
              CustomButton(
                label: 'Sign Up',
                onPressed: () {
                  Navigator.pushNamed(context, '/dashboard');
                  // later: implement actual sign up logic
                },
              ),
              const SizedBox(height: 30),

              // 🔹 Login Link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: AppTextStyles.caption,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Go back to login
                      },
                      child: Text(
                        'Login',
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

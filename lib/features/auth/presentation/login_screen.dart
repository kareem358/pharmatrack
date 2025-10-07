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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text('Welcome Back 👋', style: AppTextStyles.heading1),
              const SizedBox(height: 8),
              Text('Login to your PharmaTrack account', style: AppTextStyles.caption),
              const SizedBox(height: 40),
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



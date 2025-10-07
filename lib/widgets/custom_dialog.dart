
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dar.dart';
import '../core/constants/app_text_styles.dart';
import 'custom_button.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final VoidCallback onConfirm;
  final String? cancelText;
  final VoidCallback? onCancel;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.background,
      title: Text(title, style: AppTextStyles.heading1),
      content: Text(message, style: AppTextStyles.body),
      actions: [
        if (cancelText != null)
          TextButton(
            onPressed: onCancel ?? () => Navigator.pop(context),
            child: Text(cancelText!, style: AppTextStyles.body),
          ),
        CustomButton(
          label: confirmText,
          onPressed: onConfirm,
          //color: AppColors.primary,
        ),
      ],
    );
  }
}

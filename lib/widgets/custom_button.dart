import 'package:flutter/material.dart';
import '../core/constants/app_colors.dar.dart';
import '../core/constants/app_text_styles.dart';


class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isOutlined;
  final bool isDisabled;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = isOutlined
        ? Colors.transparent
        : (isDisabled ? Colors.grey : AppColors.primary);

    final borderColor = isOutlined ? AppColors.primary : Colors.transparent;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: isOutlined ? AppColors.primary : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: borderColor, width: 1.5),
          ),
          elevation: 0,
        ),
        child: Text(label, style: AppTextStyles.button),
      ),
    );
  }
}

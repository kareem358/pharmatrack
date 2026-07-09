import 'package:flutter/material.dart';
import '../core/constants/app_colors.dar.dart';
import '../core/constants/app_text_styles.dart';


class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textLight.withOpacity(0.6)),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.title),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textLight.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}

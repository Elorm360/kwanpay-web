import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: AppColors.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutButton({
    super.key,
    required this.onLogout,
  });

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        title: const Text(
          "Sign Out",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          "Are you sure you want to sign out of your KwanPay account?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onLogout();
            },
            child: const Text(
              "Sign Out",
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: () => _showLogoutConfirmation(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.error),
            foregroundColor: AppColors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
          ),
          child: const Text(
            "Log Out",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}


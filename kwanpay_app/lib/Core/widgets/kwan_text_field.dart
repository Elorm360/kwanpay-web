import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class KwanTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscure;
  final TextEditingController controller;

  const KwanTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Colors.grey.shade700,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(
            color: AppColors.accent,
            width: 2,
          ),
        ),
      ),
    );
  }
}


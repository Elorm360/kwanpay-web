import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../Core/theme/app_colors.dart';
import '../../../Core/theme/app_radius.dart';

class OtpCodeField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;

  const OtpCodeField({
    super.key,
    required this.controller,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 6,
      style: const TextStyle(
        fontSize: 27,
        fontWeight: FontWeight.w700,
        letterSpacing: 12,
        color: AppColors.primary,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: InputDecoration(
        counterText: '',
        hintText: '••••••',
        hintStyle: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w700,
          letterSpacing: 12,
          color: AppColors.textSecondary.withValues(alpha: 0.35),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
      onChanged: (value) {
        if (value.length == 6) {
          onCompleted?.call(value);
        }
      },
    );
  }
}

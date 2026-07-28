import 'package:flutter/material.dart';

import '../../../core/models/profile_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_colors.dart';

class ProfileInfoCard extends StatelessWidget {
  final ProfileModel? profile;
  final bool isLoading;

  const ProfileInfoCard({
    super.key,
    required this.profile,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final email = isLoading
        ? ""
        : (profile?.email.isNotEmpty == true
            ? profile!.email
            : "");
    final phone = isLoading
        ? ""
        : (profile?.phone.isNotEmpty == true
            ? profile!.phone
            : "Not Added");
    final country = isLoading
        ? ""
        : (profile?.country.isNotEmpty == true
            ? profile!.country
            : "Not Added");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: context.colorSurface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.email_outlined,
              label: "Email",
              value: email,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Divider(height: 1, color: context.colorBorder),
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: "Phone",
              value: phone,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Divider(height: 1, color: context.colorBorder),
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              icon: Icons.public_outlined,
              label: "Country",
              value: country,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = value == "Not Available" || value == "Not Set";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: context.colorTextSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isPlaceholder
                  ? context.colorTextSecondary
                  : context.colorTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}


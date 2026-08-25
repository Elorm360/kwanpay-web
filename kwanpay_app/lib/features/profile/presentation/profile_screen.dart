import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/profile_model.dart';
import '../../../core/providers/wallet_dashboard_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/presentation/welcome_screen.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_section.dart';
import '../widgets/profile_tile.dart';
import 'edit_profile_screen.dart';
import 'payment_methods_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ProfileModel? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final result = await ProfileService().getProfile();

    if (!mounted) return;

    setState(() {
      profile = result;
      isLoading = false;
    });
  }

  Future<void> _navigateToEditProfile() async {
    if (profile == null) return;

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: profile!),
      ),
    );

    if (updated == true) {
      // Reload profile so changes show immediately
      loadProfile();
    }
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "Light";
      case ThemeMode.dark:
        return "Dark";
      case ThemeMode.system:
        return "System";
    }
  }

  IconData _themeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.settings_brightness_outlined;
    }
  }

  void _showThemePicker() {
    final currentMode = ref.read(themeModeProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Handle ───────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                "Appearance",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "Choose your preferred theme.",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // ── Options ──────────────────────────────
              for (final mode in ThemeMode.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ThemeOption(
                    icon: _themeModeIcon(mode),
                    label: _themeModeLabel(mode),
                    isSelected: currentMode == mode,
                    onTap: () {
                      ref.read(themeModeProvider.notifier).state = mode;
                      Navigator.pop(sheetContext);
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final dashboard = ref.watch(walletDashboardProvider);
    final wallet = dashboard.wallet;
    final defaultMethod = dashboard.defaultPaymentMethod;

    return Scaffold(
      backgroundColor: context.colorPaper,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: AppSpacing.lg,
            bottom: AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────
              ProfileHeader(
                userName: isLoading
                    ? "Loading..."
                    : profile?.fullName ?? "Traveller",
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Personal Information ────────────────────
              ProfileInfoCard(
                profile: profile,
                isLoading: isLoading,
              ),
              const SizedBox(height: AppSpacing.sm),
              // ── Edit Profile Button ────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToEditProfile(),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text("Edit Profile"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Wallet ──────────────────────────────────
              ProfileSection(
                title: "WALLET",
                children: [
                  ProfileTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: "Wallet Status",
                    subtitle: wallet == null
                        ? "Not created"
                        : "${wallet.status} · ${wallet.walletId}",
                    onTap: () {},
                  ),
                  ProfileTile(
                    icon: Icons.link_outlined,
                    title: "Payment methods",
                    subtitle: defaultMethod == null
                        ? "Add Mobile Money"
                        : "${defaultMethod.network.name} · ${defaultMethod.displayNumber}",
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentMethodsScreen(),
                        ),
                      );
                      await ref
                          .read(walletDashboardProvider.notifier)
                          .refresh();
                    },
                  ),
                ],
              ),

              // ── Security ────────────────────────────────
              ProfileSection(
                title: "SECURITY",
                children: [
                  ProfileTile(
                    icon: Icons.lock_outline_rounded,
                    title: "Change Password",
                    onTap: () {},
                  ),
                  ProfileTile(
                    icon: Icons.fingerprint,
                    title: "Biometric Login",
                    onTap: () {},
                  ),
                ],
              ),

              // ── Preferences ─────────────────────────────
              ProfileSection(
                title: "PREFERENCES",
                children: [
                  ProfileTile(
                    icon: Icons.notifications_outlined,
                    title: "Notifications",
                    onTap: () {},
                  ),
                  ProfileTile(
                    icon: _themeModeIcon(themeMode),
                    title: "Appearance",
                    subtitle: _themeModeLabel(themeMode),
                    onTap: _showThemePicker,
                  ),
                ],
              ),

              // ── Support ─────────────────────────────────
              ProfileSection(
                title: "SUPPORT",
                children: [
                  ProfileTile(
                    icon: Icons.help_outline_rounded,
                    title: "Help Center",
                    onTap: () {},
                  ),
                  ProfileTile(
                    icon: Icons.chat_outlined,
                    title: "Contact Support",
                    onTap: () {},
                  ),
                  ProfileTile(
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy Policy",
                    onTap: () {},
                  ),
                ],
              ),

              // ── About ───────────────────────────────────
              ProfileSection(
                title: "ABOUT",
                children: [
                  ProfileTile(
                    icon: Icons.info_outline_rounded,
                    title: "Version",
                    subtitle: "1.0",
                    onTap: () {},
                  ),
                  ProfileTile(
                    icon: Icons.description_outlined,
                    title: "Terms of Service",
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Logout ──────────────────────────────────
              LogoutButton(
                onLogout: () async {
                  await AuthService().signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WelcomeScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single selectable option row in the theme picker bottom sheet.
class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.accent.withValues(alpha: 0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? AppColors.accent
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.accent
                      : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 22,
                  color: AppColors.accent,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

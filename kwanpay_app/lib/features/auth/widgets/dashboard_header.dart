import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class DashboardHeader extends StatefulWidget {
  final String userName;

  const DashboardHeader({
    super.key,
    required this.userName,
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  static const _slogans = [
    "The path your payment takes.",
    "Send money anywhere in Africa.",
    "Pay operators in seconds.",
    "Your wallet, your rules.",
    "Travel smarter, pay easier.",
    "Fast transfers. Fair rates.",
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _slogans.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 5) return "Good Evening";

    if (hour < 12) return "Good Morning";

    if (hour < 17) return "Good Afternoon";

    return "Good Evening";
  }

  /// Returns a contextually relevant emoji based on the time of day.
  /// 🌅 dawn/morning → ☀️ afternoon → 🌆 evening → 🌙 late night
  String getGreetingEmoji() {
    final hour = DateTime.now().hour;

    if (hour < 5) return "🌙"; // late night

    if (hour < 12) return "🌅"; // morning

    if (hour < 17) return "☀️"; // afternoon

    if (hour < 21) return "🌆"; // evening

    return "🌙"; // night
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${getGreeting()} ${getGreetingEmoji()}",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.userName.isEmpty
                      ? "Welcome to KwanPay"
                      : "${getGreeting()}, ${widget.userName}",
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    _slogans[_currentIndex],
                    key: ValueKey(_currentIndex),
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.paper,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_rounded),
          label: "Explore",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_rounded),
          label: "Wallet",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: "Profile",
        ),
      ],
    );
  }
}

